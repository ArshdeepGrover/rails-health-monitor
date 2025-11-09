require_relative "rails_health_monitor/version"
require_relative "rails_health_monitor/checker"
require_relative "rails_health_monitor/gem_analyzer"
require_relative "rails_health_monitor/job_analyzer"
require_relative "rails_health_monitor/system_analyzer"
require_relative "rails_health_monitor/health_middleware"
require_relative "rails_health_monitor/dashboard_middleware"
require_relative "rails_health_monitor/report_generator"
require_relative "rails_health_monitor/railtie" if defined?(Rails)

module RailsHealthMonitor
  class Error < StandardError; end

  def self.check
    Checker.new.run
  end
end