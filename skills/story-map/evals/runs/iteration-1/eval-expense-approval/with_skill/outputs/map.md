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
