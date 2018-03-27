require "bundler/gem_tasks"

require 'rake'
require 'rake/testtask'
# require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the acts_as_taggable_on_steroids plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Copy migration file to db/migration of plugin'
file 'copy_migration' do
  cp "generators/redmine_crm_migration/templates/migration.rb", "db/migrate/redmine_crm.rb"
end
