require './lib/v1mapping'
require 'yaml'
require 'json'


describe V1Mapping do

  it "loads a yaml mapping file" do
    json = YAML::load(File.open("config/mappings.yml"))  
    mappings = V1Mapping.new('config/mappings.yml')    
    expect(mappings.to_json).to match(json.to_json)
    expect(mappings.j2v("Summary")).to match("Name")
    expect(mappings.j2v("Root Cause Analysis")).to match("Resolution")
    expect(mappings.v2j("Resolution")).to match("Root Cause Analysis")
  end

end
