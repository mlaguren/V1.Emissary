require './lib/v1defect'
require 'yaml'

describe V1Defect do

  it "retrieves the details of a story" do
    v1 = V1Defect.new("D-05106")
    response =  v1.get_details
#    update = v1.updateStatus
    p didUpdate = v1.wasItSentToJira
    v1.getJiraList

    Number = response['Assets']['Asset']['Attribute'].map {|h1| h1['__content__'] if h1['name']=="Number"}.compact.first
    expect(Number).to match("D-05106")
#    expect(update).to match(0|1)
    expect(didUpdate).to match(0|1)
  end

end
