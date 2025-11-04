#!/usr/bin/env ruby

# Simple test script to verify gem functionality
require_relative 'lib/rails_health_checker'

# Mock Rails and ActiveRecord for testing
module Rails
  def self.version
    "7.0.0"
  end
end

module ActiveRecord
  class Base
    def self.connection
      MockConnection.new
    end
  end
end

class MockConnection
  def active?
    true
  end
end

class Time
  def self.current
    Time.now
  end
end

# Mock Bundler
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

# Test the gem
puts "Testing RailsHealthChecker gem..."

begin
  # Test version
  puts "✓ Version: #{RailsHealthChecker::VERSION}"
  
  # Test checker
  checker = RailsHealthChecker::Checker.new
  results = checker.run
  puts "✓ Health check completed"
  
  # Test gem analyzer
  analyzer = RailsHealthChecker::GemAnalyzer.new
  gem_results = analyzer.analyze
  puts "✓ Gem analysis completed: #{gem_results[:total]} gems found"
  
  # Test middleware
  middleware = RailsHealthChecker::HealthMiddleware.new(nil)
  env = { 'PATH_INFO' => '/health' }
  response = middleware.call(env)
  puts "✓ Health endpoint returns: #{response[0]} status"
  
  puts "\n✅ All tests passed!"
  
rescue => e
  puts "❌ Test failed: #{e.message}"
  puts e.backtrace.first(3)
end