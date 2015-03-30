require 'httparty'
require 'nokogiri'
require 'sqlite3'

# This class identifies defects that needs to be duplicated to Jira.  This class also tracts state of those tickets.
class V1Trigger
  include HTTParty
  include Nokogiri
  include SQLite3

  $V1HOST = YAML::load(File.open("config/v1config.yml"))
  $JIRA = YAML::load(File.open("config/jiraconfig.yml"))
  basic_auth $V1HOST['username'], $V1HOST['password']
  base_uri $V1HOST['base_url']

  def initialize
    #CREATE TABLE v1link(defect varchar(10), jira_link varchar(200), status varchar(2));
    @db = SQLite3::Database.new $V1HOST['dbname']
    @findDefect = @db.prepare("select * from v1link where defect=?")
    @insertDefect = @db.prepare("insert into v1link (defect) values (?)")

    @TRIGGER_STATUS = 'Complete'
  end

  # Gets a list of tickets in Jira that are in completed state.  These tickets are ready to be closed in VersionOne.
  #
  # ==== Return
  #
  # * +list+ - List of Jira tickets that are not closed in VersionOne.
  #
  # ==== Examples
  #
  # list = V1Trigger.get_Jira_list
  def get_Jira_list
    l = Array.new

    @db.execute("select jira_link from v1link where jira_link is not null and status is null").each do |row|
        row.each do |issue|
          auth = {:username => $JIRA['username'], :password => $JIRA['password']}
          doc = HTTParty.get('http://jiradev/rest/api/2/issue/' + issue.split('/').last + '?fields=status',
            :basic_auth => auth)

          l << issue if doc['fields']['status']['name'] == @TRIGGER_STATUS
        end
    end

    return l
  end

  # Gets a list of tickets in Jira that are in completed state.  These tickets are ready to be closed in VersionOne.
  #
  # ==== Return
  #
  # * +list+ - List of Jira tickets that are not closed in VersionOne.
  #
  # ==== Examples
  #
  # list = V1Trigger.get_v1defect_Jira_list
  def get_v1defect_Jira_list
    l = Array.new

    @db.execute("select jira_link from v1link where jira_link is not null and status is null").each do |row|
      row.each do |issue|
        auth = {:username => $JIRA['username'], :password => $JIRA['password']}
        doc = HTTParty.get('http://jiradev/rest/api/2/issue/' + issue.split('/').last + '?fields=status',
                           :basic_auth => auth)
        i = @db.execute('select defect from v1link where jira_link = "' + issue + '"')
        l.push(i[0][0]) if doc['fields']['status']['name'] == @TRIGGER_STATUS
      end
    end

    return l
  end

  # Returns a list of defects in VersionOne that have "Send to JIRA" flag set.  Tickets in this state
  # Needs an associated Jira ticket created.  The method will also create an entry of the defect in the database so
  # its state can be tracked.
  #
  # ==== Return
  #
  # * +list+ - List of defects that needs to have Jira tickets created.
  #
  # ==== Examples
  #
  # list = V1Trigger.get_v1_list
  def get_v1_list
    theSelectionURi="sel=Number&where=Custom_JIRAIntStatus.Name='Send to JIRA'"
    uri=URI.encode("#{$V1HOST['base_uri']}/rest-1.v1/Data/Defect?#{theSelectionURi}")
    updateList = self.class.get("#{uri}", :verify => false)

    list = Array.new
    doc = Nokogiri::XML(updateList.body)
    doc.xpath('/Assets/Asset/Attribute/text()').each do |v|
      defect = v.to_s
#      dbDefect = @db.execute("select defect from v1link where defect=\"#{defect}\" and status is null and jira_link is null")
      dbDefect = @db.execute("select defect, jira_link, status from v1link where defect=\"#{defect}\"")
      unless dbDefect[0] || dbDefect[2] == 'Y'
        #TODO: This following delete is horrible, need to implement an error queue, risk of backing up with same failure constantly
        #@db.execute("delete from v1link where defect = \"#{defect\""}) unless dbDefect[0][1]
        begin
          @db.execute("insert into v1link (defect) values (\"#{defect}\")")
        rescue SQLite3::Exception => e
          p "get_v1_list: #{e}"
        else
          list << defect
        end
      end
    end

    return list
  end

end