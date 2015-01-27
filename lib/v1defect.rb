require 'httparty'

class V1Defect 
  include HTTParty

  $V1HOST = YAML::load(File.open("config/v1config.yml"))
  basic_auth $V1HOST['username'], $V1HOST['password']
  base_uri $V1HOST['base_uri'] 

  def initialize
  
  end

  def get_details(story)
    details = self.class.get("/MacysIncIPWSandbox/rest-1.v1/Data/Defect?where=Number='D-04942'") 
    return details
  end
end
