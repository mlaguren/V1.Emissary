require './lib/v1defect'
require './lib/v1jira'
require './lib/v1trigger'
require 'yaml'
require 'httparty'

  # Check if the rss file is configured
  if File.file?('./config/v1config.yml')
    v1 = V1Trigger.new
    list = v1.get_v1_list
    list.each do |story|
      p "Creating JIRA ticket for V1 defect #{story}"

      d = V1Defect.new(story)
      url = V1Jira.new(d).create_ticket
      d.addUrl(url) if url.length > 0
    end

    jlist = v1.get_v1defect_Jira_list
    jlist.each do |issue|
      p "Closing JIRA issue #{issue}"

      dd = V1Defect.new(issue)
      dd.updateStatus
    end
  end
