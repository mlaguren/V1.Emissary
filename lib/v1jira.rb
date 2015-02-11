require './lib/v1defect'
require 'httparty'
require 'nokogiri'
require 'json'

require 'awesome_print'

class V1Jira 
  include HTTParty
#  debug_output $stdout

  $JIRA = YAML::load(File.open("config/jiraconfig.yml"))
  basic_auth $JIRA['username'], $JIRA['password']
  base_uri $JIRA['base_uri'] 

  def initialize(defect)
    @DEFAULT = YAML::load(File.open("default/jira.yml"))
    @customFieldMap = getAllFieldsMap
    @defect = defect
  end

  def getAllFieldsMap
    @customFieldMap = self.class.get("/rest/api/2/field")
  end

  def jw_create_ticket(defect)
    jiraPair = defect.getJiraList

    payload = {
        :fields =>
            {:project =>
                 {:key => "#{@DEFAULT['project']}"},
             :summary => "Test Summary",
             :description => "Test Description",
             :customfield_10143 => [
                 {
                     :self => @DEFAULT['environment']['self'],
                     :value => @DEFAULT['environment']['value'],
                     :id => @DEFAULT['environment']['id']
                 }
             ],
             :issuetype => {:name => @DEFAULT['issuetype']['name']},
             :customfield_10181 => {:value => "WDS"},
             :customfield_12614 => {:id => "13634"}
            },
    }
    response = self.class.post("/rest/api/2/issue/",
                               :body => payload.to_json,
                               :headers => {'Content-Type' => 'application/json' })
    return response
  end

  def jiraAPIMapping
    mapping = Hash.new
    mp = @customFieldMap
    for i in 0..mp.size-1 do
      mapping[mp[i]['name']] = mp[i]['id']
    end

    return mapping
  end

  def create_ticket
    jiraPair = @defect.getJiraList

    mapping = jiraAPIMapping
    payload = {
        :fields =>
            {:project =>
                 {:key => "#{@DEFAULT['project']}"},
             :summary => jiraPair['Summary'] + " (#{@defect.get_story})",
             :description => jiraPair['Description'],
             :customfield_10143 => [
                 {
                     :self => @DEFAULT['environment']['self'],
                     :value => @DEFAULT['environment']['value'],
                     :id => @DEFAULT['environment']['id']
                 }
             ],
             :issuetype => {:name => jiraPair['issuetype']},
             mapping['Functional Group'] => {:value => "WDS"},
             mapping['Project Manager'] => {:id => "13634"}
            },
    }

    response = self.class.post('/rest/api/latest/issue/',
                 :body => payload.to_json,
                 :headers => {'Content-Type' => 'application/json' })

    p response

    url = $JIRA['base_uri'] + "/browse/" + response['key']
    return url
  end

  def get_ticket
    ticket_details = self.class.get("/rest/api/2/issue/")
    File.open("custom.txt", 'w') {|f| f.write(ticket_details) }
  end

  def to_json
    return self.class.to_json
  end
end

