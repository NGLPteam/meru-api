# frozen_string_literal: true

RSpec.describe "Query.users", type: :request do
  graphql_query! <<~GRAPHQL
  query getOrderedUsers($order: UserOrder!, $prefix: String) {
    users(order: $order, prefix: $prefix) {
      edges {
        node {
          id
          name
          globalAdmin
        }
      }

      pageInfo {
        totalCount
        totalUnfilteredCount
      }
    }
  }
  GRAPHQL

  let_it_be(:user_admin) { fixture(:admin_user) }

  let_it_be(:user_aa) do
    Timecop.freeze(3.days.ago) do
      FactoryBot.create :user, given_name: "AA", family_name: "AA", email: "aa@example.com", metadata: { testing: false }
    end
  end

  let_it_be(:user_zz) do
    Timecop.freeze(2.days.ago) do
      FactoryBot.create :user, given_name: "ZZ", family_name: "ZZ", email: "zz@example.com", metadata: { testing: false }
    end
  end

  let_it_be(:user_test) { fixture(:regular_user) }

  let!(:keyed_users) do
    {
      admin:,
      aa:,
      test:,
      zz:,
    }
  end

  let!(:admin) { to_rep user_admin }
  let!(:aa) { to_rep user_aa }
  let!(:test) { to_rep user_test }
  let!(:zz) { to_rep user_zz }

  let!(:order) { "RECENT" }

  let(:search_prefix) { nil }

  let!(:graphql_variables) { { order:, prefix: search_prefix } }

  # We gotta make sure our fixture users are not included in the query
  # @todo in the future, test resolvers directly instead of through the GraphQL API, so we can avoid this
  around do |example|
    User.lock_to!(user_admin, user_aa, user_test, user_zz) do
      example.run
    end
  end

  def shape_for(*keys)
    keys.flatten!

    gql.query do |q|
      q.prop :users do |u|
        u.array :edges do |e|
          keys.each do |k|
            e.item do |n|
              n[:node] = keyed_users.fetch k
            end
          end
        end

        u.prop :page_info do |pi|
          pi[:total_count] = keys.size
          pi[:total_unfiltered_count] = keyed_users.size
        end
      end
    end
  end

  def to_rep(user)
    user.slice(:name).merge(id: user.to_encoded_id, global_admin: user.has_global_admin_access?)
  end

  context "when ordering" do
    let(:token) { token_helper.build_token from_user: user_admin }

    shared_examples_for "an ordered list of users" do |order_value, *keys|
      let!(:order) { order_value }

      let!(:expected_shape) do
        shape_for(*keys)
      end

      it "returns users in the expected order" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end

    {
      "RECENT" => %i[test zz aa admin],
      "OLDEST" => %i[admin aa zz test],
      "ADMINS_FIRST" => %i[admin aa zz test],
      "ADMINS_RECENT" => %i[admin zz aa test],
      "NAME_ASCENDING" => %i[aa admin test zz],
      "NAME_DESCENDING" => %i[zz test admin aa],
      "EMAIL_ASCENDING" => %i[aa admin test zz],
      "EMAIL_DESCENDING" => %i[zz test admin aa],
    }.each do |order, keys|
      context "when ordered by #{order}" do
        include_examples "an ordered list of users", order, *keys
      end
    end

    context "when filtered by prefix" do
      let(:search_prefix) { "test" }
      let(:expected_shape) { shape_for(:test) }

      it "returns only the filtered user" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end
  end
end
