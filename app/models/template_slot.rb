# frozen_string_literal: true

class TemplateSlot < ::ApplicationFrozenRecord
  include Templates::Config::SourcedByTemplateKind

  schema!(types: ::Templates::TypeRegistry) do
    optional(:id).filled(:string)
    required(:template_kind).filled(:template_kind)
    required(:name).filled(:string)
    required(:slot_kind).filled(:slot_kind)
    required(:default_template).maybe(:stripped_string)
    required(:description).maybe(:stripped_string)
  end

  default_attributes!(
    default_template: nil,
    description: nil
  )

  multiline! :default_template, :description

  def has_default?
    default_template.present?
  end

  # @return [Templates::Compositions::Slot]
  def to_composition
    Templates::Compositions::Slot.from_hash(to_composition_hash)
  end

  # @return [{ String => Object }]
  def to_composition_hash
    slice(
      :name,
      :slot_kind,
      :template_kind,
      :default_template,
      :description
    ).stringify_keys
  end

  class << self
    def default_templates
      @default_templates ||= Concurrent::Map.new
    end

    # @return [Proc]
    def default_slot_value_for(id)
      value = default_template_hash_for(id)

      Templates::Config::Utility::SlotValue.from_hash(value)
    end

    def default_template_hash_for(id)
      default_templates.compute_if_absent [id, :hash] do
        slot = TemplateSlot.find id

        raw_template = slot.default_template&.freeze

        { raw_template:, }
      end
    end
  end
end
