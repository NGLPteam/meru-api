# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn,
  :query,
  :raw_source, :raw_metadata_source,
  :xml_source, :xml_metadata_source,
  :json_source, :json_metadata_source,
]
