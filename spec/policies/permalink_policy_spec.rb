# frozen_string_literal: true

RSpec.describe PermalinkPolicy, type: :policy do
  subject { described_class.new(identity, permalink) }

  let_it_be(:permalink) { FactoryBot.create :permalink }
end
