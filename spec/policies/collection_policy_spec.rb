# frozen_string_literal: true

RSpec.describe CollectionPolicy, type: :policy do
  include_context "policy setup"

  let_it_be(:community) { FactoryBot.create :community }

  let_it_be(:collection, refind: true) { FactoryBot.create :collection, community:, title: "Collection" }

  let_it_be(:subcollection, refind: true) { FactoryBot.create :collection, parent: collection, title: "Subcollection" }

  let_it_be(:other_community, refind: true) { FactoryBot.create :community }

  let_it_be(:other_collection, refind: true) { FactoryBot.create :collection, community: other_community, title: "Other Collection" }

  let_it_be(:manager_role) { FactoryBot.create :role, :manager }

  let_it_be(:editor_role) { FactoryBot.create :role, :editor }

  let_it_be(:contextual_role) { FactoryBot.create :role, :all_contextual }

  let(:record) { collection }

  describe_rule :show? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a manager on the parent community" do
      before { grant_access! manager_role, on: community, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end
    end

    context "as an editor on the parent community" do
      before { grant_access! editor_role, on: community, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end
    end

    succeed "as a random user with no permissions"

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end

    context "when the collection is hidden" do
      let(:record) { FactoryBot.create :collection, visibility: :hidden }

      failed "as a random user" do
        let(:user) { regular_user }
      end

      failed "as an anonymous user" do
        let(:user) { anonymous_user }
      end
    end
  end

  describe_rule :read? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a manager on the parent community" do
      before { grant_access! manager_role, on: community, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end
    end

    context "as an editor on the parent community" do
      before { grant_access! editor_role, on: community, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: collection, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end
    end

    failed "as a random user with no permissions"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :create? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a manager on the parent community" do
      before { grant_access! manager_role, on: community, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end

      failed "on an unrelated collection" do
        let(:record) { other_collection }
      end
    end

    context "as an editor on the parent community" do
      before { grant_access! editor_role, on: community, to: user }

      failed "on a collection"
      failed "on a subcollection" do
        let(:record) { subcollection }
      end
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: collection, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
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

    context "as a manager on the parent community" do
      before { grant_access! manager_role, on: community, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end

      failed "on an unrelated collection" do
        let(:record) { other_collection }
      end
    end

    context "as an editor on the parent community" do
      before { grant_access! editor_role, on: community, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end

      failed "on an unrelated collection" do
        let(:record) { other_collection }
      end
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: collection, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
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

    context "as a manager on the parent community" do
      before { grant_access! manager_role, on: community, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end

      failed "on an unrelated collection" do
        let(:record) { other_collection }
      end
    end

    context "as an editor on the parent community" do
      before { grant_access! editor_role, on: community, to: user }

      failed "on a collection"
      failed "on a subcollection" do
        let(:record) { subcollection }
      end
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: collection, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end
    end

    failed "as a random user with no permissions"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :create_collections? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a manager on the parent community" do
      before { grant_access! manager_role, on: community, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end

      failed "on an unrelated collection" do
        let(:record) { other_collection }
      end
    end

    context "as an editor on the parent community" do
      before { grant_access! editor_role, on: community, to: user }

      failed "on a collection"
      failed "on a subcollection" do
        let(:record) { subcollection }
      end
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: collection, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end

      failed "on an unrelated collection" do
        let(:record) { other_collection }
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

    context "as a manager on the parent community" do
      before { grant_access! manager_role, on: community, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end

      failed "on an unrelated collection" do
        let(:record) { other_collection }
      end
    end

    context "as an editor on the parent community" do
      before { grant_access! editor_role, on: community, to: user }

      failed "on a collection"
      failed "on a subcollection" do
        let(:record) { subcollection }
      end
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: collection, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end

      failed "on an unrelated collection" do
        let(:record) { other_collection }
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

    context "as a manager on the parent community" do
      before { grant_access! manager_role, on: community, to: user }

      succeed "on a collection"
      succeed "on a subcollection" do
        let(:record) { subcollection }
      end

      failed "on an unrelated collection" do
        let(:record) { other_collection }
      end
    end

    context "as an editor on the parent community" do
      before { grant_access! editor_role, on: community, to: user }

      failed "on the collection"
      failed "on a subcollection" do
        let(:record) { subcollection }
      end
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: collection, to: user }

      failed "on the collection"
    end

    failed "as a random user with no permissions"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe "relation scope" do
    let(:target) { Collection.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

    context "as an admin" do
      let(:user) { admin }

      it "includes everything" do
        is_expected.to include collection, subcollection, other_collection
      end
    end

    context "as a random user" do
      before do
        other_collection.update!(visibility: :hidden)
      end

      it "excludes hidden records" do
        is_expected.to exclude(other_collection).and include(collection, subcollection)
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      before do
        other_collection.update!(visibility: :hidden)
      end

      it "excludes hidden records" do
        is_expected.to exclude(other_collection).and include(collection, subcollection)
      end
    end
  end
end
