# Sliced stories (Gherkin)

## #108 Submit a request with amount, date and description
```gherkin
Feature: Submit a request with amount, date and description

  Scenario: Employee submits a valid request
    Given Priya is signed in and her manager is Marcus
    When she submits a request for 42.50 dated 2026-11-10 with description "Client lunch"
    Then a request is created with status "Pending approval"
    And it is assigned to Marcus for review

  Scenario: Employee submits a request with a non-positive amount
    Given Priya is signed in
    When she submits a request for 0 dated 2026-11-10 with description "Client lunch"
    Then no request is created
    And she sees the error "Amount must be greater than 0"

  Scenario: Employee submits a request with no description
    Given Priya is signed in
    When she submits a request for 42.50 dated 2026-11-10 with an empty description
    Then no request is created
    And she sees the error "Description is required"
```

## #140 List pending requests from my direct reports
```gherkin
Feature: List pending requests from my direct reports

  Scenario: Manager sees only their reports' pending requests
    Given Marcus manages Priya and Jo manages Sam
    And Priya has a pending request "Client lunch" for 42.50
    And Sam has a pending request "Taxi" for 18.00
    When Marcus opens his review list
    Then he sees "Client lunch" for 42.50 from Priya
    And he does not see "Taxi"

  Scenario: Manager has nothing to review
    Given Marcus manages Priya and she has no pending requests
    When Marcus opens his review list
    Then he sees the message "No requests awaiting your decision"
```

## #146 Approve a request
```gherkin
Feature: Approve a request

  Scenario: Manager approves a pending request
    Given Priya has a pending request "Client lunch" for 42.50 assigned to Marcus
    When Marcus approves it
    Then the request status becomes "Approved"
    And it no longer appears in Marcus's review list
    And it appears in finance's list of approved requests awaiting payment
```

## #150 Reject a request with a reason
```gherkin
Feature: Reject a request with a reason

  Scenario: Manager rejects a pending request with a reason
    Given Priya has a pending request "Client lunch" for 42.50 assigned to Marcus
    When Marcus rejects it with the reason "Not a business expense"
    Then the request status becomes "Rejected"
    And Priya can see the reason "Not a business expense" on the request
    And it does not appear in finance's list of approved requests

  Scenario: Manager rejects without giving a reason
    Given Priya has a pending request "Client lunch" for 42.50 assigned to Marcus
    When Marcus rejects it with an empty reason
    Then the request status stays "Pending approval"
    And Marcus sees the error "A reason is required to reject a request"
```

## #159 List approved requests awaiting payment
```gherkin
Feature: List approved requests awaiting payment

  Scenario: Finance sees approved unpaid requests only
    Given an approved unpaid request "Client lunch" for 42.50 from Priya
    And a pending request "Taxi" for 18.00 from Sam
    And a paid request "Train" for 60.00 from Jo
    When Fatima from finance opens the payout list
    Then she sees "Client lunch" for 42.50 from Priya
    And she does not see "Taxi" or "Train"

  Scenario: Nothing is awaiting payment
    Given there are no approved unpaid requests
    When Fatima from finance opens the payout list
    Then she sees the message "No requests awaiting payment"
```

## #164 Mark an approved request as paid
```gherkin
Feature: Mark an approved request as paid

  Scenario: Finance marks an approved request as paid
    Given an approved unpaid request "Client lunch" for 42.50 from Priya
    When Fatima from finance marks it as paid
    Then the request status becomes "Paid"
    And it no longer appears in the payout list
    And Priya sees the request as "Paid"

  Scenario: Finance cannot mark an unapproved request as paid
    Given a pending request "Taxi" for 18.00 from Sam
    When Fatima from finance tries to mark it as paid
    Then the request status stays "Pending approval"
    And she sees the error "Only approved requests can be paid"
```
