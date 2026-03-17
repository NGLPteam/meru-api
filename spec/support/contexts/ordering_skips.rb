# frozen_string_literal: true

RSpec.shared_context "disable ordering refreshes" do
  around do |example|
    Schemas::Orderings.with_disabled_refresh do
      example.run
    end
  end
end

RSpec.configure do |config|
  config.include_context "disable ordering refreshes", disable_ordering_refresh: true
end
