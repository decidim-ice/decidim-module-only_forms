# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", "~> 0.27.3"
gem "decidim-only_forms", path: "."

gem "puma", ">= 5.6.2"
gem "bootsnap", "~> 1.4"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", "~> 0.27.3"

  gem "brakeman", "~> 5.2"
  gem "parallel_tests", "~> 3.7"
end


group :test do
  gem 'rspec-rails', '~> 4.0'
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.2"
end

gem "doorkeeper", "~> 5.6"
