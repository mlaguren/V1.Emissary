require 'httparty'

class V1Jira 
  include HTTParty

  $JIRA = YAML::load(File.open("config/jiraconfig.yml"))
  basic_auth $JIRA['username'], $JIRA['password']
  base_uri $JIRA['base_uri'] 

  def initialize
  
  end

  def create_ticket 

  end

end
