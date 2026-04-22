# frozen_string_literal: true

module Decidim
  # This holds the decidim-meetings version.
  module OnlyForms
    def self.version
      "0.1.1"
    end

    def self.decidim_version
      [">= 0.26", "<0.30"].freeze
    end
  end
end
