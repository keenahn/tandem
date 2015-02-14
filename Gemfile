ruby "2.2.0"

source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "4.2"
# Use postgresql as the database for Active Record
gem "pg"
# Use SCSS for stylesheets
gem "sass-rails", "~> 4.0.3"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# Use CoffeeScript for .js.coffee assets and views
gem "coffee-rails", "~> 4.0.0"
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem "therubyracer",  platforms: :ruby

# Use jquery as the JavaScript library
gem "jquery-rails"
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem "turbolinks"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.0"
# bundle exec rake doc:rails generates the API under doc/api.
gem "sdoc", "~> 0.4.0",          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem "spring",        group: :development

# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use unicorn as the app server
# gem "unicorn"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

# Use debugger
# gem "debugger", group: [:development, :test]

gem "bundler"

gem "simple_form"
gem "bootstrap-sass", github: "twbs/bootstrap-sass"
gem "bootstrap-sass-extras"
gem "devise", github: "plataformatec/devise"
gem "omniauth"
gem "omniauth-facebook"
gem "validates_formatting_of"
gem "tzinfo-data"
gem "twilio-ruby"
gem "thin"

gem "dotenv-rails", :groups => [:development, :test] # for the .env file

gem "haml-rails", "~> 0.8" # for haml generators
gem "haml"


gem "memcachier"                  # memcache service
gem "kgio"                        # performance boost for dalli
gem "dalli"                       # memcached

gem "rails_12factor", group: :production   # https://devcenter.heroku.com/articles/ruby-support#injected-plugins

gem "multi_fetch_fragments" # for parallel fetching of cached items from memcache http://ninjasandrobots.com/rails-faster-partial-rendering-and-caching


group :development do
  gem "awesome_print"
  gem "pry" # better console
  gem "pry-rails" #rails loader for pry
  gem "colorize"
  gem "hirb"
  gem "byebug"
  gem "pry-byebug"
  gem "pry-stack_explorer"
  gem "htmlentities"
  gem "smarter_csv"
end

group :test do
  gem "shoulda-matchers"
end

group :development, :staging do
  gem "rack-cors", :require => "rack/cors"
end

group :development, :test do
  gem "rspec-rails" # , "~> 2.0"
  gem "factory_girl_rails"
  gem "faker"
  gem "database_cleaner"
end


gem "pundit" # for a lightweight permissions system
