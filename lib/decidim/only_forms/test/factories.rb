# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :only_forms_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :only_forms).i18n_name }
    manifest_name :only_forms
    participatory_space { create(:participatory_process, :with_steps) }
  end

  # Add engine factories here
end
