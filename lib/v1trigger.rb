require 'httparty'
require 'nokogiri'
require 'sqlite3'

class V1Trigger
  include HTTParty
  include Nokogiri
  include SQLite3

  $V1HOST = YAML::load(File.open("config/v1config.yml"))
  basic_auth $V1HOST['username'], $V1HOST['password']
  base_uri $V1HOST['base_url']

  def initialize
    @db = SQLite3::Database.new "v1link.db"
    @findDefect = @db.prepare("select * from v1link where defect=?")
    @insertDefect = @db.prepare("insert into v1link (defect) values (?)")
  end

  def get_list
    theSelectionURi="sel=Number&where=Custom_JIRAIntStatus.Name='Send to JIRA'"
    uri=URI.encode("#{$V1HOST['base_uri']}/rest-1.v1/Data/Defect?#{theSelectionURi}")
    updateList = self.class.get("#{uri}")

    list = Array.new
    doc = Nokogiri::XML(updateList.body)
    doc.xpath('/Assets/Asset/Attribute/text()').each do |v|
      defect = v.to_s

      dbDefect = @db.execute("select * from v1link where defect=\"#{defect}\"")
#      dbDefect = @findDefect.execute(defect)
      unless dbDefect.size > 0
        @db.execute("insert into v1link (defect) values (\"#{defect}\")")
#        @insertDefect.execute(defect)
        list << defect
      end
    end

    return list
  end

end