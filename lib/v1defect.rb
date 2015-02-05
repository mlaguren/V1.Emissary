require 'v1mapping'
require 'httparty'

class V1Defect 
  include HTTParty

  $V1HOST = YAML::load(File.open("config/v1config.yml"))
  basic_auth $V1HOST['username'], $V1HOST['password']
  base_uri $V1HOST['base_uri'] 

  def initialize
    $MAP = V1Mapping.new('config/mappings.yml').get_Map
  end

  def get_details(story)

    theSelection = "sel=Number"    
    $MAP.each do |k, v|
    theSelection << "," << v
    end 
    
    print theSelection + "\n"
    uri="/rest-1.v1/Data/Defect?#{theSelection}&where=Number"
    details = self.class.get("#{uri}=\'#{story}\'")

print "Get -  #{$V1HOST['base_uri']}/#{uri}=\'#{story}\'\n\n"
    print details
    
    return details
  end
end