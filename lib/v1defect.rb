require 'httparty'

class V1Defect 
  include HTTParty

  $V1HOST = YAML::load(File.open("config/v1config.yml"))
  basic_auth $V1HOST['username'], $V1HOST['password']
  base_uri $V1HOST['base_uri'] 

  def initialize
  
  end

  def get_details
    test = self.class.get("/MacysIncIPWSandbox/rest-1.v1/Data/Defect?where=Number='D-04942'") 
    return test
  end
end

#  Convert to rspec test 
#  v1 = V1Defect.new
#  response =  v1.get_details
#  details = response.to_json
#  puts details
