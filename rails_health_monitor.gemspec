require_relative "lib/rails_health_monitor/version"

Gem::Specification.new do |spec|
  spec.name = "rails-health-monitor"
  spec.version = RailsHealthMonitor::VERSION
  spec.authors = ["Arshdeep Singh"]
  spec.email = ["arsh199820@gmail.com"]

  spec.summary = "Comprehensive health monitor for Rails applications and dependencies"
  spec.description = "A Ruby gem that provides comprehensive health monitoring for Rails applications, including database connectivity, gem dependencies, security vulnerabilities, and system health monitoring with a web dashboard."
  spec.homepage = "https://rails-health-monitor.netlify.app"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = "https://rails-health-monitor.netlify.app"
  spec.metadata["source_code_uri"] = "https://github.com/ArshdeepGrover/rails-health-monitor"
  spec.metadata["changelog_uri"] = "https://github.com/ArshdeepGrover/rails-health-monitor/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rails-health-monitor.netlify.app"
  spec.metadata["bug_tracker_uri"] = "https://github.com/ArshdeepGrover/rails-health-monitor/issues"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end