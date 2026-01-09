# frozen_string_literal: true

module Harvesting
  module Metadata
    module Drops
      # @see Harvesting::Metadata::Types::DropDataAttrMapping
      class DataExtractor < Support::FlexibleStruct
        include Dry::Core::Equalizer.new(:name)

        Mapping = Types::Hash.map(Types::Symbol, self)

        attribute :name, Types::Coercible::Symbol

        attribute :attr, Types::Coercible::Symbol

        attribute? :default, Types::Any.optional

        attribute? :type, Types.Instance(::Dry::Types::Type).default(Types::Any)

        attribute? :optional, Types::Bool.default(true)

        def cast_type
          optional ? type.optional : type
        end

        def ivar
          @ivar ||= :"@#{name}"
        end

        # @param [Object] data
        # @return [Object]
        def extract(data)
          value = data.public_send(attr)

          result = cast_type.try(value).to_monad

          cast = result.value_or(default)

          cast.nil? ? default : cast
        end
      end
    end
  end
end
