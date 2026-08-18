# frozen_string_literal: true

module Decidim
  module OnlyForms
    module Admin
      class ComponentForm < Decidim::Admin::ComponentForm
        validate :admin_email_must_be_space_admin

        private

        def admin_email_must_be_space_admin
          return if allowlist.valid_setting?

          settings.errors.add(:admin_email, :invalid)
        end

        def allowlist
          ::Decidim::OnlyForms::AdminEmailAllowlist.new(settings.admin_email, participatory_space)
        end
      end
    end
  end
end
