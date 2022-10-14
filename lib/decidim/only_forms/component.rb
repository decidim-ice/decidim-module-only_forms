# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:surveys) do |component|
  #component.engine = Decidim::OnlyForms::Engine
  #component.admin_engine = Decidim::OnlyForms::AdminEngine
  #component.icon = "decidim/only_forms/icon.svg"

  component.settings(:step) do |settings|
    settings.attribute :allow_multiple_answers, type: :boolean, default: true
  end
  puts component.settings(:step).attributes
end
