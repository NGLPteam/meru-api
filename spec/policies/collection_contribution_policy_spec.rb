# frozen_string_literal: true

RSpec.describe CollectionContributionPolicy, type: :policy do
  let_it_be(:community, refind: true) { FactoryBot.create :community }

  let_it_be(:editor_role, refind: true) { FactoryBot.create :role, :editor }

  let_it_be(:reader_role, refind: true) { FactoryBot.create :role, :reader }

  let_it_be(:collection, refind: true) { FactoryBot.create :collection, community: }
  let_it_be(:contributor, refind: true) { FactoryBot.create :contributor, :person }

  let_it_be(:hidden_collection, refind: true) { FactoryBot.create :collection, :hidden, community: }

  let_it_be(:hidden_collection_contribution, refind: true) { FactoryBot.create :collection_contribution, collection: hidden_collection, contributor: }

  let_it_be(:collection_contribution, refind: true) { FactoryBot.create :collection_contribution, collection:, contributor: }

  let(:record) { collection_contribution }

  shared_examples_for "publicly accessible permission" do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a regular user" do
      let(:user) { regular_user }
    end

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end

    context "when the contributable is hidden" do
      let(:record) { hidden_collection_contribution }

      succeed "as an admin" do
        let(:user) { admin }
      end

      succeed "as an editor with an inherited role" do
        before { grant_access! editor_role, on: community, to: user }
      end

      succeed "as a reader with an inherited role" do
        before { grant_access! reader_role, on: community, to: user }
      end

      failed "as a regular user" do
        let(:user) { regular_user }
      end

      failed "as an anonymous user" do
        let(:user) { anonymous_user }
      end
    end
  end

  shared_examples_for "a permission that requires reader access to the collection" do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as an editor" do
      before do
        grant_access! editor_role, on: collection, to: user
      end
    end

    succeed "as a reader" do
      before do
        grant_access! reader_role, on: collection, to: user
      end
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  shared_examples_for "a permission that requires update access to the collection" do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as an editor" do
      before do
        grant_access! editor_role, on: collection, to: user
      end
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :read? do
    include_examples "a permission that requires reader access to the collection"
  end

  describe_rule :show? do
    include_examples "publicly accessible permission"
  end

  describe_rule :create? do
    include_examples "a permission that requires update access to the collection"
  end

  describe_rule :update? do
    include_examples "a permission that requires update access to the collection"
  end

  describe_rule :destroy? do
    include_examples "a permission that requires update access to the collection"
  end

  describe "relation scope" do
    let(:target) { CollectionContribution.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

    context "as an admin" do
      let(:user) { admin }

      it "includes everything" do
        is_expected.to include record
      end
    end

    context "as an editor with an inherited role" do
      before { grant_access! editor_role, on: community, to: user }

      it "includes accessible records" do
        is_expected.to include(record)
      end

      it "includes hidden records" do
        is_expected.to include(hidden_collection_contribution)
      end
    end

    context "as a reader with an inherited role" do
      before { grant_access! reader_role, on: community, to: user }

      it "includes accessible records" do
        is_expected.to include(record)
      end

      it "includes hidden records" do
        is_expected.to include(hidden_collection_contribution)
      end
    end

    context "as a regular user" do
      it "includes accessible records" do
        is_expected.to include(record)
      end

      it "excludes inaccessible records" do
        is_expected.not_to include(hidden_collection_contribution)
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      it "includes accessible records" do
        is_expected.to include(record)
      end

      it "excludes inaccessible records" do
        is_expected.not_to include(hidden_collection_contribution)
      end
    end
  end
end
