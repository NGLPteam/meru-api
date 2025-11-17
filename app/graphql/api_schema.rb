# frozen_string_literal: true

# The entry point for the GraphQL schema.
#
# @see GraphqlController#execute
# @subsystem GraphQL
class APISchema < GraphQL::Schema
  if MeruConfig.experimental_dataloader?
    use CustomDataloader
  else
    use GraphQL::Batch
  end

  trace_with(GraphQL::Tracing::ActiveSupportNotificationsTrace)

  use GraphQL::FragmentCache

  mutation Types::MutationType

  query Types::QueryType

  default_max_page_size Support::GraphQLAPI::Constants::MAX_PER_PAGE_SIZE

  rescue_from(ActiveRecord::RecordNotFound) do |err, obj, args, ctx, field|
    # :nocov:
    raise GraphQL::ExecutionError, "#{field.type.unwrap.graphql_name} not found"
    # :nocov:
  end

  rescue_from(Pundit::NotAuthorizedError) do |_|
    # :nocov:
    GraphQL::ExecutionError.new(
      I18n.t("server_messages.auth.forbidden"),
      extensions: {
        code: "FORBIDDEN"
      }
    )
    # :nocov:
  end

  extra_types(
    Types::SchemaPropertyKindType,
    Types::Schematic::AssetPropertyType,
    Types::Schematic::AssetsPropertyType,
    Types::Schematic::BooleanPropertyType,
    Types::Schematic::ContributorPropertyType,
    Types::Schematic::ContributorsPropertyType,
    Types::Schematic::ControlledVocabulariesPropertyType,
    Types::Schematic::ControlledVocabularyPropertyType,
    Types::Schematic::DatePropertyType,
    Types::Schematic::EmailPropertyType,
    Types::Schematic::EntitiesPropertyType,
    Types::Schematic::EntityPropertyType,
    Types::Schematic::FloatPropertyType,
    Types::Schematic::FullTextPropertyType,
    Types::Schematic::GroupPropertyType,
    Types::Schematic::HasAvailableEntitiesType,
    Types::Schematic::HasControlledVocabularyType,
    Types::Schematic::IntegerPropertyType,
    Types::Schematic::MarkdownPropertyType,
    Types::Schematic::MultiselectPropertyType,
    Types::Schematic::OptionablePropertyType,
    Types::Schematic::ScalarPropertyType,
    Types::Schematic::SchemaPropertyType,
    Types::Schematic::SelectOptionType,
    Types::Schematic::SelectPropertyType,
    Types::Schematic::StringPropertyType,
    Types::Schematic::TagsPropertyType,
    Types::Schematic::TimestampPropertyType,
    Types::Schematic::UnknownPropertyType,
    Types::Schematic::URLPropertyType,
    Types::Schematic::VariableDatePropertyType,
    Types::AnyChildEntityType,
    Types::AnyContributableType,
    Types::AnyContributionType,
    Types::AnyContributorAttributionType,
    Types::AnyContributorType,
    Types::AnyEntityType,
    Types::AnyOrderingPathType,
    Types::AnyScalarPropertyType,
    Types::AnySchemaPropertyType,
    Types::ContributorType,
    Types::ContributorBaseType,
    Types::ContributorAttributionType,
    Types::ContributorAttributionConnectionType,
    Types::ContributorAttributionEdgeType,
    Types::ContributorCollectionAttributionType,
    Types::ContributorItemAttributionType,
    Types::EntityType,
    Types::OrderingPathType,
    Types::OrganizationContributorType,
    Types::PersonContributorType,
    Types::SearchResultType,
    Types::SchemaPropertyTypeType,
    Types::SchemaInstanceType,
    Types::TemplateContributionType
  )

  orphan_types(
    *Types::AnyOrderingPathType.possible_types,
    Types::Schematic::AssetPropertyType,
    Types::Schematic::AssetsPropertyType,
    Types::Schematic::BooleanPropertyType,
    Types::Schematic::ContributorPropertyType,
    Types::Schematic::ContributorsPropertyType,
    Types::Schematic::ControlledVocabulariesPropertyType,
    Types::Schematic::ControlledVocabularyPropertyType,
    Types::Schematic::DatePropertyType,
    Types::Schematic::EmailPropertyType,
    Types::Schematic::EntitiesPropertyType,
    Types::Schematic::EntityPropertyType,
    Types::Schematic::FloatPropertyType,
    Types::Schematic::FullTextPropertyType,
    Types::Schematic::GroupPropertyType,
    Types::Schematic::IntegerPropertyType,
    Types::Schematic::MarkdownPropertyType,
    Types::Schematic::MultiselectPropertyType,
    Types::Schematic::SelectOptionType,
    Types::Schematic::SelectPropertyType,
    Types::Schematic::StringPropertyType,
    Types::Schematic::TagsPropertyType,
    Types::Schematic::TimestampPropertyType,
    Types::Schematic::UnknownPropertyType,
    Types::Schematic::URLPropertyType,
    Types::Schematic::VariableDatePropertyType,
    Types::ContributorCollectionAttributionType,
    Types::ContributorItemAttributionType,
    Types::OrganizationContributorType,
    Types::PersonContributorType,
    Types::SearchResultType
  )

  class << self
    def id_from_object(object, type_definition, query_context)
      Support::System["relay_node.id_from_object"].call(object, type_definition:, query_context:) do |m|
        m.success do |id|
          id
        end

        m.failure do
          # :nocov:
          raise GraphQL::ExecutionError.new("Cannot derive ID")
          # :nocov:
        end
      end
    end

    def object_from_id(id, query_context)
      Support::System["relay_node.object_from_id"].call(id, query_context:) do |m|
        m.success do |object|
          object
        end

        m.failure do
          # :nocov:
          raise GraphQL::ExecutionError.new("Cannot find model for ID: #{id.inspect}")
          # :nocov:
        end
      end
    end

    def resolve_type(abstract_type, object, context)
      # Remap arg order because we really mainly care about object
      Support::System["relay_node.resolve_type"].call(object, abstract_type, context).value_or do |reason|
        # :nocov:
        opts = {
          extensions: { abstract_type: abstract_type&.graphql_name }
        }

        case reason
        when GraphQL::ExecutionError then reason
        when String then GraphQL::ExecutionError.new(reason, **opts)
        else
          raise GraphQL::ExecutionError.new("Unexpected object: #{object.inspect}", **opts)
        end
        # :nocov:
      end
    end
  end
end
