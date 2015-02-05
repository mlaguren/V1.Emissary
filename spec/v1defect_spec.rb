require './lib/v1defect'
require 'yaml'

describe V1Defect do

  it "retrieves the details of a story" do
    v1 = V1Defect.new
    response =  v1.get_details "D-05106"
    Number = response['Assets']['Asset']['Attribute'].map {|h1| h1['__content__'] if h1['name']=="Number"}.compact.first
    expect(Number).to match("D-05106") 
  end

end
