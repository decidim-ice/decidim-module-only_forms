# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module OnlyForms
    # This is the engine that runs on the public interface of only_forms.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::OnlyForms

      initializer "decidim_only_forms.allow_test_hosts" do |app|
        next unless app.config.respond_to?(:hosts)

        # Decidim system tests commonly use *.lvh.me subdomains.
        app.config.hosts << /.*\.lvh\.me(:\d+)?/
      end

      routes do
        # Add engine routes here
      end

    end
  end
end
