# frozen_string_literal: true

source "https://rubygems.org"

RUBY_VERSION = ">= 3.4.7"
ruby RUBY_VERSION
DECIDIM_VERSION = ">= 0.32.1"

base_path = "./"
base_path = "../../" if File.basename(__dir__) == "decidim_dummy_app"
base_path = "../" if File.basename(__dir__) == "development_app"

require_relative "#{base_path}lib/decidim/only_forms/version"

gem "bootsnap", "~> 1.4"
gem "decidim", DECIDIM_VERSION
gem "decidim-only_forms", path: base_path
gem "decidim-templates", DECIDIM_VERSION
gem "puma", ">= 6.6"
gem "uglifier", "~> 4.2"
gem "uri", "1.1.1"

gem "concurrent-ruby", "= 1.3.4"
gem "html-pipeline", "~> 3.2.2"
gem "selma", "~> 0.4.0"

gem "deface", "1.9.0", git: "https://github.com/froger/deface", branch: "fix/js-overrides"

group :development, :test do
  gem "brakeman", "~> 6.1"
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "erb_lint"
  gem "parallel_tests", "~> 4.2"
end

group :test do
  gem "capybara", "~> 3.24"
  gem "rspec-rails", "~> 6.0"
  gem "rubocop-faker"
  gem "simplecov", require: false
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "web-console", "~> 4.2"
end
