# frozen_string_literal: true

module System
  class SetBucketLifecycle
    include Dry::Monads[:result, :do]

    LIFECYCLE_CONFIGURATION = {
      rules: [
        {
          id: "PruneShrineCache",
          filter: {
            prefix: "cache/",
          },
          status: "Enabled",
          expiration: {
            days: 7,
          },
        },
      ],
    }.freeze

    def call
      # simplecov:disable
      bucket = UploadConfig.bucket

      client = S3Config.build_s3_client

      client.put_bucket_lifecycle_configuration(bucket:, lifecycle_configuration: LIFECYCLE_CONFIGURATION)

      Success()
      # simplecov:enable
    end
  end
end
