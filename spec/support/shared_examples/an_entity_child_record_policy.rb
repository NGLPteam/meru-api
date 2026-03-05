# frozen_string_literal: true

RSpec.shared_examples_for "an entity child record policy" do
  include_context "policy setup"

  let_it_be(:community, refind: true) { FactoryBot.create :community }
  let_it_be(:collection, refind: true) { FactoryBot.create :collection }

  let_it_be(:editor_role, refind: true) { FactoryBot.create :role, :editor }

  let(:entity) { collection }

  let!(:record) { raise "must override in the including spec" }

  describe_rule :show? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a user with contextual permissions" do
      before { grant_access! editor_role, on: entity, to: user }
    end

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end

    context "when the entity is a community" do
      let(:entity) { community }

      succeed "as an admin" do
        let(:user) { admin }
      end

      succeed "as a user with contextual permissions" do
        before { grant_access! editor_role, on: entity, to: user }
      end

      succeed "as an anonymous user" do
        let(:user) { anonymous_user }
      end
    end

    context "when the entity is hidden" do
      let(:entity) { FactoryBot.create :collection, :hidden }

      succeed "as an admin" do
        let(:user) { admin }
      end

      succeed "as a user with contextual permissions" do
        before { grant_access! editor_role, on: entity, to: user }
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

    succeed "as a user with contextual permissions" do
      before { grant_access! editor_role, on: entity, to: user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :create? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a user with contextual permissions" do
      before { grant_access! editor_role, on: entity, to: user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :update? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a user with contextual permissions" do
      before { grant_access! editor_role, on: entity, to: user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :destroy? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a user with contextual permissions" do
      before { grant_access! editor_role, on: entity, to: user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe "relation scope" do
    let(:target) { record.class.where(id: record.id) }

    subject { policy.apply_scope(target, type: :active_record_relation).pluck(:id) }

    context "as an admin" do
      let(:user) { admin }

      it "includes the record" do
        is_expected.to include record.id
      end
    end

    context "as a user with contextual permissions" do
      before { grant_access! editor_role, on: entity, to: user }

      it "includes the record" do
        is_expected.to include record.id
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      it "includes the record" do
        is_expected.to include record.id
      end
    end
  end
end
