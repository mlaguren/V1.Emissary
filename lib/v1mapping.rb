require 'yaml'

class V1Mapping

  def initialize(file)
    $v1mapper = YAML::load(File.open(file))
  end
  
  def display_mappings
    $v1mapper.each_key {|key| puts key}    
  end
  
end

  mapping = V1Mapping.new('config/v1_to_jira.yml')
  mapping.display_mappings
