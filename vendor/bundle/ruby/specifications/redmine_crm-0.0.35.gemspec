# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "redmine_crm"
  s.version = "0.0.35"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["RedmineUP"]
  s.date = "2018-03-05"
  s.description = "Common libraries for RedmineUP plugins (www.redmineup.com) for Redmine. Requered Redmine from http://redmine.org"
  s.email = ["support@redminecrm.com"]
  s.homepage = ""
  s.licenses = ["GPL2"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.14.1"
  s.summary = "Common libraries for RedmineUP plugins for Redmine"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<liquid>, ["< 2.6.4"])
    else
      s.add_dependency(%q<liquid>, ["< 2.6.4"])
    end
  else
    s.add_dependency(%q<liquid>, ["< 2.6.4"])
  end
end
