# frozen_string_literal: true

module Decidim
  module OnlyForms
    class AdminSubmissionNotification
      def self.handle(_event_name, data)
        new(data).deliver
      end

      def initialize(data)
        @questionnaire = data[:resource]
        @session_token = data.dig(:extra, :session_token)
      end

      def deliver
        return unless @questionnaire.is_a?(::Decidim::Forms::Questionnaire)
        return unless notify?

        AdminSubmissionMailer.notify(admin_email, @questionnaire, @session_token).deliver_later
      end

      private

      def notify?
        only_forms? && recipient_allowed? && answers.present?
      end

      def only_forms?
        survey? && component&.manifest_name.to_s == "only_forms"
      end

      def survey?
        questionnaire_for.instance_of?(::Decidim::Surveys::Survey)
      end

      def recipient_allowed?
        AdminEmailAllowlist.new(admin_email, component&.participatory_space).allowed_recipient?
      end

      def admin_email
        component&.settings&.admin_email.to_s.strip
      end

      def component
        questionnaire_for.try(:component)
      end

      def questionnaire_for
        @questionnaire.questionnaire_for
      end

      def answers
        @answers ||= collection.where(session_token: @session_token)
      end

      def collection
        return @questionnaire.answers if @questionnaire.respond_to?(:answers)

        @questionnaire.responses
      end
    end
  end
end
