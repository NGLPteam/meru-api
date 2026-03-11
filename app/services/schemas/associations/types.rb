# frozen_string_literal: true

module Schemas
  module Associations
    # Types for use with internal association-specific services
    #
    # @api private
    module Types
      extend ::Support::Typespace

      # An individual {Schemas::Associations::Association association}.
      Association = Instance(Schemas::Associations::Association)

      # A list of {Schemas::Associations::Association associations}.
      Associations = Array.of(Association)

      # A side of a prospective edge, i.e. `:parent` or `:child`.
      ConnectionType = Symbol.enum(:parent, :child)

      # A list of requirement declarations
      Requirements = Array.of(String)

      # A {SchemaVersion}.
      Schema = Instance(::SchemaVersion)
    end
  end
end
