# frozen_string_literal: true

module DepositorAgreements
  # @abstract
  class AbstractStateEnforcer < Support::HookBased::Actor
    extend Dry::Core::ClassAttributes

    include Dry::Initializer[undefined: false].define -> do
      option :depositor_agreement, Types::DepositorAgreement.optional, as: :provided_depositor_agreement, optional: true
      option :submission_target, Types::SubmissionTarget, default: proc { depositor_agreement&.submission_target }
      option :user, Types::User, default: proc { depositor_agreement&.user }
    end

    defines :target_state, type: DepositorAgreements::Types::State

    target_state "pending"

    standard_execution!

    # @return [DepositorAgreement]
    attr_reader :depositor_agreement

    delegate :in_state?, :transition_to!, to: :depositor_agreement

    # @return [Dry::Monads::Result]
    def call
      run_callbacks :execute do
        yield prepare!

        yield enforce_state!
      end

      Success depositor_agreement
    end

    wrapped_hook! def prepare
      @depositor_agreement = provided_depositor_agreement || submission_target.agreement_for(user)

      depositor_agreement.save! if depositor_agreement.new_record?

      super
    end

    wrapped_hook! def enforce_state
      transition_to!(target_state) unless in_state?(target_state)

      super
    end

    private

    # @return ["pending", "accepted"]
    def target_state = self.class.target_state
  end
end
