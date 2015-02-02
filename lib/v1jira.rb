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
    $DEFAULT = YAML::load(File.open("default/jira.yml")) 
  end

  def create_ticket
    payload = {
                :fields => 
                  {:project => 
                    {:key => "#{$DEFAULT['project']}"}, 
                     :summary => "Test Summary", 
                     :description => "Test Description", 
                     :customfield_10143 => [
                        {
                          :self => $DEFAULT['environment']['self'],
                          :value => $DEFAULT['environment']['value'],
                          :id => $DEFAULT['environment']['id']  
                        }
                     ],
                     :issuetype => {:name => $DEFAULT['issuetype']['name']},
                     :customfield_10181 => {:value => "WDS"}, 
                     :customfield_12614 => {:id => "13634"}
                   },
                }
    response = self.class.post("/rest/api/2/issue/", 
                 :body => payload.to_json, 
                 :headers => {'Content-Type' => 'application/json' }) 
    return response
  end

  def get_ticket
    ticket_details = self.class.get("/rest/api/2/issue/MCOMRE-46970")
    File.open("custom.txt", 'w') {|f| f.write(ticket_details) }
  end

  def to_json
    return self.class.to_json
  end
end

