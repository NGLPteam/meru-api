# frozen_string_literal: true

module Filtering
  TypeContainer = Support::DryGQL::TypeContainer.new.configure do |tc|
    tc.add! :any_entity, ::Entities::Types::Entity.gql_loads(::Types::EntityType)

    tc.add! :child_entity, ::Entities::Types::Entity.gql_loads(::Types::ChildEntityType)

    tc.add! :date_match, Filtering::Inputs::DateMatch

    tc.add! :float_match, Filtering::Inputs::FloatMatch

    tc.add! :integer_match, Filtering::Inputs::IntegerMatch

    tc.add! :time_match, Filtering::Inputs::TimeMatch

    tc.add_model! ::Collection
    tc.add_model! ::Community
    tc.add_model! ::Contributor
    tc.add_model! ::ControlledVocabulary
    tc.add_model! ::HarvestSource
    tc.add_model! ::Item
    tc.add_model! ::Permalink
    tc.add_model! ::Role
    tc.add_model! ::SchemaDefinition
    tc.add_model! ::SchemaVersion
    tc.add_enum! ::Types::HarvestMessageLevelType
  end
end
