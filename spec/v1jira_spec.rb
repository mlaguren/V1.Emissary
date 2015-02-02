require './lib/v1jira'
require 'yaml'
require 'awesome_print'

describe V1Jira do

  it "creates a brand new jira ticket" do
    issue = V1Jira.new
    jira_ticket = issue.create_ticket
    expect(jira_ticket.to_json).to match("MCOMRE") 
  end


end
