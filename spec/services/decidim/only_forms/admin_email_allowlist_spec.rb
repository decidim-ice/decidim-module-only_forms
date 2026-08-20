# frozen_string_literal: true

require "spec_helper"

module Decidim
  module OnlyForms
    describe AdminEmailAllowlist do
      subject(:allowlist) { described_class.new(email, process) }

      let(:organization) { create(:organization) }
      let(:process) { create(:participatory_process, :with_steps, organization:) }
      let(:email) { "admin@example.org" }

      describe "#valid_setting?" do
        it "accepts a blank value" do
          expect(described_class.new("", process).valid_setting?).to be(true)
          expect(described_class.new("  ", process).valid_setting?).to be(true)
        end
      end

      describe "#allowed_recipient?" do
        it "accepts an organization admin" do
          create(:user, :confirmed, :admin, organization:, email:)

          expect(allowlist.allowed_recipient?).to be(true)
        end

        it "accepts a space admin" do
          create(:process_admin, :confirmed, participatory_process: process, email:)

          expect(allowlist.allowed_recipient?).to be(true)
        end

        it "accepts the email regardless of case" do
          create(:user, :confirmed, :admin, organization:, email: "admin@example.org")

          expect(described_class.new("Admin@Example.org", process).allowed_recipient?).to be(true)
        end

        it "rejects a registered participant" do
          create(:user, :confirmed, organization:, email:)

          expect(allowlist.allowed_recipient?).to be(false)
        end

        it "rejects an unknown address" do
          expect(allowlist.allowed_recipient?).to be(false)
        end

        it "rejects a space moderator" do
          create(:process_moderator, :confirmed, participatory_process: process, email:)

          expect(allowlist.allowed_recipient?).to be(false)
        end

        it "rejects an admin from another organization" do
          other_organization = create(:organization)
          create(:user, :confirmed, :admin, organization: other_organization, email:)

          expect(allowlist.allowed_recipient?).to be(false)
        end

        it "rejects a space admin of another process" do
          other_process = create(:participatory_process, :with_steps, organization:)
          create(:process_admin, :confirmed, participatory_process: other_process, email:)

          expect(allowlist.allowed_recipient?).to be(false)
        end
      end
    end
  end
end
