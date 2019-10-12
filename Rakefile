require 'rspec/core/rake_task'
require 'securerandom'
require 'git'
require 'semantic'
require 'rake_terraform'

require_relative 'lib/configuration'
require_relative 'lib/version'

configuration = Configuration.new

def repo
  Git.open('.')
end

def latest_tag
  repo.tags.map do |tag|
    Semantic::Version.new(tag.name)
  end.max
end

RakeTerraform.define_installation_tasks(
    path: File.join(Dir.pwd, 'vendor', 'terraform'),
    version: '0.12.10')

task :default => 'test:integration'

namespace :test do
  RSpec::Core::RakeTask.new(:integration => ['terraform:ensure']) do
    ENV['AWS_REGION'] = 'us-east-1'
  end
end

namespace :deployment do
  namespace :prerequisites do
    RakeTerraform.define_command_tasks do |t|
      t.argument_names = [:deployment_identifier]

      t.configuration_name = 'prerequisites'
      t.source_directory =
          configuration.for(:prerequisites).source_directory
      t.work_directory =
          configuration.for(:prerequisites).work_directory

      t.state_file =
          configuration.for(:prerequisites).state_file

      t.vars = lambda do |args|
        configuration.for(:prerequisites, args)
            .vars
            .to_h
      end
    end
  end

  namespace :harness do
    RakeTerraform.define_command_tasks do |t|
      t.argument_names = [:deployment_identifier]

      t.configuration_name = 'harness'
      t.source_directory = configuration.for(:harness).source_directory
      t.work_directory = configuration.for(:harness).work_directory

      t.state_file = configuration.for(:harness).state_file

      t.vars = lambda do |args|
        configuration.for(:harness, args)
            .vars
            .to_h
      end
    end
  end
end

namespace :version do
  task :bump, [:type] do |_, args|
    next_tag = latest_tag.send("#{args.type}!")
    repo.add_tag(next_tag.to_s)
    repo.push('origin', 'master', tags: true)
    puts "Bumped version to #{next_tag}."
  end

  task :release do
    next_tag = latest_tag.release!
    repo.add_tag(next_tag.to_s)
    repo.push('origin', 'master', tags: true)
    puts "Released version #{next_tag}."
  end
end
