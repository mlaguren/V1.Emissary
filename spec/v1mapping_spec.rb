require './lib/v1mapping'
require 'yaml'
require 'json'


describe V1Mapping do

  it "loads a yaml mapping file" do
    Map = YAML::load(File.open("config/mappings.yml"))
    sMap = YAML::load(File.open("config/static_mappings.yml"))
    mappings = V1Mapping.new('config/mappings.yml', 'config/static_mappings.yml')
    expect(mappings.get_Map).to match(Map)
    expect(mappings.get_sMap).to match(sMap)
    expect(mappings.j2v("Root Cause Analysis")).to match("Resolution")
    expect(mappings.v2j("Resolution")).to match("Root Cause Analysis")
  end

end
