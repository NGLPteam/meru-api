# frozen_string_literal: true

module Layouts
  class Disabled < ActiveSupport::CurrentAttributes
    attribute :currently, default: proc { false }

    alias currently? currently
  end
end
