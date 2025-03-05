# frozen_string_literal: true

require_relative "lib/metrics/backend/statsd/version"

Gem::Specification.new do |spec|
	spec.name = "metrics-backend-statsd"
	spec.version = Metrics::Backend::Statsd::VERSION
	
	spec.summary = "Application metrics and instrumentation."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/metrics-backend-statsd"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/metrics-backend-statsd/",
		"source_code_uri" => "https://github.com/socketry/metrics-backend-statsd.git",
	}
	
	spec.files = Dir.glob(["{lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "metrics"
end
