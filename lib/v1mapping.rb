require 'yaml'

class V1Mapping

  def initialize(file)
    $v1mapper = YAML::load(File.open(file))
  end

  def to_json
    return $v1mapper.to_json
  end
  
end

