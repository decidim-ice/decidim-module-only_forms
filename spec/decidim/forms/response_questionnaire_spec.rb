# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Forms::ResponseQuestionnaire do
  subject(:command) { command_class.new(form, questionnaire, allow_editing_responses:) }

  let(:command_class) do
    questionnaire_stub = questionnaire
    form_stub = form

    Class.new(described_class) do
      define_method(:response_questionnaire) { nil }

      define_method(:form) { form_stub }
      define_method(:questionnaire) { questionnaire_stub }
    end
  end

  let(:user) { instance_double("Decidim::User") }
  let(:questionnaire_for) { instance_double("Dummy", allow_multiple_answers:) }
  let(:allow_multiple_answers) { true }
  let(:allow_editing_responses) { false }
  let(:questionnaire) { instance_double("Decidim::Forms::Questionnaire", questionnaire_for:) }
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

  before do
    allow(questionnaire).to receive(:responded_by?).and_return(false)
  end

  describe ".call" do
    it "supports (form, questionnaire, allow_editing_responses:) arity" do
      result = described_class.call(form, questionnaire, allow_editing_responses: false)
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

    describe "multiple answers" do
      context "when multiple answers are allowed" do
        let(:allow_multiple_answers) { true }

        it "does not block responding even if questionnaire is already responded" do
          allow(questionnaire).to receive(:responded_by?).and_return(true)
          expect { command.call }.to broadcast(:ok)
        end
      end

      context "when multiple answers are NOT allowed" do
        let(:allow_multiple_answers) { false }

        it "blocks responding if questionnaire was already responded" do
          allow(questionnaire).to receive(:responded_by?).and_return(true)
          expect { command.call }.to broadcast(:invalid)
        end

        it "allows responding if not already responded" do
          allow(questionnaire).to receive(:responded_by?).and_return(false)
          expect { command.call }.to broadcast(:ok)
        end
      end

      context "when questionnaire_for does not respond to allow_multiple_answers" do
        let(:questionnaire_for) { instance_double("Dummy") }

        before do
          allow(questionnaire_for).to receive(:respond_to?).with("allow_multiple_answers").and_return(false)
        end

        it "allows responding (allow_multiple_answers? returns nil, falsy)" do
          allow(questionnaire).to receive(:responded_by?).and_return(true)
          expect { command.call }.to broadcast(:ok)
        end
      end
    end

    describe "editing responses" do
      let(:allow_editing_responses) { true }
      let(:allow_multiple_answers) { false }

      before do
        allow(questionnaire).to receive(:responded_by?).and_return(true)
      end

      it "allows responding even when already responded" do
        expect { command.call }.to broadcast(:ok)
      end

      it "clears previous responses before responding" do
        response_scope = instance_double(ActiveRecord::Relation)
        allow(Decidim::Forms::Response).to receive(:where).and_return(response_scope)
        allow(response_scope).to receive(:destroy_all)

        command.call

        expect(Decidim::Forms::Response).to have_received(:where).with(
          questionnaire:,
          user:,
          session_token: "st",
          ip_hash: "ih"
        )
        expect(response_scope).to have_received(:destroy_all)
      end
    end

    describe "success path" do
      let(:allow_multiple_answers) { true }

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "publishes response_questionnaire:after" do
        seen = nil
        subscriber = ActiveSupport::Notifications.subscribe("decidim.forms.response_questionnaire:after") do |_name, data|
          seen = data
        end

        command.call

        expect(seen[:resource]).to eq(questionnaire)
        expect(seen[:extra][:session_token]).to eq("st")
        expect(seen[:extra][:event_author]).to eq(user)
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end

      it "publishes the created answer ids" do
        publishing_class = Class.new(command_class) do
          define_method(:response_questionnaire) { @created_answer_ids = [11, 22] }
        end
        publishing_command = publishing_class.new(form, questionnaire, allow_editing_responses: false)

        seen = nil
        subscriber = ActiveSupport::Notifications.subscribe("decidim.forms.response_questionnaire:after") do |_name, data|
          seen = data
        end

        publishing_command.call

        expect(seen[:extra][:answer_ids]).to eq([11, 22])
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end
    end

    describe "failure path" do
      let(:allow_multiple_answers) { true }

      it "resets attachments and broadcasts invalid" do
        failing_command_class = Class.new(command_class) do
          attr_reader :reset_called

          def response_questionnaire
            @errors = true
          end

          def reset_form_attachments
            @reset_called = true
          end
        end

        failing_command = failing_command_class.new(form, questionnaire, allow_editing_responses: false)
        expect { failing_command.call }.to broadcast(:invalid)
        expect(failing_command.reset_called).to be(true)
      end
    end
  end
end
