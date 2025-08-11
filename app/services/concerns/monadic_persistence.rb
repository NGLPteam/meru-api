# frozen_string_literal: true

module MonadicPersistence
  extend ActiveSupport::Concern

  include MonadicFind

  # @param [ApplicationRecord] model
  # @return [Dry::Monads::Success(ApplicationRecord)]
  # @return [Dry::Monads::Failure(:invalid, ApplicationRecord, <String>)]
  def monadic_save(model)
    if model.save
      Dry::Monads.Success(model)
    else
      Dry::Monads::Result::Failure[:invalid, model, model.errors.full_messages.to_a]
    end
  end

  # @param [Class#upsert] klass
  # @param [Hash] attributes
  # @param [<Symbol>] unique_by
  # @return [Dry::Monads::Result]
  def monadic_upsert(klass, attributes, unique_by:, skip_find: false)
    klass.upsert(attributes, unique_by:)

    # :nocov:
    return Dry::Monads.Success() if skip_find
    # :nocov:

    tuple = Array(unique_by).index_with { |k| attributes.fetch(k) }.symbolize_keys

    monadic_find_by(klass, **tuple)
  end
end
