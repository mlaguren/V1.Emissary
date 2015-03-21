require './lib/v1mapping'
require './lib/v1persist'
require 'httparty'
require 'nokogiri'

# The purpose of this class is to interface with VersionOne.  There is exactly one instant of this class per
# Version one defect, and the class handles all conversion, interpretation, and transformation operations.
# Updating status in VersionOne is also handled by this class.
class V1Defect 
  include HTTParty
  include Nokogiri

  $V1HOST = YAML::load(File.open("config/v1config.yml"))
  basic_auth $V1HOST['username'], $V1HOST['password']
  base_uri $V1HOST['base_url']

  # Initilizes the class.  Also creates a V1Mapping object and V1Persist object that will handle all database
  # persistance and retrival operations.
  #
  # ==== Return
  #
  # * +story+ - VersionOne defect ID
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

  # Retrieves the details of the VersionOne defect.  The information to be returned is constructed based on
  # definition defined in v1mapping configuration file.
  #
  # ==== Return
  #
  # * +details+ - HTTP response from VersionOne, unparsed.
  #
  # ==== Examples
  #
  # details = v1defect.get_details
  def get_details
    theSelection = "sel=Number"    
    @MAP.each do |k, v|
      theSelection << "," << v
    end 
    
    uri="#{$V1HOST['base_uri']}/rest-1.v1/Data/Defect?#{theSelection}&where=Number"
    details = self.class.get("#{uri}=\'#{@story}\'")
    return details
  end

  # Prepares translation of Jira and VersionOne values.  Values starting with
  # "-" is ignored as there is no Jira counterpart.
  #
  # ==== Return
  #
  # * +jiraContent+ - Hash translation where Jira fieldname is key and VersionOne fieldname is value.
  #
  # ==== Examples
  #
  # jc = V1Defect.getJiraList
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

  # Updates JIRAIntStatus flag in VersionOne for *this* defect to "Resolved"
  #
  # ==== Options
  #
  # +Send to JIRA+: Custom_JIRA_Int_Status:64901
  # +Resolved in JIRA+:  Custom_JIRA_Int_Status:64902
  #
  # ==== Return
  #
  # * +Boolean+ - True if Successful, False if unsuccessful
  #
  # ==== Examples
  #
  # updated = V1Defect.updateStatus
  def updateStatus

    storyURI = @details['Assets']['Asset']['href']

    statusXml = '<Asset>
    <Attribute name="Custom_JIRAIntStatus" act="set">Custom_JIRA_Int_Status:64902</Attribute>
    </Asset>'

    r_status = self.class.post("#{storyURI}", :body => statusXml,
                             :headers => {"content_type" => "application/xml"})

    unless (r_status['Error'])
      @persist.updateDefectStatus(@story)
      return 1
    end
    return 0
  end

  # Populates the "Link" field in VersionOne with the URL of Jira ticket
  #
  # ==== Attributes
  #
  # * +link+ - URL to Jira ticket
  #
  # ==== Return
  #
  # * +Boolean+ - True if Successful, False if unsuccessful
  #
  # ==== Examples
  #
  # updated = V1Defect.setJiraLink
  def setJiraLink(link)
    @JiraLink = link
    linkURL = "#{$V1HOST['base_uri']}/rest-1.v1/Data/Link"

    storyURI = @details['Assets']['Asset']['href']
    return 0 unless storyURI.length > 0

    idRef = storyURI.split('/').last

    linkXml = '<Asset>
	<Relation name="Asset" act="set">
	    <Asset idref="Defect:' + idRef + '" />
	</Relation>
	<Attribute name="Name" act="set">JIRA Link</Attribute>
  <Attribute name="OnMenu" act="set">True</Attribute>
	<Attribute name="URL" act="set">' + @JiraLink + '</Attribute>
</Asset>'

    return 0 unless @JiraLink.length > 0
    r_link = self.class.post("#{linkURL}", :body => linkXml,
                               :headers => {"content_type" => "application/xml"})
    unless (r_link['Error'])
      return 1
    end

    return 0
  end

  # Returns the VersionOne defect ID this instance represents.
  #
  # ==== Return
  #
  # * +story+ - Defect ID
  #
  # ==== Examples
  #
  # defect_id = V1Defect.get_story
  def get_story
    return @story
  end

  # Adds the Jira ticket URL to database for defect this instance represents.
  #
  # ==== Attributes
  #
  # * +url+ - URL of Jira ticket
  #
  # ==== Examples
  #
  # V1Defect.addUrl("http://jira/browse/STORY-1234")
  def addUrl(url)
    @persist.updateDefect(@story, url)
  end

  # Checks to see if Jira ticket exists (was created) for this defect.  It does this via the database,
  # NOT via probing Jira or VersionOne.
  #
  # ==== Return
  #
  # * +Boolean+ - True if Ticket Exists, False if not
  #
  # ==== Examples
  #
  # existance = V1Defect.doesJiraLinkExist
  def doesJiraLinkExist
    return @persist.findDefect(@story)[1]
  end

  # Checks to see if defect is set to "Send to JIRA"
  #
  # ==== Return
  #
  # * +Boolean+ - True if Successful, False if unsuccessful
  #
  # ==== Examples
  #
  # sent = V1Defect.wasItSentToJira
  def wasItSentToJira
    if @doc.xpath('//Attribute[@name="Custom_JIRAIntStatus.Name"]').text == "Send to JIRA"
      return 1
    end

    return 0
  end
end