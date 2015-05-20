require './lib/v1defect'
require './lib/v1jira'
require './lib/v1trigger'
require './lib/v1mapping'
require 'yaml'
require 'httparty'

  p Time.new.inspect

# Check if the rss file is configured
  if File.file?('./config/v1config.yml')
    v1 = V1Trigger.new
    v1m = V1Mapping.new('config/mappings.yml', 'config/static_mappings.yml')
    list = v1.get_v1_list
    list.each do |story|
      p "Creating JIRA ticket for V1 defect #{story}"

      d = V1Defect.new(story, v1m)
      url = V1Jira.new(d).create_ticket
      d.addUrl(url) if url.length > 0
    end

    jlist = v1.get_v1defect_Jira_list
    jlist.each do |issue|
      p "Closing JIRA issue #{issue}"

      dd = V1Defect.new(issue, v1m)
      dd.updateStatus
      if dd.updateStatus == 0
        p "Error closing issue #{issue}"
      end
    end
  end
