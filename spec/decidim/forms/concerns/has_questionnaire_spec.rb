# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Forms::Concerns::HasQuestionnaire, type: :controller do
  controller(ActionController::Base) do
    include Decidim::Forms::Concerns::HasQuestionnaire

    def questionnaire_for = :dummy

    def allow_answers? = true

    def allow_unregistered? = false

    def enforce_permission_to(*) = true

    def current_user = nil

    def current_settings = @current_settings

    def questionnaire = @questionnaire
  end

  let(:settings) { instance_double("settings", allow_multiple_answers: allow_multiple_answers) }
  let(:allow_multiple_answers) { true }
  let(:questionnaire) { instance_double("Decidim::Forms::Questionnaire") }

  before do
    controller.instance_variable_set(:@current_settings, settings)
    controller.instance_variable_set(:@questionnaire, questionnaire)
    allow(questionnaire).to receive(:salt).and_return(nil)
    allow(questionnaire).to receive(:id).and_return(123)
    allow(questionnaire).to receive(:answered_by?).and_return(true)
    allow(controller).to receive(:session).and_return({ session_id: "abc" })
  end

  describe "#visitor_already_answered?" do
    context "when multiple answers are allowed" do
      let(:allow_multiple_answers) { true }

      it "returns false" do
        expect(controller.send(:visitor_already_answered?)).to be(false)
      end
    end

    context "when multiple answers are not allowed" do
      let(:allow_multiple_answers) { false }

      it "delegates to questionnaire answered_by? using a tokenized session id" do
        expect(questionnaire).to receive(:answered_by?) do |token|
          expect(token).to be_a(String)
          expect(token.length).to be > 1
          true
        end
        expect(controller.send(:visitor_already_answered?)).to be(true)
      end
    end
  end

  describe "#visitor_can_answer?" do
    it "returns false when no current user and unregistered are not allowed" do
      expect(controller.send(:visitor_can_answer?)).to be(false)
    end
  end

  describe "#session_token" do
    it "returns nil when both user and session are missing" do
      allow(controller).to receive(:session).and_return({})
      allow(controller.request).to receive(:session).and_return({})
      expect(controller.send(:session_token)).to be_nil
    end
  end
end

