source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'shipit-engine', '~> 0.15.0'
gem 'rails', '~> 5.0.1'

gem 'thin'
gem 'rack'
gem 'mysql2'
gem 'redis-rails'
gem 'sinatra', '2.0.0.beta2'
gem 'resque', '1.26.pre.0', require: %w(resque resque/server)
gem 'hashie', '~> 3.4.6'
gem 'uglifier', '~> 2.7.2'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
end

group :development, :test do
  gem 'byebug', platform: :mri
end

group :deploy do
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano'
  gem 'whenever'
end
