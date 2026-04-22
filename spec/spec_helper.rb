# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  enable_coverage :branch
  add_filter "/spec/"
end

require "decidim/dev"
require "decidim/dev/test/map_server"

ENV["RAILS_DISABLE_HOST_AUTHORIZATION"] = "1"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path("decidim_dummy_app", __dir__)

require "decidim/dev/test/base_spec_helper"
