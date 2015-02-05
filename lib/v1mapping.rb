require 'yaml'

class V1Mapping

  def initialize(file)
    $v1mapper = YAML::load(File.open(file))
    $rmapper = $v1mapper.invert
  end

  def to_json
    return $v1mapper.to_json
  end
  
  def get_Map
    return $v1mapper
  end
  
  def j2v(field)
    return $v1mapper[field]
  end
  
  def v2j(field)
    return $rmapper[field]
  end
    
end

