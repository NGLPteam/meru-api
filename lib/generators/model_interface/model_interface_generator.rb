# frozen_string_literal: true

require_relative "../../support/system"

class ModelInterfaceGenerator < Rails::Generators::NamedBase
  include Support::GeneratesCommonFields
  include Support::GeneratesGQLFields

  source_root File.expand_path("templates", __dir__)

  class_option :filters, type: :boolean, default: false,
    description: "Whether to create a filter scope"

  class_option :default_order, type: :boolean, default: true
  class_option :order_enum, type: :boolean, default: true
  class_option :simply_ordered, type: :boolean, default: true
  class_option :skip_resolver, type: :boolean, default: false

  def create_order_enum!
    return unless use_custom_enum?

    template "order_enum.rb", Rails.root.join("app/graphql/types", "#{order_enum_file}.rb")
  end

  def create_order_concern!
    return unless use_custom_enum?

    template "order_concern.rb", Rails.root.join("app/services/resolvers", "#{order_concern_file}.rb")
  end

  def create_filter_scope!
    return unless using_filters?

    template "filter_scope.rb", Rails.root.join("app/services/filtering/scopes", "#{filter_scope_name.underscore}.rb")
  end

  def create_resolver!
    return if skip_resolver?

    template "resolver.rb", Rails.root.join("app/services/resolvers", "#{resolver_file}.rb")
  end

  def create_selector_input!
    return unless has_unique_identifier?

    template "selector_input.rb", Rails.root.join("app/graphql/types", "#{selector_input_file}.rb")
  end

  def create_query_interface!
    template "query_interface.rb", Rails.root.join("app/graphql/types", "#{query_interface_file}.rb")
  end

  def create_specs!
    template "collection_spec.rb", Rails.root.join(spec_path, "query", "#{field_collection_name}_spec.rb")
    template "single_spec.rb", Rails.root.join(spec_path, "query", "#{field_single_name}_spec.rb")
  end

  def expose_in_query!
    inject_query!(<<~RUBY)
    implements #{query_interface_klass}
    RUBY
  end

  private

  def spec_path
    "spec/requests/graphql"
  end

  def field_collection_name
    model_key_plural
  end

  def field_single_name
    model_key_singular
  end

  def filter_scope_name
    @filter_scope_name ||= model_name.pluralize
  end

  def graphql_collection_field_name
    field_collection_name.to_s.camelize(:lower)
  end

  def graphql_collection_var_declaration
    @graphql_collection_var_declaration ||= [].tap do |arr|
      if options[:order_enum]
        arr << "$order: #{order_enum_graphql_name}" if options[:order_enum]
      elsif simply_ordered?
        arr << "$order: SimpleOrder"
      end
    end.join(", ")
  end

  def graphql_collection_vars
    @graphql_collection_vars ||= [].tap do |arr|
      arr << "order: $order" if options[:order_enum] || simply_ordered?
    end.join(", ")
  end

  def graphql_model_klass
    "Types::#{model_name}Type"
  end

  def graphql_single_field_name
    field_single_name.to_s.camelize(:lower)
  end

  def has_default_order?
    options[:default_order]
  end

  def human_models
    @human_models ||= model_name.underscore.humanize(capitalize: false).pluralize
  end

  def target_query
    "app/graphql/types/query_type.rb"
  end

  def using_filters?
    options[:filters]
  end

  def inject_query!(text)
    query_path = Rails.root.join(target_query)
    query_content = File.read(query_path)

    # Extract existing implementations between the group markers
    implementations_match = query_content.match(/# @!group Query Implementations\n(.*?)# @!endgroup Query Implementations/m)

    unless implementations_match
      # Fallback to old behavior if markers not found
      inject_into_file target_query, before: "    # @!endgroup Query Implementations\n" do
        text.indent(4)
      end
      return
    end

    implementations_section = implementations_match[1]
    existing_implementations = implementations_section.scan(/implements (Types::Queries\w+)/).flatten

    # Get the new interface name and determine insertion point
    new_interface = query_interface_klass
    all_implementations = (existing_implementations + [new_interface]).sort
    insert_index = all_implementations.index(new_interface)

    # Determine what to insert before
    if insert_index == all_implementations.length - 1
      # Insert at the end, before the endgroup comment
      inject_into_file target_query, before: "\n    # @!endgroup Query Implementations" do
        text.indent(4)
      end
    else
      # Insert before the next implementation in alphabetical order
      next_implementation = all_implementations[insert_index + 1]
      inject_into_file target_query, before: "    implements #{next_implementation}\n" do
        text.indent(4)
      end
    end
  end

  def model_factory
    model_key_singular
  end

  def model_key_plural
    name_helper.plural.to_sym
  end

  def model_key_singular
    name_helper.singular.to_sym
  end

  def model_name
    class_name
  end

  def name_helper
    @name_helper ||= ActiveModel::Name.new(nil, nil, model_name)
  end

  def order_concern_file
    order_concern_name.underscore
  end

  def order_concern_klass
    "Resolvers::#{order_concern_name}"
  end

  def order_concern_name
    "OrderedAs#{model_name}"
  end

  def order_enum_file
    order_enum_name.underscore
  end

  def order_enum_graphql_name
    "#{model_name}Order"
  end

  def order_enum_klass
    "Types::#{order_enum_name}"
  end

  def order_enum_name
    "#{order_enum_graphql_name}Type"
  end

  def query_interface_file
    query_interface_name.underscore
  end

  def query_interface_klass
    "Types::#{query_interface_name}"
  end

  def query_interface_name
    "Queries#{model_name}"
  end

  def selector_input_file
    selector_input_name.underscore
  end

  def selector_input_graphql_name
    "#{model_name}SelectorInput"
  end

  def selector_input_klass
    "Types::#{selector_input_name}"
  end

  def selector_input_name
    "#{model_name}SelectorInputType"
  end

  def skip_resolver?
    options[:skip_resolver]
  end

  def skip_ensure_model_type?
    options[:skip_ensure_model_type]
  end

  def simply_ordered?
    options[:simply_ordered]
  end

  def resolver_file
    resolver_name.underscore
  end

  def resolver_klass
    "Resolvers::#{resolver_name}"
  end

  def resolver_name
    "#{model_name}Resolver"
  end

  def use_custom_enum?
    options[:order_enum]
  end

  def use_resolver?
    !skip_resolver?
  end
end
