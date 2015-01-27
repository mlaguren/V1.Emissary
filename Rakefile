begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end

desc "run app locally"
task :run => "Gemfile.lock" do
  require './app'
  Sinatra::Application.run!
end
