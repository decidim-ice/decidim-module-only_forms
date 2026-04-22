# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module OnlyForms
    # This is the engine that runs on the public interface of only_forms.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::OnlyForms

      initializer "decidim_only_forms.allow_test_hosts" do |app|
        next unless Rails.env.test?

        # Decidim system tests commonly use *.lvh.me subdomains.
        Rails.application.config.hosts << /.*\.lvh\.me(:\d+)?/
      end
    end
  end
end
