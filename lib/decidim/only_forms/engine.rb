# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module OnlyForms
    # This is the engine that runs on the public interface of only_forms.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::OnlyForms

      routes do
        # Add engine routes here
        #resources :only_forms
        #root to: 'only_forms#index'
      end

      initializer "decidim_only_forms.assets" do |app|
        app.config.assets.precompile += %w[decidim_only_forms_manifest.js decidim_only_forms_manifest.css]
      end

    end
  end
end
