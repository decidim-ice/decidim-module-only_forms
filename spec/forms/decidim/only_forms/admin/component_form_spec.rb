# frozen_string_literal: true

require "spec_helper"

module Decidim
  module OnlyForms
    module Admin
      describe ComponentForm do
        subject(:form) do
          described_class.from_params(
            id: component.id,
            weight: 0,
            manifest:,
            participatory_space: process,
            name: generate_localized_title,
            default_step_settings: {},
            settings: component_settings
          ).with_context(current_organization: organization)
        end

        let(:organization) { create(:organization) }
        let(:process) { create(:participatory_process, :with_steps, organization:) }
        let(:component) { create(:only_forms_component, participatory_space: process) }
        let(:manifest) { component.manifest }
        let(:admin_email) { "" }
        let(:component_settings) { Decidim::Component.build_settings(manifest, :global, { admin_email: }, organization) }

        it "is valid when admin_email is blank" do
          expect(form).to be_valid
        end

        context "when the email belongs to an organization admin" do
          let(:admin_email) { "org-admin@example.org" }

          before { create(:user, :confirmed, :admin, organization:, email: admin_email) }

          it { is_expected.to be_valid }
        end

        context "when the email belongs to a space admin" do
          let(:admin_email) { "space-admin@example.org" }

          before { create(:process_admin, :confirmed, participatory_process: process, email: admin_email) }

          it { is_expected.to be_valid }
        end

        shared_examples "a rejected admin email" do
          it "is invalid with the same error as any other rejected address" do
            expect(form).not_to be_valid
            expect(form.settings.errors[:admin_email]).to eq(["is invalid"])
          end
        end

        context "when the email belongs to a registered participant" do
          let(:admin_email) { "participant@example.org" }

          before { create(:user, :confirmed, organization:, email: admin_email) }

          it_behaves_like "a rejected admin email"
        end

        context "when the email is unknown" do
          let(:admin_email) { "unknown@example.org" }

          it_behaves_like "a rejected admin email"
        end

        context "when the email belongs to another organization admin" do
          let(:admin_email) { "other-org@example.org" }

          before { create(:user, :confirmed, :admin, organization: create(:organization), email: admin_email) }

          it_behaves_like "a rejected admin email"
        end
      end
    end
  end
end
