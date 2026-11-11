# frozen_string_literal: true

require "spec_helper"

module Decidim
  module OnlyForms
    describe AdminSubmissionNotification do
      subject(:notification) { described_class.new(data) }

      let(:organization) { create(:organization) }
      let(:process) { create(:participatory_process, :with_steps, organization:) }
      let(:admin_email) { "admin@example.org" }
      let(:component) do
        create(
          :only_forms_component,
          participatory_space: process,
          settings: { admin_email: }
        )
      end
      let(:survey) { create(:survey, component:) }
      let(:questionnaire) { survey.questionnaire }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:question) { create(:questionnaire_question, questionnaire:) }
      let(:session_token) { "session-token" }
      let(:response_session_token) { "session-token" }
      let(:response) { create(:response, questionnaire:, question:, user:, session_token: response_session_token, body: "red") }
      let(:response_ids) { [response.id] }
      let(:data) do
        {
          resource: questionnaire,
          extra: { session_token:, questionnaire:, event_author: user, response_ids: }
        }
      end
      let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

      before do
        questionnaire.update!(questionnaire_for: survey)
        response
        allow(AdminSubmissionMailer).to receive(:notify).and_return(mailer)
      end

      describe ".handle" do
        before do
          questionnaire.questionnaire_for.update!(
            admin_email: "admin@example.org"
          )
          create(:user, :confirmed, :admin, organization:, email: admin_email)
        end

        it "enqueues the admin notification mailer" do
          described_class.handle("decidim.forms.response_questionnaire:after", data)

          expect(AdminSubmissionMailer).to have_received(:notify).with(
            "admin@example.org",
            questionnaire,
            response_ids
          )
          expect(mailer).to have_received(:deliver_later)
        end

        context "when response_ids are blank" do
          let(:session_token) { nil }

          it "does not enqueue" do
            described_class.handle("decidim.forms.response_questionnaire:after", data)

            expect(AdminSubmissionMailer).not_to have_received(:notify)
          end
        end
      end

      describe "#deliver" do
        context "when admin_email is blank" do
          let(:admin_email) { "" }

          it "does not enqueue" do
            notification.deliver

            expect(AdminSubmissionMailer).not_to have_received(:notify)
          end
        end

        context "when admin_email is invalid" do
          let(:admin_email) { "not-an-email" }

          it "does not enqueue" do
            notification.deliver

            expect(AdminSubmissionMailer).not_to have_received(:notify)
          end
        end

        context "when the email is a registered participant" do
          let(:admin_email) { "participant@example.org" }

          before { create(:user, :confirmed, organization:, email: admin_email) }

          it "does not enqueue" do
            notification.deliver

            expect(AdminSubmissionMailer).not_to have_received(:notify)
          end
        end

        context "when the component is surveys" do
          let(:component) { create(:surveys_component, participatory_space: process) }

          it "does not enqueue" do
            notification.deliver

            expect(AdminSubmissionMailer).not_to have_received(:notify)
          end
        end
      end
    end
  end
end
