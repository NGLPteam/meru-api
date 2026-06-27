# frozen_string_literal: true

module Support
  module ClassyList
    # @api private
    class List
      include Dry::Core::Equalizer.new(:list_name)
      include Enumerable

      include Dry::Initializer[undefined: false].define -> do
        option :config, Support::ClassyList::Configuration::Type
      end

      delegate :item_type, :list_name, :list_type, :realize_mode, to: :config

      def initialize(...)
        super

        @items = Set.new
      end

      # @param [Object] new_item
      # @return [Boolean]
      def add!(new_item)
        valid_item = item_type[new_item]

        @items.add?(valid_item)
      end

      # @param [Array] new_items
      # @return [void]
      def merge!(*new_items)
        valid_items = list_type[new_items.flatten]

        @items.merge(valid_items)

        return self
      end

      def each
        return enum_for(:each) unless block_given?

        items.each { |item| yield item }
      end

      # @api private
      # @param [Support::ClassyList::Map] original
      # @return [void]
      def initialize_copy(original)
        super

        @items = original.items.dup
      end

      # @param [Object]
      # @return [Array] when `realize_mode` is `:array`
      # @return [Hash] when `realize_mode` is `:hash`
      def realize(source)
        case realize_mode
        in :array
          items.map { |item| source.__send__(item) }
        in :hash
          items.index_with { |item| source.__send__(item) }
        else
          raise Support::ClassyList::Error, "#{list_name} is not realizable"
        end
      end

      def to_ary = to_a

      protected

      # @return [Set]
      attr_reader :items
    end
  end
end
