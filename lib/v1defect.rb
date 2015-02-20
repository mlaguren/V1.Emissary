require './lib/v1mapping'
require './lib/v1persist'
require 'httparty'
require 'nokogiri'

class V1Defect 
  include HTTParty
  include Nokogiri

  $V1HOST = YAML::load(File.open("config/v1config.yml"))
  basic_auth $V1HOST['username'], $V1HOST['password']
  base_uri $V1HOST['base_url'] 

  def initialize(story)
    @mapping = V1Mapping.new('config/mappings.yml', 'config/static_mappings.yml')
    @persist = V1Persist.new
    @MAP = @mapping.get_Map
    @sMAP = @mapping.get_sMap
    @story = story
    @details = get_details
    @doc = Nokogiri::XML(@details.body)
    @JiraLink = ''
  end

  def get_details
    theSelection = "sel=Number"    
    @MAP.each do |k, v|
      theSelection << "," << v
    end 
    
    uri="#{$V1HOST['base_uri']}/rest-1.v1/Data/Defect?#{theSelection}&where=Number"
    details = self.class.get("#{uri}=\'#{@story}\'")
    return details
  end

  def getJiraList
    jiraContent = Hash.new
    @MAP.each do |k, v|
      next if k.start_with?('-')
      content = @doc.xpath('//Attribute[@name="' + v + '"]').text

      jiraContent[k] << "," if jiraContent.has_key?(k)
      jiraContent[k] = content
    end

    @sMAP.each do |k, v|
#      jiraContent[k] << "," if jiraContent.has_key?(k)
      if jiraContent.has_key?(k) && jiraContent[k].length > 0
          next
      else
        jiraContent[k] = v
      end
    end

    return jiraContent
  end

  def updateStatus
    # Send to JIRA: Custom_JIRA_Int_Status:64901
    # Resolved in JIRA:  Custom_JIRA_Int_Status:64902
    
    storyURI = @details['Assets']['Asset']['href']
    linkURL = "#{$V1HOST['base_uri']}/rest-1.v1/Data/Link"
    idRef = storyURI.split('/').last

    statusXml = '<Asset>
    <Attribute name="Custom_JIRAIntStatus" act="set">Custom_JIRA_Int_Status:64902</Attribute>
    </Asset>'

    linkXml = '<Asset>
	<Relation name="Asset" act="set">
	    <Asset idref="Defect:' + idRef + '" />
	</Relation>
	<Attribute name="Name" act="set">JIRA Link</Attribute>
  <Attribute name="OnMenu" act="set">True</Attribute>
	<Attribute name="URL" act="set">' + @JiraLink + '</Attribute>
</Asset>'

    r_status = self.class.post("#{storyURI}", :body => statusXml,
                             :headers => {"content_type" => "application/xml"})

    r_link = self.class.post("#{linkURL}", :body => linkXml,
                             :headers => {"content_type" => "application/xml"})

    # If link fails to update, it's still ok
    unless (r_status['Error'])
      @persist.updateDefectStatus(@story)
      return 1
    end
    return 0
  end

  def setJiraLink(link)
    @JiraLink = link
  end

  def get_story
    return @story
  end

  def addUrl(url)
    @persist.updateDefect(@story, url)
  end

  def doesJiraLinkExist
    return @persist.findDefect(@story)[1]
  end

  def wasItSentToJira
    if @doc.xpath('//Attribute[@name="Custom_JIRAIntStatus.Name"]').text == "Send to JIRA"
      return 1
    end

    return 0
  end
end