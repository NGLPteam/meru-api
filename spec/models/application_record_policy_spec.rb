# frozen_string_literal: true

RSpec.describe ApplicationRecord, type: :model do
  describe "policy_class" do
    described_class.descendants.each do |model|
      describe model do
        it "has a policy class", :aggregate_failures do
          expect do
            expect(ActionPolicy.lookup(described_class)).to be_a Class
          end.not_to raise_error
        end
      end
    end
  end
end
