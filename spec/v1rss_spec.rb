require './lib/v1rss'
require 'yaml'

describe V1RSS do
  it "connect to an rss feed" do
    test = V1RSS.new           
  end

  it "returns a story" do 
    v1rss = V1RSS.new
    p v1rss.get_story
    expect(v1rss.get_story).to match(/B|D-\d.*/) 
  end
end
