# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Forms::AnswerQuestionnaire do
  subject(:command) { command_class.new(form, questionnaire) }

  let(:command_class) do
    settings = current_settings
    questionnaire_stub = questionnaire
    form_stub = form

    Class.new(described_class) do
      define_method(:current_settings) { settings }
      define_method(:answer_questionnaire) { nil }

      define_method(:form) { form_stub }
      define_method(:questionnaire) { questionnaire_stub }
    end
  end
  let(:user) { instance_double("Decidim::User") }
  let(:questionnaire) { instance_double("Decidim::Forms::Questionnaire") }
  let(:form) do
    instance_double(
      "Decidim::Forms::QuestionnaireForm",
      current_user: user,
      invalid?: form_invalid,
      responses_by_step: [],
      responses: [],
      context:
    )
  end
  let(:context) { instance_double("Decidim::Forms::QuestionnaireContext", session_token: "st", ip_hash: "ih") }
  let(:form_invalid) { false }
  let(:current_settings) { instance_double("settings", allow_multiple_answers: true) }

  before do
    allow(questionnaire).to receive(:answered_by?).and_return(false)
    allow(questionnaire).to receive(:questionnaire_for).and_return(nil)
  end

  describe ".call" do
    it "supports (form, questionnaire) arity" do
      result = described_class.call(form, questionnaire)
      expect(result).to be_a(Hash)
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
        expect { command.call }.to broadcast(:ok)
      end
    end

    context "when multiple answers are NOT allowed" do
      let(:current_settings) { instance_double("settings", allow_multiple_answers: false) }

      it "blocks answering if questionnaire was already answered" do
        allow(questionnaire).to receive(:answered_by?).and_return(true)
        expect { command.call }.to broadcast(:invalid)
      end
    end

    context "when the command succeeds" do
      let(:current_settings) { instance_double("settings", allow_multiple_answers: true) }

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "publishes answer_questionnaire:after" do
        seen = nil
        subscriber = ActiveSupport::Notifications.subscribe("decidim.forms.answer_questionnaire:after") do |_name, data|
          seen = data
        end

        command.call

        expect(seen[:resource]).to eq(questionnaire)
        expect(seen[:extra][:session_token]).to eq("st")
        expect(seen[:extra][:answer_ids]).to eq([])
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end

      it "publishes the created answer ids" do
        publishing_class = Class.new(command_class) do
          define_method(:answer_questionnaire) { @created_answer_ids = [11, 22] }
        end
        publishing_command = publishing_class.new(form, questionnaire)
        seen = nil
        subscriber = ActiveSupport::Notifications.subscribe("decidim.forms.answer_questionnaire:after") do |_name, data|
          seen = data
        end

        publishing_command.call

        expect(seen[:extra][:answer_ids]).to eq([11, 22])
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end
    end

    context "when answer persistence fails inside the command" do
      let(:current_settings) { instance_double("settings", allow_multiple_answers: true) }

      it "resets attachments and broadcasts invalid" do
        failing_command_class = Class.new(command_class) do
          attr_reader :reset_called

          def answer_questionnaire
            @errors = true
          end

          def reset_form_attachments
            @reset_called = true
          end
        end

        failing_command = failing_command_class.new(form, questionnaire)
        expect { failing_command.call }.to broadcast(:invalid)
        expect(failing_command.reset_called).to be(true)
      end
    end
  end
end
