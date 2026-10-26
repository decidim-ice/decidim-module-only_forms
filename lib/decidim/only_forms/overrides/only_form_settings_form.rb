# frozen_string_literal: true

module Decidim
  module OnlyForms
    module Overrides
      module OnlyFormSettingsForm
        extend ActiveSupport::Concern

        included do
          attribute :allow_multiple_answers, :boolean
          attribute :admin_email, String

          validate :admin_email_must_be_space_admin

          private

          def admin_email_must_be_space_admin
            return if allowlist.valid_setting?

            survey.errors.add(:admin_email, :invalid)
          end

          def allowlist
            ::Decidim::OnlyForms::AdminEmailAllowlist.new(settings.admin_email, participatory_space)
          end
        end
      end
    end
  end
end
