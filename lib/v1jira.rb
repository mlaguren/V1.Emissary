require 'httparty'
require 'json'

require 'awesome_print'

class V1Jira 
  include HTTParty
  debug_output $stdout

  $JIRA = YAML::load(File.open("config/jiraconfig.yml"))
  basic_auth $JIRA['username'], $JIRA['password']
  base_uri $JIRA['base_uri'] 

  def initialize
  
  end

  def create_ticket
    payload = {:fields => {:project => {:key => "MCOMRE"}, :summary => "Test Summary", :description => "Test Description", :issuetype => {:name =>"Bug"}}}
    puts payload.class
    puts payload.to_json.class
    response = self.class.post("/rest/api/2/issue/", 
                 :body => payload.to_json, 
                 :options => { :headers => {'Content-Type' => 'application/json' } }) 
    return response
  end

  def get_ticket
    ticket_details = self.class.get("/rest/api/2/issue/MCOMRE-48098")
    ap ticket_details
  end

end

jira = V1Jira.new
test = jira.create_ticket
ap test
