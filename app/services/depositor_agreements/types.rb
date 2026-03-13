# frozen_string_literal: true

module DepositorAgreements
  module Types
    extend ::Support::Typespace

    DepositorAgreement = ModelInstance("DepositorAgreement")

    State = ApplicationRecord.dry_pg_enum("depositor_agreement_state", default: "pending").fallback("pending")

    SubmissionTarget = ModelInstance("SubmissionTarget")

    User = ModelInstance("User")
  end
end
