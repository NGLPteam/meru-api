# frozen_string_literal: true

module TemplateInstance
  extend ActiveSupport::Concern
  extend DefinesMonadicOperation

  include HasLayoutKind
  include HasTemplateKind
  include Renderable

  included do
    attribute :config, Templates::Instances::Config.to_type

    belongs_to :entity, polymorphic: true

    has_one :instance_digest, as: :template_instance, class_name: "Templates::InstanceDigest", dependent: :destroy

    delegate :policy_class, to: :class

    has_many_readonly :prev_siblings, -> { for_prev }, as: :template_instance, class_name: "Templates::InstanceSibling"
    has_many_readonly :next_siblings, -> { for_next }, as: :template_instance, class_name: "Templates::InstanceSibling"

    before_validation :infer_config!
  end

  # @see Templates::Instances::BuildConfig
  # @see Templates::Instances::ConfigBuilder
  monadic_operation! def build_config
    call_operation("templates.instances.build_config", self)
  end

  # @see Templates::Instances::BuildDigestAttributes
  # @see Templates::Instances::DigestAttributesBuilder
  monadic_operation! def build_digest_attributes
    call_operation("templates.instances.build_digest_attributes", self)
  end

  # Boolean complement of {#force_show?}.
  #
  # Used when calculating {#hidden} to bypass the hide logic.
  def calculate_allow_hide?
    !force_show?
  end

  # For most templates, it is just derived from from {#hidden_by_empty_slots}.
  #
  # @abstract Provides the uncached value for {#hidden} and can be overridden in subclasses.
  # @api private
  # @see #hidden?
  # @return [Boolean]
  def calculate_hidden
    hidden_by_empty_slots?
  end

  # @api private
  # @abstract
  # @return [Boolean]
  def force_show
    false
  end

  # @see #force_show
  def force_show?
    force_show
  end

  # @see Templates::Instances::PostProcessor
  # @return [Dry::Monads::Success(TemplateInstance)]
  monadic_operation! def post_process
    call_operation("templates.instances.post_process", self)
  end

  # @see Templates::Instances::Processor
  # @return [Dry::Monads::Success(TemplateInstance)]
  monadic_operation! def process
    call_operation("templates.instances.process", self)
  end

  # @see Templates::Instances::Reprocessor
  # @param [Hash] options
  # @option options [Boolean] :update_digest (false)
  # @return [Dry::Monads::Success(TemplateInstance)]
  monadic_operation! def reprocess(**options)
    call_operation("templates.instances.reprocess", self, **options)
  end

  # @see Templates::Digests::Instances::TemplateUpserter
  monadic_operation! def upsert_instance_digests
    call_operation("templates.digests.instances.upsert_for_template", self)
  end

  private

  # @return [void]
  def infer_config!
    self.config = build_config!
  end

  module ClassMethods
    def policy_class
      TemplateInstancePolicy
    end
  end
end
