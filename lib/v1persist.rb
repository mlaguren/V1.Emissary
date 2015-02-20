require 'sqlite3'
require 'yaml'

class V1Persist
  include SQLite3

  $V1HOST = YAML::load(File.open("config/v1config.yml"))

  def initialize
    #CREATE TABLE v1link(defect varchar(10), jira_link varchar(200), status);
    #create unique index idx_defect on v1link(defect)
    @db = SQLite3::Database.new $V1HOST['dbname']
#    @findDefect = @db.prepare("select * from v1link where defect=?")
#    @insertDefect = @db.prepare("insert into v1link (defect) values (?)")
  end

  def findDefect(defect)
    return @db.execute("select * from v1link where defect=\"#{defect}\"")
  end

  def getJiraLinkByDefect(defect)
    return @db.execute("select jiralink from v1link where defect=\"#{defect}\"")
  end

  def createDefect(defect, jiralink)
    begin
      return @db.execute("insert into v1link (defect, jira_link) values (\"#{defect}\", \"#{jiralink}\")")
    rescue SQLite3::Exception => e
      print "Exception (v1persist): #{e}"
    end
  end

  def updateDefect(defect, jiralink)
    begin
      return @db.execute("update v1link set jira_link=\"#{jiralink}\" where defect = \"#{defect}\"")
    rescue SQLite3::Exception => e
      print "Exception (v1persist): #{e}"
    end
  end

  def updateDefectStatus(defect)
    begin
      return @db.execute("update v1link set status=\"Y\" where defect = \"#{defect}\"")
    rescue SQLite3::Exception => e
      print "Exception (v1persist): #{e}"
    end
  end

end