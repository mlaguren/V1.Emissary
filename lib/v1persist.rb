require 'sqlite3'
require 'yaml'

# This class is meant to handle all data access needs.  It should become a generic class that handles all data access,
# at the moment, it's only used for database access, however.
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

  # Finds a defect in the database and returns the jira link and its state.
  #
  # ==== Attributes
  #
  # * +defect+ - defect ID to find
  #
  # ==== Return
  #
  # * Array with defect id, jira link, and status.
  #
  # ==== Examples
  #
  # defect = V1Persist.findDefect("D-12345")
  def findDefect(defect)
    return @db.execute("select * from v1link where defect=\"#{defect}\"")
  end

  # Get the URL to the Jira ticket for VersionOne defect.
  #
  # ==== Attributes
  #
  # * +defect+ - defect ID in VersionOne
  #
  # ==== Return
  #
  # * URL of Jira Ticket for the VersionOne ticket.
  #
  # ==== Examples
  #
  # url = V1Persist.getJiraLinkByDefect("D-12345")
  def getJiraLinkByDefect(defect)
    return @db.execute("select jiralink from v1link where defect=\"#{defect}\"")
  end

  # Inserts defect into database
  #
  # ==== Attributes
  #
  # * +defect+ - VersionOne defect ID
  # * +jiralink+ - URL to Jira ticket
  #
  # ==== Examples
  #
  # V1Persist.createDefect("D-12345", "http://jira/browse/STORY-1234")
  def createDefect(defect, jiralink)
    begin
      return @db.execute("insert into v1link (defect, jira_link) values (\"#{defect}\", \"#{jiralink}\")")
    rescue SQLite3::Exception => e
      print "Exception (v1persist): #{e}"
    end
  end

  # Updates a defect in the database
  #
  # ==== Attributes
  #
  # * +defect+ - VersionOne defect ID
  # * +jiralink+ - URL to Jira ticket
  #
  # ==== Examples
  #
  # V1Persist.updateDefect("D-12345", "http://jira/browse/STORY-1234")
  def updateDefect(defect, jiralink)
    begin
      return @db.execute("update v1link set jira_link=\"#{jiralink}\" where defect = \"#{defect}\"")
    rescue SQLite3::Exception => e
      print "Exception (v1persist): #{e}"
    end
  end

  # Updates a defect in the database when it errors out
  #
  # ==== Attributes
  #
  # * +defect+ - VersionOne defect ID
  # * +err+ - Error returned from creating Jira ticket
  #
  # ==== Examples
  #
  # V1Persist.updateDefectError("D-12345", "Error: Invalid field data")
  def updateDefectError(defect, err)
    begin
      ins = @db.prepare('update v1link set errormsg = (?) where defect = (?)')
      return ins.execute(err, defect)
    rescue SQLite3::Exception => e
      print "Exception (v1persist): #{e}"
    end
  end

  # Updates the status of the defect to complete.
  #
  # ==== Attributes
  #
  # * +defect+ - defect ID in VersionOne
  #
  # ==== Examples
  #
  # V1Persist.updateDefectStatus("D-12345")
  def updateDefectStatus(defect)
    begin
      return @db.execute("update v1link set status=\"Y\" where defect = \"#{defect}\"")
    rescue SQLite3::Exception => e
      print "Exception (v1persist): #{e}"
    end
  end

end