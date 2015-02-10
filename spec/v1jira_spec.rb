require './lib/v1jira'
require './lib/v1defect'
require 'yaml'
require 'awesome_print'

describe V1Jira do
  it "creates a brand new jira ticket" do
    defect = V1Defect.new("D-05106")
    issue = V1Jira.new
    jira_ticket = issue.create_ticket(defect)

    expect(jira_ticket.to_json).to match("MCOMRE")
  end


end
