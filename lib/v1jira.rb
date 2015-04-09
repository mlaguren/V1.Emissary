require './lib/v1defect'
require 'httparty'
require 'nokogiri'
require 'sanitize'
require 'json'

require 'awesome_print'

# The purpose of this class is to perform necessary operation to interact with Jira.  It's main purpose, however,
# is to support the creation of Jira tickets.
class V1Jira 
  include HTTParty
#  debug_output $stdout

  $JIRA = YAML::load(File.open("config/jiraconfig.yml"))
  basic_auth $JIRA['username'], $JIRA['password']
  base_uri $JIRA['base_uri']

  # Instantiates the object.
  #
  # ==== Attributes
  #
  # * +defect+ - A v1defect object
  def initialize(defect)
    @customFieldMap = getAllFieldsMap
    @defect = defect
  end

  # Retrieves all the custom and built-in fields from the VersionOne template.
  #
  # ==== Examples
  #
  # map = getAllFieldsMap
  def getAllFieldsMap
    @customFieldMap = self.class.get("/rest/api/2/field")
  end

  # Creates a mapping hash that has VersionOne API element as Key, and associated Jira API element as value.
  #
  # ==== Return
  #
  # * +mapping+ - Hash with VersionOne API element as Key
  #
  # ==== Examples
  #
  # map = jiraAPIMapping
  def jiraAPIMapping
    mapping = Hash.new
    mp = @customFieldMap
    for i in 0..mp.size-1 do
      mapping[mp[i]['name']] = mp[i]['id']
    end

    return mapping
  end

  # Creates a Jira ticket based on the VersionOne defect.  The defect object is passed in during instantiation of
  # this class.
  #
  # ==== Return
  #
  # * +url+ - URL to the Jira ticket is returned if successful.
  #
  # ==== Examples
  #
  # ticket_url = create_ticket
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
             :customfield_10143 => [{:value => jiraPair['Environment'],}],
             :issuetype => {:name => jiraPair['issuetype']},
             mapping['Functional Group'] => {:value => jiraPair['Functional Group']},
             mapping['Project Manager'] => {:value => jiraPair['Project Manager']},
             :versions => [{:name => "#{jiraPair['Release']}",}],
            },
    }

    response = self.class.post('/rest/api/latest/issue/',
                 :body => payload.to_json,
                 :headers => {'Content-Type' => 'application/json' })

    url = ""
    if response['key']
      url = $JIRA['base_uri'] + "/browse/" + response['key']
      @defect.setJiraLink(url)
    else
      p "Error (#{@defect.get_story}): #{response}"
    end


    return url
  end

  # Deprecated - To be removed.
  def get_ticket
    ticket_details = self.class.get("/rest/api/2/issue/")
    File.open("custom.txt", 'w') {|f| f.write(ticket_details) }
  end

  # Deprecated - To be removed.
  def to_json
    return self.class.to_json
  end
end

