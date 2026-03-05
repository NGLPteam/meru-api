# frozen_string_literal: true

module Types
  # An override of the default Relay PageInfo type to add additional fields
  # for page-based pagination.
  class PageInfoType < Types::AbstractObjectType
    include GraphQL::Types::Relay::PageInfoBehaviors

    field :page, Integer, null: true do
      description "The page (if page-based pagination is supported and one was provided, does not introspect a value with cursor-based pagination)"
    end

    field :page_count, Integer, null: true do
      description "The total number of pages available to the connection (if page-based pagination supported and a page was provided)"
    end

    field :per_page, Integer, null: true do
      description "The number of edges/nodes per page (if page-based pagination supported and a page was provided)"
    end

    field :total_count, Integer, null: false do
      description "The total number of nodes available to this connection, constrained by applied filters (if any)"
    end

    field :total_unfiltered_count, Integer, null: false do
      description "The total number of nodes available to this connection, independent of any filters"
    end

    # @return [Integer, nil]
    def page
      from_info :page
    end

    # @return [Integer, nil]
    def page_count
      # :nocov:
      return nil if per_page.nil?
      # :nocov:

      size = total_count

      return 0 if size.zero?

      full_pages, rem = size.divmod per_page

      rem > 0 ? full_pages + 1 : full_pages
    end

    # @return [Integer, nil]
    def per_page
      from_info :per_page
    end

    # @return [Integer]
    def total_count
      from_connection_info(:total_count) do
        object.items.count_from_subquery
      end
    end

    # @return [Integer]
    def total_unfiltered_count
      from_connection_info(:unfiltered_count) do
        from_resolver(:unfiltered_count) { total_count }
      end
    end

    private

    # @param [Symbol] key
    # @return [Object]
    def from_connection_info(key)
      object.context[:connection_info].then do |cinfo|
        # :nocov:
        cinfo&.__send__(key) || yield
        # :nocov:
      end
    end

    # @param [Symbol] key
    # @return [Object]
    def from_info(key)
      object.context[:pagination].then do |pagination|
        if pagination.kind_of?(Hash)
          pagination[key]
        else
          # :nocov:
          object.arguments[key]
          # :nocov:
        end
      end
    end

    # @param [Symbol] method_name
    # @return [Object]
    def from_resolver(method_name, &)
      object.context[:resolver].try(method_name).then do |value|
        value.presence || yield
      end
    end
  end
end
