require "omniauth"
require "hmac"

module OmniAuth
  module Strategies
    class Token
      include OmniAuth::Strategy

      option :uid_field, :id
      option :email_address_field, :email_address
      option :token_field, :token
      option :context, :sessions
      option :secret, nil
      option :request_a_login_email_path, "/"

      def request_phase
        redirect options.request_a_login_email_path
      end

      def callback_phase
        return fail!(:invalid_credentials) unless valid_token?

        super
      end

      uid do
        id
      end

      info do
        {
          email: email_address,
        }
      end

    private

      def valid_token?
        token_validator.validate(token, against_id: id, extra_fields:)
      end

      def id
        request.params[options.uid_field.to_s]
      end

      def email_address
        request.params[options.email_address_field.to_s]
      end

      def token
        request.params[options.token_field.to_s]
      end

      def token_validator
        @token_validator ||= ::HMAC::Validator.new(context: options[:context], secret: options[:secret])
      end

      def extra_fields
        {}.tap do |extra_fields|
          extra_fields[:email_address] = email_address if email_address_given?
        end
      end

      def email_address_given?
        request.params.has_key?(options.email_address_field.to_s)
      end
    end
  end
end
