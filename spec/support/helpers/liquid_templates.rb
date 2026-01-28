# frozen_string_literal: true

module TestHelpers
  AssignHelpers = TestHelpers::HashSetter.new(:assigns)
end

RSpec.shared_context "liquid templates" do
  # Intentionally left blank.
end

RSpec.configure do |config|
  config.include TestHelpers::AssignHelpers, liquid_templates: true

  config.include_context "liquid templates", liquid_templates: true
end
