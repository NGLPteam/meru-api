# frozen_string_literal: true

module TestHelpers
  module SimpleV1Hierarchy
    def create_v1_community(*traits, **attributes)
      attributes.delete :schema
      attributes[:schema_version] = simple_community_v1

      FactoryBot.create :community, *traits, **attributes
    end

    def create_v1_collection(*traits, **attributes)
      attributes.delete :schema
      attributes[:schema_version] = simple_collection_v1

      if attributes[:parent].present?
        attributes[:community] = attributes[:parent].community
      elsif attributes[:community].blank?
        attributes[:community] = create_v1_community
      end

      FactoryBot.create :collection, *traits, **attributes
    end

    def create_v1_item(*traits, **attributes)
      attributes.delete :schema
      attributes[:schema_version] = simple_item_v1

      if attributes[:parent].present?
        attributes[:collection] = attributes[:parent].collection
      elsif attributes[:collection].blank?
        attributes[:collection] = create_v1_collection
      end

      FactoryBot.create :item, *traits, **attributes
    end
  end
end

RSpec.shared_context "a simple v1 hierarchy" do
  include TestHelpers::SimpleV1Hierarchy

  let_it_be(:simple_community_v1, refind: true) { FactoryBot.create :schema_version, :simple_community, :v1 }
  let_it_be(:simple_collection_v1, refind: true) { FactoryBot.create :schema_version, :simple_collection, :v1 }
  let_it_be(:simple_item_v1, refind: true) { FactoryBot.create :schema_version, :simple_item, :v1 }

  let(:v1_schemas) do
    {
      community: simple_community_v1,
      collection: simple_collection_v1,
      item: simple_item_v1,
    }.with_indifferent_access
  end

  let_it_be(:collection, refind: true) { FactoryBot.create :collection, schema_version: simple_collection_v1 }
end

RSpec.configure do |config|
  config.include TestHelpers::SimpleV1Hierarchy, simple_v1_hierarchy: true
  config.include_context "a simple v1 hierarchy", simple_v1_hierarchy: true
end
