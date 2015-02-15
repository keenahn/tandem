RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    begin
      DatabaseCleaner.strategy = :transaction
      # DatabaseCleaner.strategy = :truncation # use this if we need to have multiple db connections
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end

end