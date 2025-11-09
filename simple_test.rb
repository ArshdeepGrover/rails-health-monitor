#!/usr/bin/env ruby

require_relative 'lib/rails_health_monitor/version'
require_relative 'lib/rails_health_monitor/gem_analyzer'

puts "=== Simple Gem Test ==="
puts "Version: #{RailsHealthChecker::VERSION}"

# Test gem analyzer with mocked Bundler
module Bundler
  def self.load
    MockBundler.new
  end
end

class MockBundler
  def specs
    [
      MockGem.new('rails', '7.0.0'),
      MockGem.new('rspec', '3.12.0')
    ]
  end
end

class MockGem
  attr_reader :name, :version
  
  def initialize(name, version)
    @name = name
    @version = MockVersion.new(version)
  end
  
  def gem_dir
    "/path/to/#{name}"
  end
end

class MockVersion
  def initialize(version)
    @version = version
  end
  
  def to_s
    @version
  end
end

analyzer = RailsHealthChecker::GemAnalyzer.new
results = analyzer.analyze

puts "✓ Gem analysis: #{results[:total]} gems, #{results[:outdated]} outdated"
puts "✅ Basic functionality works!"