require_relative "rails_health_checker/version"
require_relative "rails_health_checker/checker"
require_relative "rails_health_checker/gem_analyzer"
require_relative "rails_health_checker/job_analyzer"
require_relative "rails_health_checker/system_analyzer"
require_relative "rails_health_checker/health_middleware"
require_relative "rails_health_checker/dashboard_middleware"
require_relative "rails_health_checker/report_generator"
require_relative "rails_health_checker/railtie" if defined?(Rails)

module RailsHealthChecker
  class Error < StandardError; end

  def self.check
    Checker.new.run
  end
end