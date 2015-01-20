require 'rss'
require 'open-uri'

url = 'https://www12.v1host.com/MacysIncIPWSandbox/notification.v1?feed=ATOM&ticket=HFZlcnNpb25PbmUuV2ViLkF1dGhlbnRpY2F0b3JyIQAACG1sYWd1cmVutg4IKPwB0gj%2fPzf0dSjKKxCYPfha6qBBBdmN7MGv5XM4'
open(url) do |rss|
  feed = RSS::Parser.parse(rss)
  title = feed.entry.title
  puts title
  puts title.to_s[/'*\(((B|D)-\d.*)\)/]
end
