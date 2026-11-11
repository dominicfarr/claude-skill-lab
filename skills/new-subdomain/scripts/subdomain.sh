#!/usr/bin/env bash
# Host a static site or a single file on <name>.domfarr.com through the
# CloudFormation stack in subdomain.yaml (S3, CloudFront, ACM, Route 53).
#
# <path> is either a folder with index.html at its top (a site: unknown paths
# serve index.html, so client-side routes work) or a single file (served at /
# and every other path, with its own content type).
#
# Names that already have a bucket or DNS records outside this tool are refused,
# so hand-built subdomains (care, coconut, organism) are never touched.
set -euo pipefail

export AWS_PROFILE="${AWS_PROFILE:-domfarr}" AWS_REGION=us-east-1 AWS_PAGER=""
DOMAIN=domfarr.com
ZONE=Z03722621B6AEUR5NOSKX
TEMPLATE="$(cd "$(dirname "$0")" && pwd)/subdomain.yaml"

usage() {
  cat >&2 <<EOF
usage: $(basename "$0") up <name> <path>      create or update <name>.$DOMAIN, upload <path>, verify
       $(basename "$0") down <name> [--yes]   empty the bucket and delete the stack
EOF
  exit 2
}

die() { echo "subdomain: $*" >&2; exit 1; }

stack_status() {
  aws cloudformation describe-stacks --stack-name "$STACK" --query 'Stacks[0].StackStatus' --output text 2>/dev/null || true
}

output() {
  aws cloudformation describe-stacks --stack-name "$STACK" \
    --query "Stacks[0].Outputs[?OutputKey=='$1'].OutputValue" --output text
}

refuse_if_taken() {
  local err
  if err=$(aws s3api head-bucket --bucket "$HOST" 2>&1); then
    die "bucket $HOST already exists outside this tool; refusing"
  fi
  [[ $err == *"(404)"* ]] || die "bucket name $HOST is unavailable: $err"
  [[ -z $(aws route53 list-resource-record-sets --hosted-zone-id "$ZONE" \
    --query "ResourceRecordSets[?Name=='$HOST.']" --output text) ]] ||
    die "$HOST already has DNS records outside this tool; refusing"
}

verify() {
  local cf=$1 failed=0 ips
  echo "Checks:"
  python3 - "$cf" <<'PY' || failed=1
import sys, urllib.request as u
bad = 0
for p in ("/", "/no-such-path"):
    try:
        r = u.urlopen(f"https://{sys.argv[1]}{p}", timeout=20)
        print(f"  content  {p:<14} {r.status} {r.headers['content-type']}")
    except Exception as e:
        print(f"  content  {p:<14} FAIL {e}")
        bad = 1
sys.exit(bad)
PY
  if openssl s_client -connect "$cf:443" -servername "$HOST" </dev/null 2>/dev/null |
    openssl x509 -noout -ext subjectAltName 2>/dev/null | grep -q "DNS:$HOST"; then
    echo "  cert     covers $HOST"
  else
    echo "  cert     FAIL: CloudFront presents no certificate for $HOST"
    failed=1
  fi
  # Public DNS, not the Mac's resolver, which may have cached a "not found".
  ips=$(dig +short "$HOST" @1.1.1.1 | paste -sd ' ' -)
  if [[ -n $ips ]]; then
    echo "  dns      $ips"
  else
    echo "  dns      FAIL: $HOST doesn't resolve on 1.1.1.1 yet"
    failed=1
  fi
  return "$failed"
}

cmd_up() {
  local path=$1 root status dist cf
  if [[ -d $path ]]; then
    [[ -f $path/index.html ]] || die "$path has no index.html at its top"
    root=index.html
  elif [[ -f $path ]]; then
    # The file's name becomes CloudFront's DefaultRootObject, which rejects
    # spaces and most punctuation, so store it under a cleaned-up key.
    root=$(basename "$path" | LC_ALL=C sed -E 's/[^A-Za-z0-9._-]+/-/g; s/^-+//')
    [[ -n $root && $root != .* ]] || root=file
  else
    die "no such file or folder: $path"
  fi

  status=$(stack_status)
  if [[ $status == ROLLBACK_COMPLETE ]]; then
    # A failed first create leaves an empty stack that can't be updated.
    echo "Removing failed stack $STACK..."
    aws cloudformation delete-stack --stack-name "$STACK"
    aws cloudformation wait stack-delete-complete --stack-name "$STACK"
    status=""
  fi
  [[ -n $status ]] || refuse_if_taken

  echo "Deploying stack $STACK (a new certificate and distribution take several minutes)..."
  if ! aws cloudformation deploy --stack-name "$STACK" --template-file "$TEMPLATE" \
    --parameter-overrides SubdomainName="$NAME" RootObject="$root" --no-fail-on-empty-changeset; then
    aws cloudformation describe-stack-events --stack-name "$STACK" \
      --query "StackEvents[?contains(ResourceStatus,'FAILED')].[LogicalResourceId,ResourceStatusReason]" \
      --output text | head -5 >&2
    die "stack deploy failed"
  fi
  dist=$(output DistributionId)
  cf=$(output DistributionDomainName)

  echo "Uploading $path..."
  if [[ -d $path ]]; then
    aws s3 sync "$path" "s3://$HOST" --delete --only-show-errors
  else
    aws s3 cp "$path" "s3://$HOST/$root" --content-type "$(file --mime-type -b "$path")" --only-show-errors
    aws s3 rm "s3://$HOST" --recursive --exclude "$root" --only-show-errors
  fi
  aws cloudfront create-invalidation --distribution-id "$dist" --paths '/*' >/dev/null

  status=0
  verify "$cf" || status=1
  echo
  echo "https://$HOST  (bucket $HOST, distribution $dist, $cf)"
  return "$status"
}

cmd_down() {
  local answer vname record
  [[ -n $(stack_status) ]] || die "no stack $STACK; $HOST isn't managed by this tool"
  if [[ ${1:-} != --yes ]]; then
    read -r -p "Delete https://$HOST and everything in it? Type '$NAME' to confirm: " answer
    [[ $answer == "$NAME" ]] || die "not confirmed; nothing deleted"
  fi
  # CloudFormation adds the certificate's validation CNAME but leaves it behind
  # on delete, so note its name now and remove it after the stack is gone.
  vname=$(aws acm describe-certificate --certificate-arn "$(output CertificateArn)" \
    --query 'Certificate.DomainValidationOptions[0].ResourceRecord.Name' --output text 2>/dev/null || true)
  # CloudFormation can't delete a bucket that still holds objects.
  aws s3 rm "s3://$HOST" --recursive --only-show-errors 2>/dev/null || true
  echo "Deleting stack $STACK (disabling the distribution takes several minutes)..."
  aws cloudformation delete-stack --stack-name "$STACK"
  aws cloudformation wait stack-delete-complete --stack-name "$STACK"
  if [[ -n $vname && $vname != None ]]; then
    record=$(aws route53 list-resource-record-sets --hosted-zone-id "$ZONE" \
      --query "ResourceRecordSets[?Name=='$vname'] | [0]" --output json)
    if [[ $record != null ]]; then
      aws route53 change-resource-record-sets --hosted-zone-id "$ZONE" \
        --change-batch "{\"Changes\":[{\"Action\":\"DELETE\",\"ResourceRecordSet\":$record}]}" >/dev/null
    fi
  fi
  echo "Deleted $HOST"
}

[[ $# -ge 2 ]] || usage
CMD=$1 NAME=$2
shift 2
[[ $NAME =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]] || die "invalid subdomain label: $NAME"
HOST=$NAME.$DOMAIN
STACK=subdomain-$NAME

case $CMD in
  up) [[ $# -eq 1 ]] || usage; cmd_up "$1" ;;
  down) cmd_down "$@" ;;
  *) usage ;;
esac
