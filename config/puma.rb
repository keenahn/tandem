environment ENV['RACK_ENV']
threads 0,3

workers 1
preload_app!
@clock_pid = nil
@jobs_pid = nil

on_worker_boot do
  @clock_pid ||= spawn("bundle exec clockwork config/clock.rb")
  @jobs_pid ||= spawn("bundle exec rake jobs:work")
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
