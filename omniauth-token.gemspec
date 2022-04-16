# frozen_string_literal: true

require_relative "lib/omniauth-token/version"

Gem::Specification.new do |spec|
  spec.name          = "omniauth-token"
  spec.version       = Omniauth::Token::VERSION
  spec.authors       = ["Elliot Crosby-McCullough"]
  spec.email         = ["elliot.cm@gmail.com"]

  spec.summary       = "Token authentication for OmniAuth"
  spec.homepage      = "https://github.com/SmartCasual/omniauth-token"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/SmartCasual/omniauth-token/blob/#{spec.version}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) {
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "hmac", "~> 2.1"
  spec.add_runtime_dependency "omniauth", "~> 2.1"
  spec.metadata["rubygems_mfa_required"] = "true"
end
