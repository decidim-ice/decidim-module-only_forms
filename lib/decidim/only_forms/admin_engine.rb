# frozen_string_literal: true

module Decidim
  module OnlyForms
    # This is the engine that runs on the public interface of `OnlyForms`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::OnlyForms::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        #resources :only_forms
        #root to: 'only_forms#index'
      end

      def load_seed
        nil
      end
    end
  end
end
