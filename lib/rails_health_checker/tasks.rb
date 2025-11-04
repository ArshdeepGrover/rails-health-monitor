namespace :health do
  desc "Run comprehensive health check"
  task check: :environment do
    RailsHealthChecker.check
  end

  desc "Check gem dependencies"
  task gems: :environment do
    analyzer = RailsHealthChecker::GemAnalyzer.new
    results = analyzer.analyze
    
    puts "=== Gem Health Report ==="
    puts "Total gems: #{results[:total]}"
    puts "Outdated gems: #{results[:outdated]}"
    puts "Vulnerable gems: #{results[:vulnerable]}"
    puts "========================="
  end

  desc "Check database connectivity"
  task database: :environment do
    begin
      ActiveRecord::Base.connection.active?
      puts "✓ Database connection: healthy"
    rescue => e
      puts "✗ Database connection: failed (#{e.message})"
    end
  end

  desc "Check background jobs health"
  task jobs: :environment do
    analyzer = RailsHealthChecker::JobAnalyzer.new
    results = analyzer.analyze
    
    puts "=== Background Jobs Health ==="
    puts "Overall Status: #{results[:status]}"
    
    if results[:sidekiq][:available]
      sidekiq = results[:sidekiq]
      puts "\nSidekiq:"
      puts "  Status: #{sidekiq[:status]}"
      puts "  Enqueued: #{sidekiq[:enqueued]}" unless sidekiq[:error]
      puts "  Failed: #{sidekiq[:failed]}" unless sidekiq[:error]
    end
    
    if results[:resque][:available]
      resque = results[:resque]
      puts "\nResque:"
      puts "  Status: #{resque[:status]}"
      puts "  Pending: #{resque[:pending]}" unless resque[:error]
      puts "  Failed: #{resque[:failed]}" unless resque[:error]
    end
    
    puts "============================="
  end

  desc "Generate detailed health report file"
  task report: :environment do
    results = RailsHealthChecker::Checker.new.run
    report_generator = RailsHealthChecker::ReportGenerator.new(results)
    filename = report_generator.save_to_file
    puts "📄 Health report updated: #{filename}"
  end
end