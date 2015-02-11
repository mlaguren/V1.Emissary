require 'httparty'
require 'nokogiri'
require 'sqlite3'

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
  end

  def get_Jira_list
    l = Array.new

    @db.execute("select jira_link from v1link where jira_link is not null and status is null").each do |row|
        row.each do |issue|
          auth = {:username => $JIRA['username'], :password => $JIRA['password']}
          doc = HTTParty.get('http://jiradev/rest/api/2/issue/' + issue.split('/').last + '?fields=status',
            :basic_auth => auth)

          l << issue if doc['fields']['status']['name'] == "Closed"
        end
    end

    return l
  end

  def get_v1defect_Jira_list
    l = Array.new

    @db.execute("select jira_link from v1link where jira_link is not null and status is null").each do |row|
      row.each do |issue|
        auth = {:username => $JIRA['username'], :password => $JIRA['password']}
        doc = HTTParty.get('http://jiradev/rest/api/2/issue/' + issue.split('/').last + '?fields=status',
                           :basic_auth => auth)
        i = @db.execute('select defect from v1link where jira_link = "' + issue + '"')
        l.push(i[0][0]) if doc['fields']['status']['name'] == "Closed"
      end
    end

    return l
  end

  def get_v1_list
    theSelectionURi="sel=Number&where=Custom_JIRAIntStatus.Name='Send to JIRA'"
    uri=URI.encode("#{$V1HOST['base_uri']}/rest-1.v1/Data/Defect?#{theSelectionURi}")
    updateList = self.class.get("#{uri}")

    list = Array.new
    doc = Nokogiri::XML(updateList.body)
    doc.xpath('/Assets/Asset/Attribute/text()').each do |v|
      defect = v.to_s
#      dbDefect = @db.execute("select defect from v1link where defect=\"#{defect}\" and status is null and jira_link is null")
#      dbDefect = @db.execute("select defect, jira_link, status from v1link where defect=\"#{defect}\"")
      dbDefect = @db.execute("select defect from v1link where defect=\"#{defect}\"")
#      if !dbDefect[0] || (dbDefect[0] && !dbDefect[1]) || (dbDefect[0] && !dbDefect[2] == 'Y')
#
      unless dbDefect[0]
        @db.execute("insert into v1link (defect) values (\"#{defect}\")")
        list << defect
      end
    end

    return list
  end

end