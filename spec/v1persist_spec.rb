require './lib/v1persist.rb'
require 'rspec'

describe V1Persist do

  it "should Insert defects into the database" do
    v1 = V1Persist.new

    p v1.findDefect("D-05106")
    p v1.createDefect("D-12345", "http://jiradev/browse/MCOMRE-00000")
    p v1.updateDefect("D-05108", "testlink")
  end
end