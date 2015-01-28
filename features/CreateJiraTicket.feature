Feature:  As a release engineer, I would like the Emissary to create a JIRA Ticket from a VersionOne Ticket, so that I can continue to work through the JIRA process for Release Engineering

Feature:  Create a JIRA ticket from a VersionOne Defect ticket

Scenario:  Emissary creates a JIRA ticket for a newly created VersionOne Defect

Given I create a defect in VersionOne
When the Emissary processes the ticket
Then I should see a matching ticket in JIRA

