source 'http://rubygems.org'
ruby '2.7.6'

gem 'activerecord-session_store'
gem 'bootstrap-sass'
gem 'haml-rails'
gem 'httpclient'
gem 'passenger'
gem 'pg', '~> 1.5.0'
gem 'sassc-rails'
gem 'concurrent-ruby', '~> 1.2.0'
gem 'rails', '~> 7.0.0'
gem 'rails-controller-testing'
gem 'rails-observers'
gem 'rake'
gem 'rails_autolink'
gem 'rb-readline'
gem 'webpacker'

group :assets do
  gem 'uglifier'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem "capybara"
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem "factory_bot_rails"
  gem 'i18n_generators'
  gem 'listen'
  gem 'phantomjs', :require => 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'puma'
  gem "pry-rails"
  gem "rspec-rails"
  gem 'timecop'
end

group :production do
  gem 'sendgrid-ruby'
end
