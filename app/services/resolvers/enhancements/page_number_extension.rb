# frozen_string_literal: true

module Resolvers
  module Enhancements
    # This extension works on connection resolvers to support adding page-based pagination
    # that works in concert with graphql-ruby's existing opaque cursor-based offset pagination.
    # Should the underlying logic in that ever change, we'll need to adjust this. As it stands,
    # it works very efficiently.
    class PageNumberExtension < GraphQL::Schema::FieldExtension
      include Support::GraphQLAPI::Constants

      # @return [void]
      def apply
        resolver = options[:resolver]

        max_page_size = resolver.has_max_page_size? ? resolver.max_page_size : MAX_PER_PAGE_SIZE

        field.argument :page, Integer, required: false do
          description "The page of edges/nodes to fetch"

          validates numericality: { allow_blank: true, greater_than_or_equal_to: 1 }
        end

        field.argument :page_direction, ::Types::PageDirectionType, required: false, default_value: :forwards, replace_null_with_default: true do
          description "The direction in which pages advance (to traverse pages backwards)"
        end

        field.argument :per_page, Integer, required: false do
          description "The amount of edges / nodes to fetch per page"

          validates numericality: {
            allow_blank: true,
            greater_than_or_equal_to: 1,
            less_than_or_equal_to: max_page_size,
          }
        end
      end

      # @return [void]
      def resolve(object:, arguments:, context:, **rest)
        cleaned_args = arguments.dup

        page = cleaned_args.delete(:page)
        page_direction = cleaned_args[:page_direction]
        per_page = cleaned_args.delete(:per_page)

        cursor_name = page_direction == :backwards ? :before : :after
        limit_name = page_direction == :backwards ? :last : :first

        # perPage was set without page, or page was set without perPage
        if page.present? ^ per_page.present?
          page ||= 1
          per_page ||= DEFAULT_PER_PAGE_SIZE
        end

        raise GraphQL::ExecutionError, "Cannot specify both page and before/after cursor" if exclusive_options?(page, context)

        # Update to make sure our inconsistencies are accounted for
        cleaned_args[:page] = page

        cleaned_args[:per_page] = per_page

        info = { page:, per_page:, page_direction: }

        if page.present?
          info[cursor_name] = calculate_cursor page, per_page
          info[limit_name] = per_page
        end

        info.freeze

        context.scoped_set! :resolver, options[:resolver].new(object: object.object, context:)

        context.scoped_set! :pagination, info

        yield object, cleaned_args, info
      end

      # @see apply_page_based_pagination!
      # @param [GraphQL::Pagination::ActiveRecordRelationConnection] value
      # @param [{ Symbol => Object }] memo
      # @return [GraphQL::Pagination::ActiveRecordRelationConnection]
      def after_resolve(value:, memo:, **rest)
        apply_page_based_pagination! value, memo

        value
      end

      def exclusive_options?(page, context)
        return false if page.blank?

        args = context[:current_arguments].to_h

        %i[before after].any? { |cursor| cursor.in?(args) }
      end

      # We need to override certain keys in the connection with the values calculated
      # in {#resolve}.
      #
      # @api private
      # @param [GraphQL::Pagination::ActiveRecordRelationConnection] connection
      # @param [{ Symbol => Object }] settings
      # @return [void]
      def apply_page_based_pagination!(connection, settings)
        settings.each do |key, value|
          case key
          when :before
            connection.before_value = value
          when :after
            connection.after_value = value
          when :first
            connection.first_value = value
          when :last
            connection.last_value = value
          end
        end
      end

      # Calculate the offset to the current page, given the following formula:
      #
      # ```ruby
      # (page - 1) * per_page
      # ```
      #
      # @api private
      # @param [Integer] page
      # @param [Integer] per_page
      # @return [Integer]
      def calculate_cursor(page, per_page)
        zero_based_page = page - 1

        offset = zero_based_page * per_page

        encode_cursor offset
      end

      # @api private
      # @param [#to_s] value
      # @return [String]
      def encode_cursor(value)
        APISchema.cursor_encoder.encode value.to_s
      end
    end
  end
end
