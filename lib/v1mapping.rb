require 'yaml'

# This class manages all mapping operations for mapping/translation of VersionOne and Jira fields.
class V1Mapping

  # Populates the "Link" field in VersionOne with the URL of Jira ticket
  #
  # ==== Attributes
  #
  # * +file1+ - Mapping file between VersionOne and Jira fileds
  # * +file2+ - Static Mapping file.  Fields that needs to be hard-coded for Jira due to required field status.
  def initialize(file1, file2)
    @v1mapper = YAML::load(File.open(file1))
    @v1smapper = YAML::load(File.open(file2))
    @rsmapper = @v1smapper.invert
    @rmapper = @v1mapper.invert
  end

  # Converts map data to JSON presentation.
  #
  # ==== Return
  #
  # * +json+ - JSON string
  #
  # ==== Examples
  #
  # p V1Mapping.to_json
  def to_json
    return @v1mapper.to_json
  end

  # Returns dynamic mapping.
  #
  # ==== Return
  #
  # * +map+ - Dynamic mapping data from file as hash.
  #
  # ==== Examples
  #
  # m = V1Mapping.get_Map
  def get_Map
    return @v1mapper
  end

  # Returns static mapping
  #
  # ==== Return
  #
  # * +smap+ - Static mapping data from file as hash
  #
  # ==== Examples
  #
  # sm = V1Mapping.get_sMap
  def get_sMap
    return @v1smapper
  end

  # Returns the VersionOne fieldname from the provided Jira fieldname.
  #
  # ==== Attributes
  #
  # * +field+ - Jira field name
  #
  # ==== Return
  #
  # * +V1field+ - VersionOne field name
  #
  # ==== Examples
  #
  # v1field = V1Mapping.j2v("Project")
  def j2v(field)
    return @v1mapper[field]
  end

  # Returns the Jira fieldname from the provided VersionOne fieldname
  #
  # ==== Attributes
  #
  # * +field+ - VersionOne field name
  #
  # ==== Return
  #
  # * +jira_field+ - Jira field name
  #
  # ==== Examples
  #
  # jira_field = V1Mapping.v2j("Parent.Name")
  def v2j(field)
    return @rmapper[field]
  end
    
end

