source 'https://rubygems.org'

ruby file: ".ruby-version"

gem 'rails', '~> 8.0.4'
gem 'mysql2'
gem 'puma', '~> 7.2'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'base64', '~> 0.3.0'
gem 'bigdecimal', '~> 4.0'
gem 'mutex_m', '~> 0.3.0' # Required by pubsubstub (via shipit-engine); no longer a default gem in Ruby 3.4+
gem 'json', '~> 2.18'
gem 'io-console', '~> 0.8'
gem 'minitest', '~> 5.0'
gem 'ostruct'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5'
end

group :development, :test do
  gem 'byebug', platform: :mri
end

gem 'sidekiq'
gem 'shipit-engine', '>= 0.36.0'
