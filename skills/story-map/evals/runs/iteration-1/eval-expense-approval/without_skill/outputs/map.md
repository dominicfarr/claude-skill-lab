# Expense Reimbursement Tool: Core Flow Spec

## Assumptions (no human available to answer, so these are my picks)
1. Question: how do people sign in and who is whose manager? Assumption: company SSO provides identity, and each user record has a single manager and a role (employee, manager, finance).
2. Question: is payout executed by the tool or recorded by finance? Assumption: finance pays outside the tool (bank/payroll) and marks the request Paid with a reference. No payment-provider integration in v1.
3. Question: currency and limits? Assumption: single currency, no approval thresholds or policy rules in v1.
4. Question: are receipts mandatory? Assumption: yes, at least one receipt file is required to submit.
5. Rejection requires a comment; the employee may edit and resubmit.

## Actors
Employee (submitter), Manager (approver), Finance (payer).

## Request lifecycle
Draft -> Submitted -> Approved | Rejected -> Paid
Rejected -> (edit) -> Submitted again. Only Approved can become Paid.

## Backbone (activities) and stories

| Create request | Submit for approval | Review (manager) | Pay (finance) | Track |
|---|---|---|---|---|
| Create a draft with amount, date, category, description | Submit a draft | See queue of requests from my reports | See queue of approved requests | See my requests and their status |
| Attach receipt(s) | Edit and resubmit after rejection | Approve a request | Mark request as paid with payment reference | Notified when status changes |
| | Withdraw a submitted request | Reject with a required comment | | |

## Release slices
- Walking skeleton (v1): create draft with fields, attach receipt, submit, manager queue, approve, reject with comment, finance queue, mark paid, employee sees status.
- v1.1: resubmit after rejection, withdraw, email notifications.
- Later (out of scope now): policy limits and auto-approval, multi-level approval, delegation when manager is away, payment export/integration, reporting, multi-currency.

## Stories and acceptance criteria

1. Create expense request draft. Given I am signed in, when I enter amount (>0), date (not in future), category, description and save, then a Draft exists that only I can see.
2. Attach receipt. I can upload PNG/JPG/PDF up to 10 MB, multiple allowed; I can remove one while Draft.
3. Submit request. Submit requires all fields and at least one receipt; status becomes Submitted and the request is locked from editing; my manager sees it.
4. Manager review queue. A manager sees only Submitted requests from direct reports, oldest first, with details and receipts.
5. Approve request. Manager approves; status Approved; records approver and timestamp; manager cannot approve own request.
6. Reject request. Manager must enter a comment; status Rejected; employee can see the comment.
7. Finance payout queue. Finance sees Approved requests, unpaid.
8. Mark as paid. Finance enters payment reference and date; status Paid; Paid is final and cannot be changed.
9. My requests and status. Employee lists own requests with status, and rejection comment or payment reference.
10. Resubmit after rejection (v1.1). Employee edits a Rejected request and submits again; history is kept.
11. Withdraw submitted request (v1.1). Allowed only before a decision.
12. Email notifications (v1.1). Manager on submission, employee on decision, employee on payment.

## Cross-cutting rules
- Authorization by role; everyone sees only what their role allows.
- Audit trail of every status change (who, when).
