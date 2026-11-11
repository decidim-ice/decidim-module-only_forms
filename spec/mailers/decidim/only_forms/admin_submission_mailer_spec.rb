# frozen_string_literal: true

require "spec_helper"

module Decidim
  module OnlyForms
    describe AdminSubmissionMailer do
      include AdminSubmissionEmailHelpers

      let(:organization) { create(:organization, default_locale: :en) }
      let(:process) { create(:participatory_process, :with_steps, organization:, title: { en: "Test Process" }) }
      let(:component) { create(:only_forms_component, participatory_space: process) }
      let(:survey) { create(:survey, component:) }
      let(:questionnaire) { survey.questionnaire }
      let(:session_token) { "session-token" }
      let(:response_ids) { questionnaire.responses.where(session_token:).pluck(:id) }
      let(:mail) { described_class.notify("admin@example.org", questionnaire, response_ids) }

      before do
        questionnaire.update!(questionnaire_for: survey, title: { en: "Registration" })
      end

      shared_examples "a native responses notification" do
        it "sends to the admin email" do
          expect(mail.to).to eq(["admin@example.org"])
        end

        it "sets a subject with the form title" do
          expect(mail.subject).to include("Registration")
        end

        it "renders responses with the native questionnaire response presenter" do
          html = mail_html(mail)

          expect(html).to include("Registration")
          expect(html).to include("Test Process")
          expect(html).to include(expected_author)
          expect_native_presented_responses(mail, questionnaire, session_token)
        end
      end

      context "when the participant is registered" do
        let(:user) { create(:user, :confirmed, name: "Ada Lovelace", email: "ada@example.org", organization:) }
        let(:expected_author) { "Ada Lovelace (ada@example.org)" }

        before { create_mixed_only_forms_responses(questionnaire, user:, session_token:) }

        it_behaves_like "a native responses notification"
      end

      context "when the participant is unregistered" do
        let(:user) { nil }
        let(:expected_author) { "Unregistered participant" }

        before { create_mixed_only_forms_responses(questionnaire, user:, session_token:) }

        it_behaves_like "a native responses notification"
      end

      context "when the same session submits twice" do
        let(:question) do
          create(:questionnaire_question, questionnaire:, question_type: :short_response, body: { en: "fullname" })
        end
        let!(:current_response) do
          create(:response, questionnaire:, question:, session_token:, body: "Louis")
          create(:response, questionnaire:, question:, session_token:, body: "Ana")
        end
        let(:response_ids) { [current_response.id] }

        it "includes only the responses from this submission" do
          html = mail_html(mail)

          expect(html).to include("Ana")
          expect(html).not_to include("Louis")
        end
      end
    end
  end
end
