# frozen_string_literal: true

module Support
  module Networking
    module MisbehavingSSLUpstream
      module ErrorMatcher
        refine Exception do
          def misbehaving_ssl_upstream?
            return true if kind_of?(::OpenSSL::SSL::SSLError) && /unexpected eof while reading/.match?(message)

            # :nocov:
            return true if kind_of?(::Errno::ECONNRESET) && /SSL_connect/i.match?(message)
            # :nocov:

            cause&.misbehaving_ssl_upstream? || false
          end
        end
      end
    end
  end
end
