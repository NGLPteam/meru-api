# frozen_string_literal: true

RSpec.describe EntityPolicy, type: :policy do
  include_context "policy setup"

  let_it_be(:editor_role, refind: true) { FactoryBot.create :role, :editor }

  let_it_be(:community, refind: true) { FactoryBot.create :community }

  let_it_be(:collection, refind: true) { FactoryBot.create :collection, community: }

  let_it_be(:other_item, refind: true) { FactoryBot.create :item }

  let_it_be(:entity, refind: true) { collection.entity }

  let(:record) { entity }

  describe_rule :read? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :show? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a regular user" do
      let(:user) { regular_user }
    end

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end

    context "when the entity is hidden" do
      before do
        collection.update!(visibility: "hidden")
      end

      succeed "as an admin" do
        let(:user) { admin }
      end

      failed "as a regular user" do
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

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :update? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :destroy? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe "relation scope" do
    let(:target) { Entity.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

    context "as an admin" do
      let(:user) { admin }

      it "includes everything" do
        is_expected.to include entity
      end
    end

    context "as a user with all contextual permissions" do
      before do
        grant_access! editor_role, on: collection, to: user

        other_item.update!(visibility: :hidden)
      end

      it "excludes hidden records outside of the user's purview" do
        is_expected.to exclude(other_item).and include(entity)
      end
    end

    context "as a random user" do
      before do
        other_item.update!(visibility: :hidden)
      end

      it "excludes hidden records" do
        is_expected.to exclude(other_item).and include(entity)
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      before do
        other_item.update!(visibility: :hidden)
      end

      it "excludes hidden records" do
        is_expected.to exclude(other_item).and include(entity)
      end
    end
  end
end
