# frozen_string_literal: true

module Processing
  module Types
    extend Support::Typespace

    ClassOrName = Class.constructor do |input|
      case input
      when ::Class then input
      when ::String then input.constantize
      else
        raise Dry::Types::CoercionError, "Expected a Class or String, got #{input.inspect}"
      end
    rescue NameError
      raise Dry::Types::CoercionError, "#{input} is not a valid class"
    end

    AttacherClass = Constant(Shrine::Attacher) | Inherits(Shrine::Attacher)

    AttachmentName = Coercible::Symbol

    FileData = Hash.schema(
      id?: Coercible::String,
      storage?: Coercible::String,
    ).with_key_transform(&:to_sym)

    AttachmentData = FileData | String

    Model = ::Support::Models::Types::Model
  end
end
