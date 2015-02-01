Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.


  Rails.application.routes.default_url_options[:host] = "beta.tandem.com"
  Rails.application.routes.default_url_options[:protocol] = 'http'
  config.action_controller.asset_host = "http://beta2.tandem.com"
  config.action_mailer.asset_host = "http://beta2.tandem.com"
  # config.action_controller.asset_host = ""

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false


  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true


  # Caching
  config.cache_store = :dalli_store, {expires_in: 1.day, compress: true }
  Dalli.logger = Logger.new("#{Rails.root}/log/#{Rails.env}_cache.log")
  Dalli.logger.level = Logger::DEBUG


  config.action_mailer.delivery_method = :test # :smtp
  config.action_mailer.deliveries = []
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # :debug, :info, :warn, :error, and :fatal
  # http://guides.rubyonrails.org/debugging_rails_applications.html
  config.log_level = :debug

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.serve_static_files = true

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  # config.assets.debug = true

  config.assets.compile = true

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  # config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # ActiveSupport::Dependencies.autoload_paths << File::join( Rails.root, 'lib')
  # ActiveSupport::Dependencies.explicitly_unloadable_constants << 'Content'

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.middleware.insert_before 0, "Rack::Cors" do
    allow do
      origins "http://beta.tandem.com"
      resource '*', :headers => :any, :methods => [:get, :options]
    end
  end

end

silence_warnings do
  require "pry"
  IRB = Pry
end

