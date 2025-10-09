# frozen_string_literal: true

# Anyway config class for managing layouts and rendering
class LayoutsConfig < ApplicationConfig
  attr_config invalidate_on_deploy: false, track_slot_compilation_time: false

  coerce_types invalidate_on_deploy: :boolean, track_slot_compilation_time: :boolean
end
