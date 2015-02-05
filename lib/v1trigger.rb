require 'httparty'
require 'sqlite3'

class V1Trigger
  include HTTParty
  include SQLite3

  $V1HOST = YAML::load(File.open("config/v1config.yml"))
  basic_auth $V1HOST['username'], $V1HOST['password']
  base_uri $V1HOST['base_url']

  def initialize
  end

  def get_list
    theSelectionURi="sel=Number&where=Custom_JIRAIntStatus.Name='Send to JIRA'"
    uri=URI.encode("#{$V1HOST['base_uri']}/rest-1.v1/Data/Defect?#{theSelectionURi}")
    updateList = self.class.get("#{uri}")

    list = Array.new
    updateList['Assets']['Asset'].each do |pair|
      list.push pair['Attribute']['__content__']
    end

    return list
  end

end