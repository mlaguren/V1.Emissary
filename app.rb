require 'sinatra'
require 'rufus-scheduler'
require './lib/v1defect'
require './lib/v1jira'
require './lib/v1trigger'
require 'yaml'
require 'httparty'


helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin1']
    @user = "Administrator"
  end
end

configure do
  # logging is enabled by default in classic style applications,
  # so `enable :logging` is not needed
  file = File.new("system.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end


#  When Sinatra starts up, begin polling the RSS feed

scheduler = Rufus::Scheduler.new

scheduler.every '5s' do
  # Check if the rss file is configured
  if File.file?('./config/v1config.yml')
    v1 = V1Trigger.new
    list = v1.get_list 
    list.each do |story|
      defect = V1Defect.new
      details = defect.get_details story
      p details
    end
  end
end



get '/' do

  erb :index 
end

get '/admin' do
  protected!
  erb :admin
end

#  Webhook for JIRA to process updated issues associated with V1

get '/jira' do
  
end
