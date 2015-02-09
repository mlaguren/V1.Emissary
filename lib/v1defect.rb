require './lib/v1mapping'
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
    @MAP = @mapping.get_Map
    @sMAP = @mapping.get_sMap
    @story = story
    @details = get_details
    @doc = Nokogiri::XML(@details.body)
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

  def jiraMap
    jiraContent = Hash.new
    @MAP.each do |k, v|
      next if k.start_with?('-')
      content = @doc.xpath('//Attribute[@name="' + v + '"]').text

      jiraContent[k] << "," if jiraContent.has_key?(k)
      jiraContent[k] = content
    end

    @sMAP.each do |k, v|
      jiraContent[k] << "," if jiraContent.has_key?(k)
      jiraContent[k] = v
    end

    return jiraContent
  end

  def updateStatus
    # Send to JIRA: Custom_JIRA_Int_Status:64901
    # Resolved in JIRA:  Custom_JIRA_Int_Status:64902
    
    storyURI = @details['Assets']['Asset']['href']
    xml = '<Asset>
    <Attribute name="Custom_JIRAIntStatus" act="set">Custom_JIRA_Int_Status:64902</Attribute>
    </Asset>'

    result = self.class.post("#{storyURI}", :body => xml,
                             :headers => {"content_type" => "application/xml"})

    return 0 if result['Error']
    return 1
  end

  def wasItSentToJira
    if @doc.xpath('//Attribute[@name="Custom_JIRAIntStatus.Name"]').text == "Send to JIRA"
      return 1
    end

    return 0
  end
end