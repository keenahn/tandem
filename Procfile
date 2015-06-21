web: bundle exec puma -p $PORT -e $RACK_ENV -C config/puma.rb
worker:  bundle exec rake jobs:work
clock: bundle exec clockwork config/clock.rb
