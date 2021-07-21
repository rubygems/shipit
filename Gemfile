source 'https://rubygems.org'

git_source :github do |repo|
  "https://github.com/#{repo}.git"
end

gem 'rails', '~> 6.0.3'
gem 'mysql2'
gem 'puma', '~> 4.3'
gem 'bootsnap', '>= 1.4.2', require: false

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.7'
end

group :development, :test do
  gem 'byebug', platform: :mri
end

gem 'sidekiq'
gem 'shipit-engine', '>= 0.31.0', github: 'Shopify/shipit-engine'
