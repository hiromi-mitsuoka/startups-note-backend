source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'active_decorator' # https://github.com/amatsuda/active_decorator
gem 'activerecord-import' # bulk insert : https://github.com/zdennis/activerecord-import
gem 'bootsnap', '>= 1.4.4', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'delayed_job_active_record' # job quere : https://github.com/collectiveidea/delayed_job
gem 'elasticsearch-model' # https://github.com/elastic/elasticsearch-rails
gem 'elasticsearch-rails'
gem 'elasticsearch', '7.10.1' # To match the version to aws and terraform.
gem 'feedjira' # rss : https://github.com/feedjira/feedjira
gem 'hotwire-rails' # https://github.com/hotwired
gem 'httparty' # feedjiraのバージョンアップにより追加
gem 'importmap-rails' # https://github.com/rails/importmap-rails
gem 'jbuilder', '~> 2.7' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'mysql2', '~> 0.5' # Use mysql as the database for Active Record
gem 'paranoia' # https://github.com/rubysherpas/paranoia
gem 'puma', '~> 5.0' # Use Puma as the app server
gem 'rack-cors' # https://github.com/cyu/rack-cors
gem 'rails', '~> 6.1.4', '>= 6.1.4.1' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'redis', '~> 4.0' # Use Redis adapter to run Action Cable in production
gem 'sass-rails', '>= 6' # Use SCSS for stylesheets
gem 'turbo-rails', '~> 0.8' # ECSで、Could not find turbo-rails-7.1.1発生のため指定。bundle update turbo-railsで対応
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'


group :development, :test do
  # gem 'active_decorator-rspec' # https://github.com/mizoR/active_decorator-rspec
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw] # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'debase' # https://github.com/ruby-debug/debase
  gem 'factory_bot_rails' # https://github.com/thoughtbot/factory_bot_rails
  # gem 'pry-byebug' # https://github.com/deivid-rodriguez/pry-byebug
  # gem 'pry-doc' # https://github.com/pry/pry-doc
  # gem 'pry-rails' # https://github.com/pry/pry-rails
  # gem 'pry-stack_explorer' # https://github.com/pry/pry-stack_explorer
  gem 'rspec-rails' # https://github.com/rspec/rspec-rails
  # gem 'ruby-debug-ide' # https://github.com/ruby-debug/ruby-debug-ide
end

group :development do
  gem 'bullet' # https://github.com/flyerhzm/bullet
  gem 'listen', '~> 3.3'
  gem 'rack-mini-profiler', require: false # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'spring' # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'web-console', '>= 4.1.0' # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
