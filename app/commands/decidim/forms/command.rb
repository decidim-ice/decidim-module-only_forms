# frozen_string_literal: true

module Decidim
  module Forms
    if defined? ::Decidim::Command
      class Command < ::Decidim::Command
      end
    else
      class Command < ::Rectify::Command
      end
    end
  end
end
