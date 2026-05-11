# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  enable_coverage :branch
  add_filter "/spec/"
  minimum_coverage 0
end

require "decidim/dev"
require "decidim/dev/test/map_server"

ENV["RAILS_DISABLE_HOST_AUTHORIZATION"] = "1"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path("decidim_dummy_app", __dir__)

require "decidim/dev/test/base_spec_helper"

RSpec.configure do |config|
  config.before(:suite) do
    Rails.application.config.hosts << /.*/
  end

  patterns =
    config.exclude_pattern
          .to_s
          .split(/\s*,\s*/)
          .reject(&:empty?)

  patterns << "spec/decidim_dummy_app/vendor/**/*_spec.rb"

  config.exclude_pattern = patterns.join(",")
end
