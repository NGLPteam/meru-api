# frozen_string_literal: true

RSpec.describe Users::AccessInfo do
  let_it_be(:user, refind: true) { FactoryBot.create :user, :admin }
  let_it_be(:user_access_info, refind: true) { user.reload_access_info }

  describe ".wrap" do
    it "accepts a User instance" do
      expect(described_class.wrap(user)).to be_a_kind_of(described_class).and(be_global)
    end

    it "accepts a UserAccessInfo instance" do
      expect(described_class.wrap(user_access_info)).to be_a_kind_of(described_class).and(be_global)
    end

    it "accepts an anonymous user and produces a forbidden access permission" do
      expect(described_class.wrap(AnonymousUser.new)).to be_a_kind_of(described_class).and(be_forbidden)
    end
  end
end
