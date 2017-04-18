#config/puma.rb
if ENV['RAILS_ENV'] == 'development'
  threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
  threads threads_count, threads_count
  port        ENV.fetch("PORT") { 3000 }
  environment ENV.fetch("RAILS_ENV") { "development" }
  plugin :tmp_restart
else
  environment ENV['RAILS_ENV'] || 'production'
  daemonize false
  pidfile "/var/app/my_app/shared/tmp/pids/puma.pid"
  stdout_redirect "/var/app/my_app/shared/tmp/log/stdout", "/var/app/my_app/shared/tmp/log/stderr"

  threads 0, 16

  bind "unix:///var/app/my_app/shared/tmp/sockets/puma.sock"
end