# Transcript

## 1. Read the skill
Read SKILL.md, scripts/publish-story-map.sh and docs/agents/issue-tracker.md. Idea names who (employees, managers, finance) and outcome, so no clarifying question was needed.

## 2. Assumptions (labeled, non-interactive)
- ASSUMPTION A: one manager per employee; manager approval is a single level (no multi-level chains). Question I would have asked: Is approval single-level, and are there spending limits?
- ASSUMPTION B: finance pays outside the tool (bank transfer); the tool only records it as Paid. Question: Should the tool initiate payments?
- ASSUMPTION C: rejected requests can be resubmitted later (card only, not in slice); no re-approval rules specified.
- ASSUMPTION D: single currency; receipts optional in the skeleton.
- ASSUMPTION E (sign-off step): the skill says to share the map in chat and iterate with the user before slicing. No human is available, so I treated the map as approved as proposed and continued; this is a deviation forced by the non-interactive run.

## 3. Backbone
Journeys: Submit an expense -> Review an expense -> Pay out an expense. Steps: Create a request; Track my requests; Find requests awaiting my decision; Decide on a request; Find approved requests to pay; Pay and record.

## 4. Map (stories under each step)
See map.md (reproduced below).

# Story map: Expense reimbursement tool

Internal tool where employees submit expense reimbursement requests, their manager approves or rejects them, and finance pays out the approved ones.

Legend: 🦴 = walking-skeleton slice (has BDD specs)

## Submit an expense

**Create a request**
- 🦴 Submit request with amount, date, category and description
- Attach receipt image or PDF
- Save request as draft

**Track my requests**
- 🦴 View my requests and their status
- Withdraw a pending request
- Edit and resubmit a rejected request

## Review an expense

**Find requests awaiting my decision**
- 🦴 See pending requests from my direct reports
- Email manager when a request is submitted
- Delegate approvals while on leave

**Decide on a request**
- 🦴 Approve a request
- 🦴 Reject a request with a reason
- Approve with a comment
- Escalate requests above a spending limit

## Pay out an expense

**Find approved requests to pay**
- 🦴 See approved requests awaiting payout
- Filter payout queue by employee or date

**Pay and record**
- 🦴 Mark an approved request as paid
- Export approved requests as a payment batch CSV
- Record payment reference number
- Monthly reimbursement report

## 5. Walking skeleton
Chosen: the thinnest path through all three journeys with every step covered: submit, view own status, manager queue, approve, reject-with-reason, finance queue, mark paid. Approve and reject are both in because the user's brief says approves or rejects, and reject is what makes the status view meaningful end to end. Left out: receipts, drafts, withdraw, resubmit, notifications, delegation, limits, CSV export, payment reference, reports.

## 6. Gherkin specs (as published)

### Submit request with amount, date, category and description

```gherkin
Feature: Submit request with amount, date, category and description

  Scenario: Employee submits a valid request
    Given I am signed in as employee "Alice" whose manager is "Bob"
    When I submit an expense with amount "42.50", date "2026-11-10", category "Travel" and description "Taxi to client site"
    Then a request is created with status "Pending approval"
    And the request is assigned to "Bob" for review

  Scenario: Amount must be positive
    Given I am signed in as employee "Alice"
    When I submit an expense with amount "0", date "2026-11-10", category "Travel" and description "Taxi"
    Then no request is created
    And I see an error that the amount must be greater than zero

  Scenario: Required fields are missing
    Given I am signed in as employee "Alice"
    When I submit an expense with an empty description
    Then no request is created
    And I see an error that the description is required
```

### View my requests and their status

```gherkin
Feature: View my requests and their status

  Scenario: Employee sees their own requests with status
    Given I am signed in as employee "Alice"
    And I have a "Pending approval" request and a "Rejected" request
    And employee "Carol" has a "Paid" request
    When I open "My requests"
    Then I see exactly my two requests with their amounts and statuses
    And I do not see Carol's request

  Scenario: Employee has no requests
    Given I am signed in as employee "Alice" with no requests
    When I open "My requests"
    Then I see an empty state saying I have not submitted any requests
```

### See pending requests from my direct reports

```gherkin
Feature: See pending requests from my direct reports

  Scenario: Manager sees only their reports' pending requests
    Given I am signed in as manager "Bob"
    And "Alice" reports to me and has a "Pending approval" request
    And "Dave" reports to someone else and has a "Pending approval" request
    When I open "Awaiting my approval"
    Then I see Alice's request with submitter, amount, category and description
    And I do not see Dave's request

  Scenario: Nothing to review
    Given I am signed in as manager "Bob" with no pending requests from my reports
    When I open "Awaiting my approval"
    Then I see an empty state saying there is nothing to review
```

### Approve a request

```gherkin
Feature: Approve a request

  Scenario: Manager approves a pending request
    Given I am signed in as manager "Bob"
    And Alice's request for "42.50" is "Pending approval" and assigned to me
    When I approve the request
    Then the request status becomes "Approved"
    And it no longer appears in my "Awaiting my approval" list
    And it appears in finance's payout queue

  Scenario: Manager cannot approve their own request
    Given I am signed in as manager "Bob"
    And I have submitted my own request that is "Pending approval"
    When I try to approve my own request
    Then the request status stays "Pending approval"
    And I see an error that I cannot approve my own request

  Scenario: Request was already decided
    Given I am signed in as manager "Bob"
    And Alice's request was already "Rejected"
    When I try to approve the request
    Then the status stays "Rejected"
    And I see an error that the request has already been decided
```

### Reject a request with a reason

```gherkin
Feature: Reject a request with a reason

  Scenario: Manager rejects with a reason
    Given I am signed in as manager "Bob"
    And Alice's request is "Pending approval" and assigned to me
    When I reject the request with reason "No receipt, please resubmit"
    Then the request status becomes "Rejected"
    And Alice sees the reason "No receipt, please resubmit" on her request
    And the request does not appear in finance's payout queue

  Scenario: Reason is required
    Given I am signed in as manager "Bob"
    And Alice's request is "Pending approval" and assigned to me
    When I reject the request with an empty reason
    Then the request status stays "Pending approval"
    And I see an error that a reason is required
```

### See approved requests awaiting payout

```gherkin
Feature: See approved requests awaiting payout

  Scenario: Finance sees approved, unpaid requests
    Given I am signed in as a finance user
    And there are requests with statuses "Approved", "Pending approval", "Rejected" and "Paid"
    When I open the payout queue
    Then I see only the "Approved" request with submitter, amount and approval date

  Scenario: Only finance can see the queue
    Given I am signed in as employee "Alice" without the finance role
    When I try to open the payout queue
    Then I am denied access

  Scenario: Queue is empty
    Given I am signed in as a finance user and no requests are "Approved"
    When I open the payout queue
    Then I see an empty state saying there is nothing to pay
```

### Mark an approved request as paid

```gherkin
Feature: Mark an approved request as paid

  Scenario: Finance marks a request paid
    Given I am signed in as a finance user
    And Alice's request for "42.50" is "Approved"
    When I mark the request as paid with payment date "2026-11-18"
    Then the request status becomes "Paid"
    And it no longer appears in the payout queue
    And Alice sees the status "Paid" and the payment date on her request

  Scenario: Request is not yet approved
    Given I am signed in as a finance user
    And Alice's request is "Pending approval"
    When I try to mark the request as paid
    Then the status stays "Pending approval"
    And I see an error that only approved requests can be paid
```

Decisions the scenarios bake in that a human should confirm: manager cannot self-approve; rejection requires a reason; decisions are final (no re-deciding); only finance role sees the payout queue.

## 7. Publish
Wrote JSON to /private/tmp/claude-502/-Users-dom-Projects-claude-skill-lab/43641b2d-1224-4a86-87b8-dcbfb46cd682/scratchpad/map.json, then ran:

```
cd /private/tmp/claude-502/-Users-dom-Projects-claude-skill-lab/43641b2d-1224-4a86-87b8-dcbfb46cd682/scratchpad/story-map-skill-test && /Users/dom/Projects/claude-skill-lab/skills/story-map/scripts/publish-story-map.sh ../map.json
```

Exit success. Output: map issue #5 plus children #6-#57 (see issues.md for table). Verification: gh issue view 6 shows the Gherkin in a fenced block with newlines intact; gh api issues/5/sub_issues returned 19 sub-issues; child issue 12 has 0 comments (no fallback used). Issue numbers are non-contiguous because other eval runs wrote to the same repo concurrently.