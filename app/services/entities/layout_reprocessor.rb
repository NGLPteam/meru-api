# frozen_string_literal: true

module Entities
  # @see Entities::ReprocessLayout
  class LayoutReprocessor < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :entity, Layouts::Types::Entity

      option :layout_kind, Layouts::Types::Kind
    end

    standard_execution!

    # @return [LayoutInstance, nil]
    attr_reader :layout_instance

    # @return [Dry::Monads::Success(HierarchicalEntity)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield reprocess!
      end

      Success entity
    end

    wrapped_hook! def prepare
      @layout_instance = entity.__send__(:"#{layout_kind}_layout_instance")

      super
    end

    wrapped_hook! def reprocess
      # simplecov:disable
      return super unless layout_instance
      # simplecov:enable

      yield layout_instance.reprocess

      super
    end
  end
end
