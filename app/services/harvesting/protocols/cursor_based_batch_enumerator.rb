# frozen_string_literal: true

module Harvesting
  module Protocols
    module CursorBasedBatchEnumerator
      extend ActiveSupport::Concern

      include ::Utility::DefinesAbstractMethods
      include Harvesting::Middleware::ProvidesHarvestData
      include Harvesting::WithLogger

      extend ::Utility::DefinesAbstractMethods::ClassMethods

      included do
        extend ActiveModel::Callbacks
        extend Dry::Initializer

        include Dry::Core::Constants

        include Dry::Monads[:result]

        include Dry::Effects::Handler.Interrupt(:halt_enumeration, as: :catch_halt_enumeration)

        include Dry::Effects.Interrupt(:halt_enumeration)

        option :cursor, ::Harvesting::Types::String.optional, optional: true, as: :provided_cursor

        define_model_callbacks :enumeration

        around_enumeration :with_halted_enumeration!
      end

      # @!group Enumeration

      def each(&)
        wrap_batch_enumeration! do
          enumerate!(&)
        end
      end

      # @return [Enumerator::Lazy]
      def to_enumerator
        to_enum(:each).lazy
      end

      # @!endgroup

      # @!group Interface

      # @abstract
      # @param [Object] batch
      # @return [Dry::Monads::Success(Object)]
      # @return [Dry::Monads::Failure]
      abstract_method!(:next_cursor_from, signature: "batch")

      # @abstract
      # @param [Object] cursor
      # @return [Object, nil]
      abstract_method!(:build_batch, signature: "cursor: nil")

      # @param [Object] batch
      # @return [<Object>]
      abstract_method!(:process_batch, signature: "batch")

      # @!endgroup

      private

      # This will perform sanity checks on prev/next cursors
      # and persist them for later use.
      #
      # @param [String, nil] prev_cursor
      # @param [String, nil] next_cursor
      # @return [void]
      def check_cursor!(prev_cursor, next_cursor)
        if next_cursor.blank?
          halt_enumeration
        elsif prev_cursor.present? && prev_cursor == next_cursor
          # simplecov:disable
          # Edge case that has happened before with poorly-implemented OAI-PMH providers
          # that did not properly generate resumption tokens.
          logger.warn("cursor repeating infinitely: #{prev_cursor}")

          halt_enumeration
          # simplecov:enable
        else
          logger.log("next cursor: #{next_cursor.inspect}")
        end
      end

      # @return [void]
      def enumerate!
        batch = build_batch(cursor: provided_cursor)

        on_initial_batch batch if provided_cursor.blank?

        # simplecov:disable
        halt_enumeration if batch.nil?
        # simplecov:enable

        prev_cursor = provided_cursor

        loop do
          pre_process! batch

          processed = process_batch batch

          processed.each do |obj|
            yield obj, prev_cursor
          end

          post_process! processed

          next_cursor = next_cursor_from batch

          check_cursor! prev_cursor, next_cursor

          batch = build_batch cursor: next_cursor

          prev_cursor = next_cursor
        end
      rescue Faraday::Error => e
        logger.fatal "Web Request Failed: #{e.message}"

        halt_enumeration
      rescue LocalJumpError
        logger.debug("Enumeration returned early, will resume")
      end

      # @!group Optional Hooks

      # @abstract
      # @param [Object] batch
      # @return [Integer]
      def batch_count_for(batch)
        batch.try(:count).to_i
      end

      # @abstract
      # @param [Object] batch
      # @return [void]
      def on_initial_batch(batch); end

      # @abstract
      # @param [Object] batch
      # @return [void]
      def on_batch(batch); end

      # @abstract
      # @param [Object] batch
      # @return [void]
      def pre_process!(batch); end

      # @abstract
      # @param [<Object>] processed
      # @return [void]
      def post_process!(processed); end

      # @!endgroup

      # @return [void]
      def wrap_batch_enumeration!
        run_callbacks :enumeration do
          yield
        end
      end

      # @return [void]
      def with_halted_enumeration!
        halted, _ = catch_halt_enumeration do
          yield if block_given?
        end

        logger.debug("Enumeration halted") if halted
      end
    end
  end
end
