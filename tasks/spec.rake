begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  require 'spec'
end
begin
  require 'spec/rake/spectask'
rescue LoadError
  puts <<-EOS
To use rspec for testing you must install rspec gem:
    gem install rspec
EOS
  exit(0)
end

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  desc "Run all specs in the presence of ActiveSupport"
  Spec::Rake::SpecTask.new(:with_active_support) do |t|
    t.spec_opts = ['--options', "spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.ruby_opts << "-r #{File.join(File.dirname(__FILE__), *%w[gem_loader load_active_support])}"
  end

  desc "Run all specs in the presence of the tzinfo gem"
  Spec::Rake::SpecTask.new(:with_tzinfo_gem) do |t|
    t.spec_opts = ['--options', "spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.ruby_opts << "-r #{File.join(File.dirname(__FILE__), *%w[gem_loader load_tzinfo_gem])}"
  end
end

if RUBY_VERSION.match(/^1\.8\./)
  desc 'Run all specs with RCov'
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_dir = "coverage"
    t.rcov_opts = ['--exclude', 'spec']
  end
end
  