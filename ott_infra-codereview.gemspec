# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ott_infra/codereview/version'

Gem::Specification.new do |spec|
  spec.name          = "ott_infra-codereview"
  spec.version       = OttInfra::Codereview::VERSION
  spec.authors       = ["Dmitry Shmelev"]
  spec.email         = ["dmitry.shmelev@onetwotrip.com"]

  spec.summary       = %q{OTT Infra CodeReview gem.}
  spec.description   = %q{Infrastructure libs for codereview notification.}
  spec.homepage      = "https://www.onetwotrip.com"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~>3.4.0"
  spec.add_development_dependency "rspec_junit_formatter", "~>0.2.3"
  spec.add_development_dependency "simplecov", "~>0.11.1"
end
