# frozen_string_literal: true

module LayoutInstance
  extend ActiveSupport::Concern
  extend DefinesMonadicOperation

  include HasLayoutKind
  include HasTemplateKinds
  include Renderable

  included do
    extend Dry::Core::ClassAttributes

    belongs_to :entity, polymorphic: true

    has_many :template_instance_digests, as: :layout_instance, inverse_of: :layout_instance, class_name: "Templates::InstanceDigest", dependent: :delete_all

    defines :template_instance_names, type: Layouts::Types::Associations

    template_instance_names [].freeze

    scope :root, -> { joins(:layout_definition).merge(layout_record.definition_klass.root) }

    scope :with_template_instances, -> { includes(*template_instance_names) }

    validates :generation, presence: true

    after_save :clear_template_instances!
  end

  # @!attribute [r] all_hidden
  # @return [Boolean]
  def all_hidden
    template_instances.blank? || template_instances.all?(&:hidden?)
  end

  # @!attribute [r] all_slots_empty
  # @return [Boolean]
  def all_slots_empty
    template_instances.blank? || template_instances.all?(&:all_slots_empty?)
  end

  alias all_slots_empty? all_slots_empty

  # @return [void]
  def clear_template_instances!
    @template_instances = false
  end

  # @return [<Symbol>]
  def template_instance_names
    self.class.template_instance_names
  end

  # @return [<TemplateInstance>]
  def template_instances
    @template_instances ||= fetch_template_instances
  end

  # @see Templates::Digests::Instances::LayoutUpserter
  monadic_operation! def upsert_template_instance_digests
    call_operation("templates.digests.instances.upsert_for_layout", self)
  end

  def each_template_instance_association
    # :nocov:
    return enum_for(__method__) unless block_given?
    # :nocov:

    template_instance_names.each do |assoc_name|
      assoc = __send__(assoc_name)

      yield assoc
    end
  ensure
    clear_template_instances!
  end

  private

  # @return [<TemplateInstance>]
  def fetch_template_instances
    template_instance_names.map do |assoc|
      __send__(assoc).reload.to_a
    end.reduce(&:+).sort_by(&:position)
  end

  module ClassMethods
    # @param [HierarchicalEntity] entity
    # @param [LayoutDefinition] layout_definition
    # @return [LayoutInstance]
    def fetch_for(entity, layout_definition:, generation: SecureRandom.uuid)
      where(entity:).first_or_initialize do |li|
        li.generation = generation
        li.layout_definition = layout_definition
      end
    end

    # @param [<LayoutDefinition>] definitions
    # @return [ActiveRecord::Relation<LayoutInstance>]
    def limited_to_layout_definitions(*definitions)
      joins(:layout_definition).merge(layout_record.definition_klass.limited_to(*definitions))
    end

    def template_kinds!(...)
      super

      template_instance_names template_kinds.map { :"#{_1}_template_instances" }
    end
  end
end
