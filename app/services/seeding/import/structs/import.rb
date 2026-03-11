# frozen_string_literal: true

module Seeding
  module Import
    module Structs
      # The root struct for handling an import.
      class Import < Base
        include ::Support::Typing

        attribute :communities, Seeding::Import::Structs::Community.as_list
        attribute :version, Seeding::Types::ImportVersion
      end
    end
  end
end
