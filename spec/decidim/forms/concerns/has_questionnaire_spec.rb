# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Forms::Concerns::HasQuestionnaire, type: :controller do
  controller(ActionController::Base) do
    include Decidim::Forms::Concerns::HasQuestionnaire

    def questionnaire_for = :dummy

    def allow_responses? = true

    def allow_unregistered? = false

    def enforce_permission_to(*) = true

    def current_user = nil

    attr_reader :questionnaire
  end

  let(:questionnaire_for) { instance_double("Dummy", allow_multiple_answers:) }
  let(:allow_multiple_answers) { true }
  let(:questionnaire) { instance_double("Decidim::Forms::Questionnaire", questionnaire_for:) }

  before do
    controller.instance_variable_set(:@questionnaire, questionnaire)
    allow(questionnaire).to receive(:salt).and_return(nil)
    allow(questionnaire).to receive(:id).and_return(123)
    allow(questionnaire).to receive(:responded_by?).and_return(true)
    allow(controller.request).to receive(:session).and_return({ session_id: "abc" })
  end

  describe "#visitor_already_responded?" do
    context "when multiple answers are allowed" do
      let(:allow_multiple_answers) { true }

      it "returns false" do
        expect(controller.send(:visitor_already_responded?)).to be(false)
      end
    end

    context "when multiple answers are not allowed" do
      let(:allow_multiple_answers) { false }

      it "delegates to questionnaire responded_by? using a tokenized session id" do
        expect(questionnaire).to receive(:responded_by?) do |token|
          expect(token).to be_a(String)
          expect(token.length).to be > 1
          true
        end
        expect(controller.send(:visitor_already_responded?)).to be(true)
      end
    end

    context "when questionnaire_for does not respond to allow_multiple_answers" do
      let(:questionnaire_for) { instance_double("Dummy") }

      before do
        allow(questionnaire_for).to receive(:respond_to?).with("allow_multiple_answers").and_return(false)
      end

      it "delegates to questionnaire responded_by? (allow_multiple_answers? returns nil)" do
        allow(questionnaire).to receive(:responded_by?).and_return(true)
        expect(controller.send(:visitor_already_responded?)).to be(true)
        expect(questionnaire).to have_received(:responded_by?)
      end
    end
  end

  describe "#visitor_can_respond?" do
    it "returns false when no current user and unregistered are not allowed" do
      expect(controller.send(:visitor_can_respond?)).to be(false)
    end

    context "when unregistered users are allowed" do
      before do
        allow(controller).to receive(:allow_unregistered?).and_return(true)
      end

      it "returns true" do
        expect(controller.send(:visitor_can_respond?)).to be(true)
      end
    end

    context "when there is a current user" do
      before do
        allow(controller).to receive(:current_user).and_return(build(:user))
      end

      it "returns true" do
        expect(controller.send(:visitor_can_respond?)).to be(true)
      end
    end
  end

  describe "#session_token" do
    it "returns nil when both user and session are missing" do
      allow(controller.request).to receive(:session).and_return({})
      expect(controller.send(:session_token)).to be_nil
    end

    it "returns a tokenized session id when no user" do
      token = controller.send(:session_token)
      expect(token).to be_a(String)
      expect(token.length).to eq(10)
    end

    it "returns a tokenized user id when user is present" do
      user = instance_double("Decidim::User", id: 42)
      allow(controller).to receive(:current_user).and_return(user)
      token = controller.send(:session_token)
      expect(token).to be_a(String)
      expect(token.length).to eq(10)
    end
  end

  describe "#ip_hash" do
    it "returns nil when remote_ip is missing" do
      allow(controller.request).to receive(:remote_ip).and_return(nil)
      expect(controller.send(:ip_hash)).to be_nil
    end

    it "returns a tokenized ip" do
      allow(controller.request).to receive(:remote_ip).and_return("192.168.1.1")
      hash = controller.send(:ip_hash)
      expect(hash).to be_a(String)
      expect(hash.length).to eq(10)
    end
  end

  describe "#tokenize" do
    it "uses questionnaire salt when present" do
      allow(questionnaire).to receive(:salt).and_return("my_salt")
      token = controller.send(:tokenize, "some_id")
      expect(token).to be_a(String)
    end

    it "falls back to questionnaire id when salt is nil" do
      allow(questionnaire).to receive(:salt).and_return(nil)
      token = controller.send(:tokenize, "some_id")
      expect(token).to be_a(String)
    end
  end

  describe "#after_response_path" do
    it "returns questionnaire_for" do
      expect(controller.send(:after_response_path)).to eq(:dummy)
    end
  end

  describe "#allow_editing_responses?" do
    it "returns false by default" do
      expect(controller.send(:allow_editing_responses?)).to be(false)
    end
  end

  describe "#visitor_can_edit_responses?" do
    it "returns false when no current user" do
      expect(controller.send(:visitor_can_edit_responses?)).to be(false)
    end
  end
end
