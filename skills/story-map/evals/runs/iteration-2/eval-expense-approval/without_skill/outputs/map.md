# Expense reimbursement story map
Overview issue: https://github.com/dominicfarr/story-map-skill-test/issues/124

Backbone: Access | Submit (Employee) | Approve (Manager) | Pay (Finance)

R1 (walking skeleton)
- Access: #97 sign-in and roles
- Submit: #90 submit request, #91 view my requests
- Approve: #92 pending queue, #93 approve, #94 reject with reason
- Pay: #95 payout queue, #96 mark paid
R2: #99 notifications, #100 edit/withdraw, #102 escalation / no self-approval
R3: #106 audit + CSV export, #110 policy limits + multi-currency

States: Submitted -> Approved -> Paid; Submitted -> Rejected; Submitted -> Withdrawn.
Assumptions: SSO, 3 roles, single approval level, single currency in R1, receipt required over 25, payment done outside tool.
