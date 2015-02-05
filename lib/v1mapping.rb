require 'yaml'

class V1Mapping

  def initialize(file1, file2)
    $v1mapper = YAML::load(File.open(file1))
    $v1sMapper = YAML::load(File.open(file2))
    $rsmapper = $v1sMapper.invert
    $rmapper = $v1mapper.invert
  end

  def to_json
    return $v1mapper.to_json
  end
  
  def get_Map
    return $v1mapper
  end

  def get_sMap
    return $v1sMapper
  end
  
  def j2v(field)
    return $v1mapper[field]
  end
  
  def v2j(field)
    return $rmapper[field]
  end
    
end

