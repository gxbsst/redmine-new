# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redmine_crm/version'

Gem::Specification.new do |spec|
  spec.name          = "redmine_crm"
  spec.version       = RedmineCrm::VERSION
  spec.authors       = ["RedmineUP"]
  spec.email         = ["support@redminecrm.com"]
  spec.summary       = %q{Common libraries for RedmineUP plugins for Redmine}
  spec.description   = %q{Common libraries for RedmineUP plugins (www.redmineup.com) for Redmine. Requered Redmine from http://redmine.org}
  spec.homepage      = ""
  spec.license       = "GPL2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'liquid', "<2.6.4"
end
