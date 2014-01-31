require "rspec/core/rake_task"
require "certmeister/version"

desc 'Build gem into the pkg directory'
task :build => :spec do
  FileUtils.rm_rf('pkg')
  Dir['*.gemspec'].each do |gemspec|
    system "gem build #{gemspec}"
  end
  FileUtils.mkdir_p('pkg')
  FileUtils.mv(Dir['*.gem'], 'pkg')
end

namespace :bump do
  bump_version = ->(component) do
    sh 'bundle', 'exec', 'semver', 'inc', component
    sh 'bundle'
    sh 'bundle', 'exec', 'semver', 'format', "New version: v%M.%m.%p%s"
  end

  desc 'Bump version [major]'
  task :major => :build do
    bump_version.call('major')
  end
  desc 'Bump version [minor]'
  task :minor => :build do
    bump_version.call('minor')
  end
  desc 'Bump version [patch]'
  task :patch => :build do
    bump_version.call('patch')
  end
end

desc 'Tags version, pushes to remote, and pushes gem'
task :release => :build do
  sh 'git', 'tag', '-m', "Released v#{Certmeister::VERSION}", "v#{Certmeister::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{Certmeister::VERSION}"
  sh "ls pkg/*.gem | xargs -n 1 gem push"
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
