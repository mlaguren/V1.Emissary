require 'rss'
require 'open-uri'

class V1RSS
  include RSS

  def initialize
    #   get rss feed url from config file

    $CREDS = YAML::load(File.open("config/v1config.yml"))
    $FEED = YAML::load(File.open("config/rss.yml"))

  end

  def get_story
    open($FEED['rss'], :http_basic_authentication=>[user="#{$CREDS['username']}", password="#{$CREDS['password']}"]) do |rss|
      feed = RSS::Parser.parse(rss)
      title = "#{feed.entry.title}"
      return title.to_s[/'*\(((B|D)-\d.*)\)/].delete('()')
    end
  end 

end
