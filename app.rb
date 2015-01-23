require 'sinatra'
require 'rufus-scheduler'

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

scheduler.every '1s' do

  # Check if the rss file is configured
  if File.file?('./config/rss.yaml')
    p 'file exists'
  end
end



get '/' do

  erb :index 
end

get '/admin' do
  protected!
  erb :admin
end
