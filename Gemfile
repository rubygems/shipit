source "https://rubygems.org"

ruby file: ".ruby-version"

gem "rails", "~> 8.1.3"
gem "mysql2"
gem "puma", "~> 7.2"
gem "bootsnap", ">= 1.4.2", require: false
gem "base64", "~> 0.3.0"
gem "bigdecimal", "~> 4.1"
gem "mutex_m", "~> 0.3.0" # Required by pubsubstub (via shipit-engine); no longer a default gem in Ruby 3.4+
gem "json", "~> 2.19"
gem "io-console", "~> 0.8"
gem "minitest", "~> 6.0"
gem "ostruct"

group :development do
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5"
end

group :development, :test do
  gem "byebug", platform: :mri
  gem "rubocop", require: false
  gem "rubocop-rails-omakase", require: false
end

gem "sidekiq"
gem "shipit-engine", ">= 0.36.0"

gem "datadog", "~> 2.0"
gem "dogstatsd-ruby", "~> 5.0"
gem "lograge"
