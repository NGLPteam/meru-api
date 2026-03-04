# frozen_string_literal: true

RSpec.describe "Query.roles", type: :request do
  let_it_be(:query) do
    <<~GRAPHQL
    query getOrderedRoles($order: RoleOrder!) {
      roles(order: $order) {
        pageInfo {
          totalCount
        }

        edges {
          node {
            id
            name
          }
        }
      }
    }
    GRAPHQL
  end

  context "when ordering" do
    let_it_be(:role_admin, refind: true) { Role.fetch(:admin) }
    let_it_be(:role_manager, refind: true) { Role.fetch(:manager) }
    let_it_be(:role_editor, refind: true) { Role.fetch(:editor) }
    let_it_be(:role_reviewer, refind: true) { Role.fetch(:reviewer) }
    let_it_be(:role_depositor, refind: true) { Role.fetch(:depositor) }
    let_it_be(:role_reader, refind: true) { Role.fetch(:reader) }

    let_it_be(:role_a3, refind: true) do
      Timecop.freeze(3.days.ago) do
        FactoryBot.create :role, name: "AA", custom_priority: 100
      end
    end

    let_it_be(:role_m1, refind: true) do
      Timecop.freeze(1.day.ago) do
        FactoryBot.create :role, name: "MM", custom_priority: 300
      end
    end

    let_it_be(:role_z2, refind: true) do
      Timecop.freeze(2.days.ago) do
        FactoryBot.create :role, name: "ZZ", custom_priority: 200
      end
    end

    let_it_be(:keyed_models) do
      {
        admin: role_admin,
        manager: role_manager,
        editor: role_editor,
        reviewer: role_reviewer,
        depositor: role_depositor,
        reader: role_reader,
        a3: role_a3,
        m1: role_m1,
        z2: role_z2,
      }
    end

    let!(:order) { "RECENT" }

    let!(:graphql_variables) { { order: } }

    shared_examples_for "an ordered list of roles" do |order_value, kind, reverse = false|
      let!(:order) { order_value }

      let(:keys) do
        keyed_models.keys.sort do |akey, bkey|
          a = public_send(:"role_#{akey}")
          b = public_send(:"role_#{bkey}")

          a.sort_value_against(b, kind:, reverse:)
        end
      end

      let!(:roles_in_order) { keys.map { |k| keyed_models.fetch(k) } }

      let!(:expected_shape) do
        gql.query do |q|
          q.prop :roles do |roles|
            roles.prop :page_info do |pi|
              pi[:total_count] = keyed_models.size
            end

            roles.array :edges do |edges|
              roles_in_order.each do |role|
                edges.item do |edge|
                  edge.prop :node do |node|
                    node[:id] = role.to_encoded_id
                    node[:name] = role.name
                  end
                end
              end
            end
          end
        end
      end

      it "returns roles in the expected order" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end

    shared_examples_for "can fetch roles in any order" do
      {
        "DEFAULT" => [:priority, false],
        "RECENT" => [:created, true],
        "OLDEST" => [:created, false],
        "NAME_ASCENDING" => [:name, false],
        "NAME_DESCENDING" => [:name, true],
      }.each do |order, (kind, reverse)|
        context "when ordered by #{order}" do
          include_examples "an ordered list of roles", order, kind, reverse
        end
      end
    end

    as_an_admin_user do
      include_examples "can fetch roles in any order"
    end

    as_a_regular_user do
      include_examples "can fetch roles in any order"
    end

    as_an_anonymous_user do
      include_examples "can fetch roles in any order"
    end
  end
end
