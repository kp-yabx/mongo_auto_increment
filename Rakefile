require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "benchmark"
require File.expand_path("../spec/spec_helper", __FILE__)

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :benchmark do
  Benchmark.bm do|bm|
    Post.delete_all
    bm.report("Generate 1") do
      1.times do
        Post.create(:title => "Foo bar")
      end
    end
    puts "Post current: #{Post.count}"
    puts ""

    bm.report("Generate 100") do
      100.times do
        Post.create(:title => "Foo bar")
      end
    end
    puts "Post current: #{Post.count}"
    puts ""

    bm.report("Generate 10,000") do
      10_000.times do
        Post.create(:title => "Foo bar")
      end
    end
    puts "Post current: #{Post.count}"
    puts ""
  end
end
