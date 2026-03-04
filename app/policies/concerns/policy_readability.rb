# frozen_string_literal: true

# Enhancements to base policies around readability of records.
module PolicyReadability
  extend ActiveSupport::Concern

  included do
    extend Dry::Core::ClassAttributes

    defines :always_readable, :readable_in_dev, type: Roles::Types::Bool

    # @!attribute [r] always_readable
    #   @!scope class
    #   Whether the record is always readable, regardless of user permissions.
    #   @return [Boolean]
    always_readable false

    # @!attribute [r] readable_in_dev
    #   @!scope class
    #   Whether the record is readable in development mode.
    #   @note This is mostly for harvesting and other records that allows for easier introspection.
    #   @return [Boolean]
    readable_in_dev false
  end

  # Whether the record is always readable, regardless of user permissions.
  # @see .always_readable
  def always_readable? = self.class.always_readable

  # Whether the record is readable in development mode.
  #
  # @see .readable_in_dev
  # @note This is mostly for harvesting and other records that allows for easier introspection.
  def readable_in_dev? = self.class.readable_in_dev && Rails.env.development?

  module ClassMethods
    # Specify that the record is always readable.
    #
    # @see .always_readable
    # @return [void]
    def always_readable!
      always_readable true
    end
  end
end
