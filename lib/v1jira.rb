require './lib/v1defect'
require 'httparty'
require 'nokogiri'
require 'sanitize'
require 'json'

require 'awesome_print'

class V1Jira 
  include HTTParty
#  debug_output $stdout

  $JIRA = YAML::load(File.open("config/jiraconfig.yml"))
  basic_auth $JIRA['username'], $JIRA['password']
  base_uri $JIRA['base_uri'] 

  def initialize(defect)
    @customFieldMap = getAllFieldsMap
    @defect = defect
  end

  def getAllFieldsMap
    @customFieldMap = self.class.get("/rest/api/2/field")
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
                 {:key => "#{jiraPair['Project']}"},
             :summary => jiraPair['Summary'] + " (#{@defect.get_story})",
             :description => Sanitize.clean(jiraPair['Description']),
             mapping['Release Milestone'] => {:value => jiraPair['Release Milestone']},
             :customfield_10143 => [
                 {
                     :value => jiraPair['Environment'],
                 }
             ],
             :issuetype => {:name => jiraPair['issuetype']},
             mapping['Functional Group'] => {:value => jiraPair['Functional Group']},
             mapping['Project Manager'] => {:value => jiraPair['Project Manager']},
             :versions => [
                 {
                     :name => "#{jiraPair['Release']}",
                 }
             ],
            },
    }

    response = self.class.post('/rest/api/latest/issue/',
                 :body => payload.to_json,
                 :headers => {'Content-Type' => 'application/json' })

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

