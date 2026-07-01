# frozen_string_literal: true

module Entities
  module Enumeration
    # @abstract
    class Abstract
      include Enumerable
      include Dry::Initializer[undefined: false].define -> do
        param :entity, ::Entities::Types::Entity

        option :cursor, ::Entities::Types::String.optional, optional: true
      end

      # @yield [subentity, new_cursor]
      # @yieldparam [::HierarchicalEntity] subentity
      # @yieldparam [String] new_cursor
      # @yieldreturn [void]
      # @return [void]
      def each
        each_hierarchical_entity do |subentity, new_cursor|
          yield subentity, new_cursor
        end
      end

      # @return [Enumerator::Lazy<HierarchicalEntity>]
      def to_enumerator
        to_enum(:each).lazy
      end

      private

      # @abstract
      # @return [ActiveRecord::Relation<::Entity>]
      def build_hierarchical_scope
        ::Entity.includes(:hierarchical)
      end

      # @yield [subentity, new_cursor]
      # @yieldparam [::HierarchicalEntity] subentity
      # @yieldparam [String] new_cursor
      # @yieldreturn [void]
      # @return [void]
      def each_hierarchical_entity
        build_hierarchical_scope.find_each(start: cursor) do |subentity|
          # simplecov:disable
          next if subentity.blank? || subentity.hierarchical.blank?
          # simplecov:enable

          yield subentity.hierarchical, subentity.id
        end
      end

      class << self
        # @return [Enumerator::Lazy<HierarchicalEntity>]
        def call(...)
          new(...).to_enumerator
        end
      end
    end
  end
end
