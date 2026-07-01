# frozen_string_literal: true

# Not a true concern, this model should be `extended`
# on modules or classes in order to build attributes.
module DelegatesAssociationWriter
  class << self
    def included(base)
      # simplecov:disable
      raise "Do not include #{name}: extend it in a module or class"
      # simplecov:enable
    end
  end

  # @param [Symbol] name
  # @return [void]
  # @!macro [attach]
  #   @!attribute [rw] $2
  #   An attribute from the `$1` association with a delegated writer
  #   that autoinstantiates the child association.
  def writes_association_attribute!(association, name)
    class_eval <<~RUBY, __FILE__, __LINE__ + 1
    def #{name}=(new_value)
      child = #{association} || build_#{association}

      child.write_attribute #{name.inspect}, new_value
    end
    RUBY
  end
end
