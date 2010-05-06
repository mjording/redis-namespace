task :default => :spec
task :test    => :spec

desc "Build a gem"
task :gem => [ :gemspec, :build ]

desc "Run specs"
task :spec do
  exec "spec spec/redis_spec.rb"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "opengotham_redis-namespace"
    gemspec.summary = "Namespaces Redis commands."
    gemspec.email = "mjording@opengotham.com"
    gemspec.homepage = "http://github.com/opengotham/redis-namespace"
    gemspec.authors = ["Matthew Jording"]
    gemspec.version = '0.4.3'
    gemspec.add_dependency 'redis', ">= 2.0.0.rc2"
    gemspec.description = <<description
Adds a Redis::Namespace class which can be used to namespace calls
to Redis. This is useful when using a single instance of Redis with
multiple, different applications.
description
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  warn "Jeweler not available. Install it with:"
  warn "gem install jeweler"
end
