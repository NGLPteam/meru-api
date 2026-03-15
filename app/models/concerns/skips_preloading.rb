# frozen_string_literal: true

# Concern to disable automatic preloading of associations for a model.
#
# This is important for certain **huge** views that should never be
# eager loaded in their entirety.
module SkipsPreloading
  extend ActiveSupport::Concern

  included do
    default_scope { skip_preloading! }
  end
end
