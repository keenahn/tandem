ruby "2.2.2"
source "https://rubygems.org"

gem "people", github: "keenahn/people" # for parsing names. Using my fork because the old one is not maintained

gem "rails", "4.2.1"              # rails! For edge Rails instead, use: gem "rails", github: "rails/rails"

gem "bootstrap-sass"              # Use sass for boostrap
gem "bootstrap-sass-extras"       # Use sass for boostrap
gem "bundler"                     # Package manager
gem "clockwork"                   # Cron replacement, used for scheduling daily tasks and reschedules
gem "coffee-rails"                # Use CoffeeScript for .js.coffee assets and views
gem "dalli"                       # memcached
gem "delayed_job_active_record"   # Delayed Job
gem "devise"                      # Simple user system
gem "flag_shih_tzu"               # Bitfield flags
gem "haml"                        # Use haml for views and generators
gem "haml-rails"                  # for haml generators
gem "i18n"                        # translation
gem "jbuilder"                    # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jquery-rails"                # Use jquery as the JavaScript library
gem "kgio"                        # performance boost for dalli
gem "memcachier"                  # memcache service
gem "multi_fetch_fragments"       # for parallel fetching of cached items from memcache http://ninjasandrobots.com/rails-faster-partial-rendering-and-caching
gem "omniauth"                    # OmniAuth is a flexible authentication system utilizing Rack middleware https://github.com/intridea/omniauth
gem "omniauth-facebook"           # Omniauth strategy for Facebook
gem "pg"                          # Use postgresql as the database for Active Record
gem "phone"                       # for parsing and validating phone numbers! And area code detection
gem "pundit"                      # for a lightweight permissions system
gem "sass-rails"                  # Use SCSS for stylesheets
gem "select2-rails"               # Better dropdowns for forms
gem "simple_form"                 # simple form generator
gem "turbolinks"                  # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem "twilio-ruby"                 # Twilio
gem "twiml_template"              # Easy TWIML views
gem "tzinfo-data"                 # TZInfo::Data contains data from the IANA Time Zone database packaged as Ruby modules for use with TZInfo.
gem "uglifier"                    # Use Uglifier as compressor for JavaScript assets
gem "validates_formatting_of"     # Simple validators (like for email) https://github.com/mattdbridges/validates_formatting_of

group :development do
  gem "awesome_print"             # Pretty print ruby objects https://github.com/michaeldv/awesome_print
  gem "pry"                       # better console
  gem "pry-rails"                 # rails loader for pry
  gem "colorize"                  # Ruby string class extension for colors # https://github.com/fazibear/colorize
  gem "hirb"                      # view framework for console https://github.com/cldwalker/hirb
  gem "byebug"                    # debugger
  gem "pry-byebug"                # use byebug with pry
  gem "pry-stack_explorer"        # add stack navigation to pry https://github.com/pry/pry-stack_explorer
  gem "thin"                      # Fast webserver for dev
end

group :staging, :production do
  gem "rails_12factor"            # https://devcenter.heroku.com/articles/ruby-support#injected-plugins
  gem "unicorn"                   # Use unicorn as the app server
end

group :test do
  gem "shoulda-matchers"          # rspec syntactic sugar
  gem "simplecov", require: false # test coverage
end

group :development, :staging do
  gem "rack-cors", require: "rack/cors" # https://github.com/cyu/rack-cors
end

group :development, :test do
  gem "rspec-rails"               # use rspec syntax for tests
  gem "factory_girl_rails"        # factories for test data
  gem "faker"                     # generate random data in different formats
  gem "database_cleaner"          # clean database after tests
  gem "dotenv-rails"              # for the .env file
  gem "httparty"                  # HTTP get and post testing
end

group :doc do
  gem "sdoc"                      # bundle exec rake doc:rails generates the API under doc/api.
end
