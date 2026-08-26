# frozen_string_literal: true

module Processing
  module ModelIntegration
    extend ActiveSupport::Concern
    extend Support::Typing
    extend DefinesMonadicOperation

    include Support::ClassyList::DSL

    STALE_TIME = 15.minutes

    included do
      has_simple_symbol_list! :shrine_attachments
    end

    # @param [Symbol] name
    # @see Processing::PromoteAttachment
    # @see Processing::AttachmentPromoter
    # @return [Dry::Monads::Success(ApplicationRecord)]
    monadic_operation! def promote_attachment(name, **options)
      call_operation("processing.promote_attachment", self, name, **options)
    end

    # @param [Symbol] name
    # @see Processing::RefreshDerivatives
    # @see Processing::DerivativesRefresher
    # @return [Dry::Monads::Success(ApplicationRecord)]
    monadic_operation! def refresh_attachment_derivatives(name, **options)
      call_operation("processing.refresh_derivatives", self, name, **options)
    end

    # @param [Symbol] name
    # @see Processing::RefreshMetadata
    # @see Processing::MetadataRefresher
    # @return [Dry::Monads::Success(ApplicationRecord)]
    monadic_operation! def refresh_attachment_metadata(name)
      call_operation("processing.refresh_metadata", self, name)
    end

    # @param [Symbol] name
    # @see Processing::Reprocess
    # @see Processing::Reprocessor
    # @return [Dry::Monads::Success(ApplicationRecord)]
    monadic_operation! def reprocess_attachment(name, **options)
      call_operation("processing.reprocess", self, name, **options)
    end

    monadic_operation! def retry_promoting_attachment(name)
      file_data = shrine_file_data_for(name)

      promote_attachment(name, file_data:)
    end

    # @return [Shrine::Attacher]
    def shrine_attacher_for(name) = __send__("#{name}_attacher")

    # @!attribute [r] shrine_attachment_names
    # @return [<Symbol>]
    def shrine_attachment_names = self.class.shrine_attachment_names

    # @return [{ Symbol => Shrine::Attacher }]
    def shrine_attachers = shrine_attachment_names.index_with { |name| shrine_attacher_for(name) }

    # @raise [Shrine::Error] if there is no file data
    # @return [Hash]
    def shrine_file_data_for(name) = shrine_attacher_for(name).file_data

    # @!group Stuck Attachment Handling

    # @return [{ Symbol => Boolean }]
    def unstick_shrine_attachments!
      shrine_attachers.each_with_object({}) do |(name, attacher), result|
        stuck = attacher.stuck?

        retry_promoting_attachment!(name) if stuck

        result[name] = stuck
      end
    end

    # @!endgroup Stuck Attachment Handling

    module ClassMethods
      # @param [Symbol] name
      # @return [void]
      def register_shrine_attachment!(name)
        shrine_attachment! name

        include Processing::RegisteredAttachment[name]
      end

      # @!attribute [r] shrine_attachment_names
      # @return [<Symbol>]
      def shrine_attachment_names = shrine_attachments.to_a

      # @param [Symbol] name
      # @return [ActiveRecord::Relation]
      def with_shrine_attachment(name, column: "#{name}_data", storage: true, with_derivatives: nil)
        attr = arel_table[column]

        conditions = [
          attr.not_eq(nil),
          arel_infix(??, attr, arel_quote("id")),
          arel_shrine_storage_condition(attr, storage),
          arel_shrine_with_derivatives_condition(attr, with_derivatives)
        ].compact

        expr = arel_grouping(arel_and_expressions(conditions))

        where(expr)
      end

      # @param [Symbol] name
      # @return [ActiveRecord::Relation]
      def with_stored_shrine_attachment(name, **options)
        with_shrine_attachment(name, **options, storage: "store")
      end

      # @param [Symbol] name
      # @return [ActiveRecord::Relation]
      def with_cached_shrine_attachment(name, **options)
        with_shrine_attachment(name, **options, storage: "cache")
      end

      # @param [Symbol] name
      # @return [ActiveRecord::Relation]
      def sans_shrine_attachment(name, column: "#{name}_data")
        where(arel_table[column].eq(nil))
      end

      # @param [Symbol] name
      # @return [ActiveRecord::Relation]
      def sans_stored_shrine_attachment(name)
        with_shrine_attachment(name, storage: [false, "store"])
      end

      # @param [Symbol] name
      # @return [ActiveRecord::Relation]
      def sans_cached_shrine_attachment(name)
        with_shrine_attachment(name, storage: [false, "cache"])
      end

      # @param [Arel::Attribute] attr
      # @param [String, Symbol, true] storage
      # @return [Arel::Nodes::Node]
      def arel_shrine_storage_condition(attr, input)
        case input
        in String | Symbol => storage
          arel_json_get_as_text(attr, "storage").eq(storage.to_s)
        in true
          arel_infix(??, attr, arel_quote("storage"))
        in false, String | Symbol => storage
          arel_json_get_as_text(attr, "storage").not_eq(storage.to_s)
        else
          # simplecov:disable
          raise ArgumentError, "Invalid storage condition: #{input.inspect}"
          # simplecov:enable
        end
      end

      # @param [Arel::Attribute] attr
      # @param [Boolean, nil] with_derivatives
      # @return [Arel::Nodes::Node, nil]
      def arel_shrine_with_derivatives_condition(attr, with_derivatives)
        case with_derivatives
        in true
          arel_infix(??, attr, arel_quote("derivatives"))
        in false
          arel_json_get_as_text(attr, "derivatives").eq(nil)
        in nil
          nil
        else
          # simplecov:disable
          raise ArgumentError, "Invalid with_derivatives condition: #{with_derivatives.inspect}"
          # simplecov:enable
        end
      end

      # @!group Stuck Attachment Handling

      def with_any_stuck_shrine_attachments = with_stuck_shrine_attachments(shrine_attachment_names)

      def with_stuck_shrine_attachments(*names)
        names.flatten!

        return none if names.empty?

        conditions = names.map do |name|
          arel_attachment_stuck(name)
        end

        expr = arel_grouping(arel_or_expressions(conditions))

        where(expr)
      end

      def arel_attachment_stuck(name, column: "#{name}_data")
        cached = arel_shrine_storage_condition(arel_table[column], "cache")
        stale = arel_attachment_stale(name, column:)

        arel_grouped cached.and(stale)
      end

      def arel_attachment_generated_at(name, column: "#{name}_data")
        attr = arel_table[column]

        arel_cast(arel_json_get_path_as_text(attr, "metadata", "generated_at"), "timestamptz")
      end

      def arel_attachment_stale(name, column: "#{name}_data")
        generated_at = arel_attachment_generated_at(name, column:)

        is_stale = generated_at.lt(STALE_TIME.ago)

        unset = generated_at.eq(nil)

        arel_grouped is_stale.or(unset)
      end

      # @!endgroup Stuck Attachment Handling
    end
  end
end
