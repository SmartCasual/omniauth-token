require "omniauth/strategies/token"

RSpec.describe OmniAuth::Strategies::Token, type: :strategy do
  let(:app) do
    provider_options = options # This won't be in scope for the closure otherwise

    Rack::Builder.new do
      use OmniAuth::Test::PhonySession
      use OmniAuth::Builder do
        provider OmniAuth::Strategies::Token, # rubocop:disable RSpec/DescribedClass
          name: :token,
          secret: "secret",
          **provider_options
      end

      run lambda { |env| [404, { "Content-Type" => "text/plain" }, [env.has_key?("omniauth.auth").to_s]] }
    end.to_app
  end

  let(:options) { {} }

  describe "#request_phase" do
    subject { post("/auth/token") }

    context "when the `request_a_login_email_path` option is set" do
      let(:options) { { request_a_login_email_path: "/login" } }

      it { is_expected.to redirect_to("/login") }
    end

    context "when the `request_a_login_email_path` option is not set`" do
      it { is_expected.to redirect_to("/") }
    end
  end

  describe "#callback_phase" do
    let(:generator) do
      ::HMAC::Generator.new(secret: "secret", context: "sessions")
    end
    let(:extra_fields_query_string) { "" }

    let(:token) do
      generator.generate(id: "12345")
    end

    before do
      get("/auth/token/callback?id=#{id}&token=#{token}#{extra_fields_query_string}")
    end

    context "when the token is valid" do # rubocop:disable RSpec/EmptyExampleGroup
      let(:id) { "12345" }

      sets_an_auth_hash
      sets_uid_to("12345")
      sets_provider_to(:token)
      sets_user_info_to(nil)
    end

    context "when the token is invalid" do
      let(:id) { "54321" }

      it "returns a failure message" do
        expect(last_request).to have_failed_with(:invalid_credentials)
      end
    end

    context "when the token is missing" do
      let(:id) { "12345" }
      let(:token) { nil }

      it "returns a failure message" do
        expect(last_request).to have_failed_with(:invalid_credentials)
      end
    end

    context "when the id is missing" do
      let(:id) { nil }

      it "returns a failure message" do
        expect(last_request).to have_failed_with(:invalid_credentials)
      end
    end

    context "when an email address is given" do
      let(:id) { "12345" }
      let(:email_address) { "test@example.com" }
      let(:extra_fields_query_string) do
        "&email_address=#{email_address}"
      end

      let(:token) do
        generator.generate(
          id:,
          extra_fields: { email_address: },
        )
      end

      it "returns the email address in the info section" do
        expect(last_request.env.dig("omniauth.auth", "info", "email")).to eq(email_address)
      end

      context "when the email address is invalid" do
        let(:extra_fields_query_string) { "&email_address=invalid" }

        it "returns a failure message" do
          expect(last_request).to have_failed_with(:invalid_credentials)
        end
      end
    end
  end
end
