require './lib/v1mapping'
require 'httparty'

class V1Defect 
  include HTTParty

  $V1HOST = YAML::load(File.open("config/v1config.yml"))
  basic_auth $V1HOST['username'], $V1HOST['password']
  base_uri $V1HOST['base_url'] 

  def initialize
    $MAP = V1Mapping.new('config/mappings.yml', 'config/static_mappings.yml').get_Map
  end

  def get_details(story)

    theSelection = "sel=Number"    
    $MAP.each do |k, v|
      theSelection << "," << v
    end 
    
    uri="#{$V1HOST['base_uri']}/rest-1.v1/Data/Defect?#{theSelection}&where=Number"
    details = self.class.get("#{uri}=\'#{story}\'")    
    return details
  end
  
  def updateStatus(story)
    ret = get_details(story)

    # Send to JIRA: Custom_JIRA_Int_Status:64901
    # Resolved in JIRA:  Custom_JIRA_Int_Status:64902
    
    storyURI = ret['Assets']['Asset']['href']
    xml = '<Asset>
    <Attribute name="Custom_JIRAIntStatus" act="set">Custom_JIRA_Int_Status:64902</Attribute>
    </Asset>'

    result = self.class.post("#{storyURI}", :body => xml,
                             :headers => {"content_type" => "application/xml"})

    return 0 if result['Error']
    return 1
  end

  def wasItSentToJira(story)
    ret = get_details(story)

    list = ret['Assets']['Asset']['Attribute']
    list.each do |pair|
      if pair['name'] == "Custom_JIRAIntStatus.Name" then
        if pair['__content__'] == "Send to JIRA"
          return 1
        end
      end
    end

    return 0
  end
end