# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "browsate/version"

Gem::Specification.new do |spec|
  spec.name          = "browsate"
  spec.version       = Browsate::VERSION
  spec.authors       = ["Jonathan Siegel"]
  spec.email         = ["248302+usiegj00@users.noreply.github.com"]

  spec.summary       = "Automate Chrome browser sessions with CDP"
  spec.description   = "Navigate Chrome browser sessions and execute JavaScript using CDP via Chromate, with session persistence"
  spec.homepage      = "https://github.com/usiegj00/browsate"
  spec.license       = "All rights reserved"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir.glob("{bin,lib}/**/*") + %w[LICENSE.txt README.md]
  spec.bindir        = "bin"
  spec.executables   = ["browsate"]
  spec.require_paths = ["lib"]

  # Using local mock for chromate
  # spec.add_dependency "chromate", "~> 0.1"
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "zeitwerk", "~> 2.6"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.44"
  spec.add_development_dependency "webrick", "~> 1.7"
  spec.metadata["rubygems_mfa_required"] = "true"
end
