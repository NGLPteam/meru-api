# frozen_string_literal: true

module Rendering
  # Types related to rendering {Layouts} / {Templates} for {Entities}.
  module Types
    extend ::Support::Typespace

    Generation = String.constrained(uuid_v4: true)
  end
end
