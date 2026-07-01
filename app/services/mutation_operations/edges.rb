# frozen_string_literal: true

module MutationOperations
  # Logic for handling the loading and validation of a {Schemas::Edges::Edge}
  # between two entity-ish values in either a mutation's args or something
  # loaded in the `local_context`.
  #
  # The loading of the edges comes after `prepare!` is called, so any mutation that uses an edge
  # that relies on values in `local_context` needs to ensure they are set before then.
  module Edges
    extend ActiveSupport::Concern

    # A source within the mutation execution to
    # retrieve a given component of an edge.
    #
    # Can be one of `:args`, `:local_context`, or `:static`.
    EdgeSource = Dry::Types["symbol"].default(:args).enum(:args, :local_context, :static)

    def default_edge
      derived_edge :edge
    end

    # Fetch an edge by its key.
    #
    # @return [Schemas::Edges::Edge]
    def derived_edge(key = :edge)
      local_context[:edges].fetch(key)
    end

    # A hook called after the {MutationOperations::Base#prepare! prepare} step of a mutation.
    #
    # @api private
    # @see #load_and_validate_edge!
    # @return [void]
    def load_and_validate_edges!
      local_context[:edges] = {}

      self.class.edge_configurations.each_value do |edge_config|
        load_and_validate_edge! edge_config
      end

      local_context[:edges].freeze
    end

    # This will attempt to load an edge based on its configuration, retrieving
    # the values based on their respective `source`,
    #
    # @api private
    # @param [MutationOperations::Edges::EdgeConfiguration] config
    # @return [void]
    def load_and_validate_edge!(config)
      parent = retrieve_edge_arg_from config.parent

      child = retrieve_edge_arg_from config.child

      if parent.blank? || child.blank?
        # simplecov:disable
        return set_blank_edge_for! config if config.skip_blank?

        raise GraphQL::ExecutionError.new("Cannot derive edge for #{config.inspect}")
        # simplecov:enable
      end

      validate_edge(parent, child) do |m|
        m.edge do |edge|
          set_edge_for! config, edge
        end

        m.unacceptable do |invalid|
          message = I18n.t("dry_validation.errors.unacceptable_edge", parent: invalid.parent, child: invalid.child)

          add_global_error! message
        end

        m.incomprehensible do |error|
          # simplecov:disable
          add_global_error! error.to_s
          # simplecov:enable
        end
      end
    end

    # @api private
    # @param [Schemas::Types::Kind] parent
    # @param [Schemas::Types::Kind] child
    # @yield [matcher] Yields a `dry-matcher` with three possible cases: `edge`, `unacceptable`, `incomprehensible`.
    # @yieldparam [Schemas::Edges::Matcher] matcher a dry-matcher
    # @yieldreturn [void]
    # @return [void]
    def validate_edge(parent, child, &)
      MeruAPI::Container["schemas.edges.validate"].call(parent, child, &)
    end

    # Retrieve the entity-ish value from a given `source` based on its `key`
    #
    # @api private
    # @param [MutationOperations::Edges::ConnectionConfig] component
    # @return [Object] an object suitable for consumption by {Schemas::Types::Kind}
    def retrieve_edge_arg_from(component)
      case component.source
      when :args
        local_context[:args][component.key]
      when :local_context
        local_context[component.key]
      when :static
        Schemas::Types::Kind[component.key]
      end
    end

    # @api private
    # @param [MutationOperations::Edges::EdgeConfiguration] config
    # @param [Schemas::Edges::Edge, nil] value
    # @return [void]
    def set_edge_for!(config, value)
      local_context[:edges][config.key] = value

      return value
    end

    # @api private
    # @param [MutationOperations::Edges::EdgeConfiguration] config
    # @return [void]
    def set_blank_edge!(config)
      set_edge_for! config, nil
    end

    # @!group Execution Helpers

    # Build the attributes necessary to assign a child to a parent.
    #
    # @see Schemas::Edges::ChildAttributesBuilder
    # @param [Community, Collection, Item] parent
    # @param [Schemas::Edges::Edge] edge
    # @return [Hash]
    def child_attributes_for(parent, edge: default_edge)
      Schemas::Edges::ChildAttributesBuilder.new(parent, edge).call
    end

    # @!endgroup

    module ClassMethods
      # Add an edge to be loaded after the `prepare` step completes.
      #
      # This generates a {MutationOperations::Edges::EdgeConfiguration} which will be
      # {MutationOperations::Edges#load_and_validate_edge! loaded and validated}.
      #
      # @note Successive calls of `derives_edge!` with the same `on` value will overwrite the previous.
      # @note While the actual execution of the mutation will be prevented if an edge is invalid,
      #   contracts will continue to run. Any contract that depends on an edge being available needs
      #   to account for the possibility that it is unset.
      # @param [Symbol] parent the name of the key to retrieve the parent of the edge
      # @param [Symbol] child the name of the key to retrieve the child of the edge
      # @param [MutationOperations::Edges::EdgeSource] parent_source where the value for the `parent` key should be retrieved from.
      # @param [MutationOperations::Edges::EdgeSource] child_source where the value for the `child` key should be retrieved from.
      # @param [Boolean] skip_blank if either side of the edge cannot be found, it will normally raise an error. If it's possible
      #   for either value to be blank, set this to true and handle the case in a later contract or during the mutation itself.
      # @param [Symbol] on the key under which to store the edge, in the case that multiple edges need be loaded.
      # @return [void]
      def derives_edge!(parent: :parent, child: :child, parent_source: :args, child_source: :args, skip_blank: false, on: :edge)
        config = EdgeConfiguration.new(
          key: on,
          skip_blank:,
          parent: build_edge_component(parent, parent_source, :parent),
          child: build_edge_component(child, child_source, :child),
        )

        edge_configurations[on] = config
      end

      # @api private
      # @return [{ Symbol => MutationOperations::Edges::EdgeConfiguration }]
      def edge_configurations
        @edge_configurations ||= {}
      end

      private

      def build_edge_component(key, source, type)
        valid_key = validate_edge_component_key key, source, type

        ConnectionConfig.new key: valid_key, source:, type:
      end

      def validate_edge_component_key(key, source, type)
        case source
        when :static
          begin
            Schemas::Types::Kind[key].to_sym
          rescue Dry::Types::ConstraintError
            raise "Invalid static #{type} type: #{key.inspect}"
          end
        else
          key
        end
      end
    end

    # @api private
    class ConnectionConfig < Dry::Struct
      attribute :source, MutationOperations::Edges::EdgeSource

      attribute :key, Dry::Types["symbol"]

      attribute :type, Schemas::Associations::Types::ConnectionType
    end

    # A configuration generated by {MutationOperations::Edges::ClassMethods#derive_edge!}
    # that tells a mutation how to load any given edge(s) during its execution.
    #
    # @api private
    class EdgeConfiguration < Dry::Struct
      attribute :key, Dry::Types["symbol"].default(:edge)
      attribute :skip_blank, Dry::Types["bool"].default(false)

      attribute :parent, ConnectionConfig
      attribute :child, ConnectionConfig

      alias skip_blank? skip_blank
    end
  end
end
