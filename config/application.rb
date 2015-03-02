require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tandem
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de


    # load subdirectories too
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # Load all stuff in lib
    config.autoload_paths += Dir["#{config.root}/lib", "#{config.root}/lib/**/"]


    # Set the default time zones. DO NOT CHANGE THIS
    # http://jessehouse.com/blog/2013/11/15/working-with-timezones-and-ruby-on-rails/
    # We will always keep the system defaults as UTC and then change it per user
    # config.time_zone = "UTC" # Default time zone for displaying
    # config.active_record.default_timezone = :utc    # For saving to the database


    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :haml
    #   g.test_framework  :test_unit, fixture: true
    # end

  end

end
