require './lib/v1trigger'
require 'yaml'

describe V1Trigger do

  it "retrieves the list of stories with JIRA flag set" do
    v1 = V1Trigger.new
    response =  v1.get_list
    p response

#    Number = response['Assets']['Asset']['Attribute'].map {|h1| h1['__content__'] if h1['name']=="Number"}.compact.first
#    expect(Number).to match("D-05106")
  end

end
