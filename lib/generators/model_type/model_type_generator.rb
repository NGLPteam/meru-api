# frozen_string_literal: true

require_relative "../../support/system"

class ModelTypeGenerator < Rails::Generators::NamedBase
  include Support::GeneratesCommonFields
  include Support::GeneratesGQLFields

  source_root File.expand_path("templates", __dir__)

  class_option :interfaces, type: :array, default: []
  class_option :use_direct_connection_and_edge, type: :boolean, default: false

  def create_type!
    template "model.rb", Rails.root.join("app/graphql/types", "#{graphql_file_name}.rb")
  end

  def create_connection_and_edge!
    return unless use_direct_connection_and_edge?

    template "connection.rb", Rails.root.join("app/graphql/types", "#{connection_type_name.underscore}.rb")

    template "edge.rb", Rails.root.join("app/graphql/types", "#{edge_type_name.underscore}.rb")
  end

  private

  def connection_type_name
    "#{class_name}ConnectionType"
  end

  def edge_type_name
    "#{class_name}EdgeType"
  end

  def full_connection_type_name
    "::Types::#{connection_type_name}"
  end

  def full_edge_type_name
    "::Types::#{edge_type_name}"
  end

  def full_node_type_name
    "::Types::#{graphql_type_name}"
  end

  def has_interfaces?
    interfaces.present?
  end

  # @return []
  def interfaces
    @interfaces ||= build_interfaces
  end

  def graphql_file_name
    graphql_type_name.underscore
  end

  def graphql_type_name
    "#{class_name}Type"
  end

  def model_name
    class_name
  end

  def build_interfaces
    [].tap do |arr|
      arr.concat options[:interfaces]

      arr << "Types::DerivesIdentifierFromNameType" if derives_identifier_from_name?

      arr << "Types::HasNameType" if has_name?

      arr << "Types::HasUniqueIdentifierType" if has_unique_identifier?
    end.sort
  end

  def use_direct_connection_and_edge?
    options[:use_direct_connection_and_edge]
  end
end
