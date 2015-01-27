require './lib/v1mapping'
require 'yaml'
require 'json'


describe V1Defect do

  it "loads a yaml file" do
  
    json = '{"Name":"Title","Description":"Description","VersionAffected":"VersionAffected"}'
    data = JSON.parse(json)
    open('test.yml', 'w') { |f| YAML::dump(data, f)}
   
    mappings = V1Mapping.new('test.yml')
    expect(mappings.to_json).to match(json)
  end

end
