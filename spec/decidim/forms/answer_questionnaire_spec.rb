# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Forms::AnswerQuestionnaire do
  subject(:command) { described_class.new(form, questionnaire) }

  let(:user) { instance_double("Decidim::User") }
  let(:questionnaire) { instance_double("Decidim::Forms::Questionnaire") }
  let(:form) do
    instance_double(
      "Decidim::Forms::QuestionnaireForm",
      current_user: user,
      invalid?: form_invalid,
      responses: [],
      context: context
    )
  end
  let(:context) { instance_double("Decidim::Forms::QuestionnaireContext", session_token: "st", ip_hash: "ih") }
  let(:form_invalid) { false }
  let(:current_settings) { instance_double("settings", allow_multiple_answers: true) }

  before do
    allow(command).to receive(:answer_questionnaire)
    allow(command).to receive(:current_settings).and_return(current_settings)
    allow(questionnaire).to receive(:answered_by?).and_return(false)
  end

  describe ".call" do
    it "supports (form, questionnaire) arity" do
      cmd = described_class.call(form, questionnaire)
      expect(cmd).to be_a(described_class)
    end
  end

  describe "#call" do
    context "when the form is invalid" do
      let(:form_invalid) { true }

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end
    end

    context "when multiple answers are allowed" do
      let(:current_settings) { instance_double("settings", allow_multiple_answers: true) }

      it "does not block answering even if questionnaire is already answered" do
        allow(questionnaire).to receive(:answered_by?).and_return(true)
        expect(command).to receive(:answer_questionnaire)
        expect { command.call }.to broadcast(:ok)
      end
    end

    context "when multiple answers are NOT allowed" do
      let(:current_settings) { instance_double("settings", allow_multiple_answers: false) }

      it "blocks answering if questionnaire was already answered" do
        allow(questionnaire).to receive(:answered_by?).and_return(true)
        expect(command).not_to receive(:answer_questionnaire)
        expect { command.call }.to broadcast(:invalid)
      end
    end

    context "when the command succeeds" do
      let(:current_settings) { instance_double("settings", allow_multiple_answers: true) }

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end
    end

    context "when answer persistence fails inside the command" do
      let(:current_settings) { instance_double("settings", allow_multiple_answers: true) }

      before do
        allow(command).to receive(:answer_questionnaire) { command.instance_variable_set(:@errors, true) }
        allow(command).to receive(:reset_form_attachments)
      end

      it "resets attachments and broadcasts invalid" do
        expect(command).to receive(:reset_form_attachments)
        expect { command.call }.to broadcast(:invalid)
      end
    end
  end
end

