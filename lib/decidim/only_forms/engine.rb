# frozen_string_literal: true

require "rails"
require "decidim/core"
require "deface"

module Decidim
  module OnlyForms
    # This is the engine that runs on the public interface of only_forms.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::OnlyForms
    end
  end
end
