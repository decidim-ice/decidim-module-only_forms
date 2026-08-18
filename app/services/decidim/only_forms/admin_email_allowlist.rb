# frozen_string_literal: true

module Decidim
  module OnlyForms
    class AdminEmailAllowlist
      def initialize(email, participatory_space)
        @email = email.to_s.strip
        @space = participatory_space
      end

      def valid_setting?
        @email.blank? || allowed_recipient?
      end

      def allowed_recipient?
        formatted? && matching_admins.exists?
      end

      private

      def formatted?
        @email.match?(URI::MailTo::EMAIL_REGEXP)
      end

      def matching_admins
        return Decidim::User.none if @space.blank?

        @space.admins.where("LOWER(email) = ?", @email.downcase)
      end
    end
  end
end
