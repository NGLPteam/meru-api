# frozen_string_literal: true

RSpec.describe ItemPolicy, type: :policy do
  include_context "policy setup"

  let_it_be(:item, refind: true) { FactoryBot.create :item, title: "Item" }

  let_it_be(:subitem, refind: true) { FactoryBot.create :item, parent: item, title: "Subitem" }

  let_it_be(:other_item, refind: true) { FactoryBot.create :item, title: "Other Item" }

  let_it_be(:contextual_role) { FactoryBot.create :role, :all_contextual }

  let(:record) { item }

  describe_rule :show? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: item, to: user }

      succeed "on an item"
      succeed "on a subitem" do
        let(:record) { subitem }
      end
    end

    succeed "as a random user with no permissions"

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end

    context "when the item is hidden" do
      let(:record) { FactoryBot.create :item, :hidden }

      failed "as a random user" do
        let(:user) { regular_user }
      end

      failed "as an anonymous user" do
        let(:user) { anonymous_user }
      end
    end
  end

  describe_rule :create? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: item, to: user }

      succeed "on an item"
      succeed "on a subitem" do
        let(:record) { subitem }
      end
    end

    failed "as a random user with no permissions"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :update? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: item, to: user }

      succeed "on an item"
      succeed "on a subitem" do
        let(:record) { subitem }
      end
    end

    failed "as a random user with no permissions"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :destroy? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: item, to: user }

      succeed "on an item"
      succeed "on a subitem" do
        let(:record) { subitem }
      end
    end

    failed "as a random user with no permissions"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :create_items? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: item, to: user }

      succeed "on an item"
      succeed "on a subitem" do
        let(:record) { subitem }
      end
    end

    failed "as a random user with no permissions"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :manage_access? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: item, to: user }

      failed "on the item"
    end

    failed "as a random user with no permissions"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe "relation scope" do
    let(:target) { Item.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

    context "as an admin" do
      let(:user) { admin }

      it "includes everything" do
        is_expected.to include item, subitem, other_item
      end
    end

    context "as a user with all contextual permissions" do
      before do
        grant_access! contextual_role, on: item, to: user
        other_item.update!(visibility: :hidden)
      end

      it "excludes hidden records" do
        is_expected.to exclude(other_item).and include(item, subitem)
      end
    end

    context "as a random user" do
      before { other_item.update!(visibility: :hidden) }

      it "excludes hidden records" do
        is_expected.to exclude(other_item).and include(item, subitem)
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      before { other_item.update!(visibility: :hidden) }

      it "excludes hidden records" do
        is_expected.to exclude(other_item).and include(item, subitem)
      end
    end
  end
end
