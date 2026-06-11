# frozen_string_literal: true

source "https://rubygems.org"

base_path = "./"
base_path = "../../" if File.basename(__dir__) == "decidim_dummy_app"
base_path = "../" if File.basename(__dir__) == "development_app"

require_relative "#{base_path}lib/decidim/only_forms/version"

ruby RUBY_VERSION

DECIDIM_VERSION = ">= 0.29.7"

gem "decidim", DECIDIM_VERSION
gem "decidim-only_forms", path: base_path
gem "decidim-templates", DECIDIM_VERSION

gem "bootsnap", "~> 1.18"
gem "puma", ">= 6.3.1"

gem "deface",
    git: "https://github.com/froger/deface",
    branch: "fix/js-overrides"

group :development, :test do
  gem "brakeman", "~> 6.1"
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
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
