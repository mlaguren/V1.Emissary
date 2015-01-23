require 'rss'
require 'open-uri'

class V1RSS
  include RSS

  def initialize
    #   get rss feed url from config file
    
    $FEED = YAML::load(File.open("config/v1_rss.yaml"))
  end

  def get_story
    open($FEED['rss']) do |rss|
      feed = RSS::Parser.parse(rss)
      title = feed.entry.title
    end
    return title.to_s[/'*\(((B|D)-\d.*)\)/]
  end 

end
