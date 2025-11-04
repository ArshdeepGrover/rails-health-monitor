module RailsHealthChecker
  class Checker
    def run
      results = {
        rails_version: check_rails_version,
        ruby_version: check_ruby_version,
        database: check_database_connection,
        gems: check_gems_health,
        security: check_security_vulnerabilities,
        jobs: check_background_jobs,
        system: check_system_details
      }
      
      generate_report(results)
    end

    private

    def check_rails_version
      {
        current: Rails.version,
        supported: rails_version_supported?,
        status: rails_version_supported? ? "healthy" : "outdated"
      }
    end

    def check_ruby_version
      {
        current: RUBY_VERSION,
        supported: ruby_version_supported?,
        status: ruby_version_supported? ? "healthy" : "outdated"
      }
    end

    def check_database_connection
      ActiveRecord::Base.connection.active?
      { status: "healthy", connected: true }
    rescue => e
      { status: "unhealthy", connected: false, error: e.message }
    end

    def check_gems_health
      GemAnalyzer.new.analyze
    end

    def check_security_vulnerabilities
      outdated_gems = `bundle outdated --parseable`.split("\n")
      {
        outdated_count: outdated_gems.length,
        status: outdated_gems.empty? ? "secure" : "needs_attention"
      }
    end

    def check_background_jobs
      JobAnalyzer.new.analyze
    end

    def check_system_details
      SystemAnalyzer.new.analyze
    end

    def rails_version_supported?
      Rails.version >= "6.0"
    end

    def ruby_version_supported?
      RUBY_VERSION >= "2.7"
    end

    def generate_report(results)
      puts "\n=== Rails Health Check Report ==="
      puts "Rails Version: #{results[:rails_version][:current]} (#{results[:rails_version][:status]})"
      puts "Ruby Version: #{results[:ruby_version][:current]} (#{results[:ruby_version][:status]})"
      puts "Database: #{results[:database][:status]}"
      puts "Gems: #{results[:gems][:total]} total, #{results[:gems][:outdated]} outdated"
      puts "Security: #{results[:security][:status]}"
      puts "Background Jobs: #{results[:jobs][:status]}"
      puts "================================\n"
      
      # Generate markdown report
      report_generator = ReportGenerator.new(results)
      filename = report_generator.save_to_file
      puts "📄 Detailed report saved to: #{filename} (previous report replaced)"
      
      results
    end
  end
end