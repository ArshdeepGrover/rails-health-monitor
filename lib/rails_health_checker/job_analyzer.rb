module RailsHealthChecker
  class JobAnalyzer
    def analyze
      {
        sidekiq: analyze_sidekiq,
        resque: analyze_resque,
        active_job: analyze_active_job,
        status: overall_job_status
      }
    end

    private

    def analyze_sidekiq
      return { available: false } unless sidekiq_available?

      stats = Sidekiq::Stats.new
      {
        available: true,
        processed: stats.processed,
        failed: stats.failed,
        enqueued: stats.enqueued,
        retry_size: stats.retry_size,
        dead_size: stats.dead_size,
        workers: stats.workers_size,
        queues: queue_stats,
        status: sidekiq_health_status(stats)
      }
    rescue => e
      { available: true, error: "Sidekiq connection failed: #{e.message}", status: 'error' }
    end

    def analyze_resque
      return { available: false } unless resque_available?

      {
        available: true,
        pending: Resque.info[:pending],
        processed: Resque.info[:processed],
        failed: Resque.info[:failed],
        workers: Resque.info[:workers],
        working: Resque.info[:working],
        queues: Resque.queues.size,
        status: resque_health_status
      }
    rescue => e
      { available: true, error: "Resque connection failed: #{e.message}", status: 'error' }
    end

    def analyze_active_job
      return { available: false } unless active_job_available?

      {
        available: true,
        adapter: ActiveJob::Base.queue_adapter.class.name,
        status: 'healthy'
      }
    rescue => e
      { available: true, error: e.message, status: 'error' }
    end

    def sidekiq_available?
      defined?(Sidekiq)
    end

    def resque_available?
      defined?(Resque)
    end

    def active_job_available?
      defined?(ActiveJob)
    end

    def queue_stats
      return {} unless sidekiq_available?
      
      Sidekiq::Queue.all.map do |queue|
        {
          name: queue.name,
          size: queue.size,
          latency: queue.latency.round(2)
        }
      end
    end

    def sidekiq_health_status(stats)
      return 'critical' if stats.failed > 100
      return 'warning' if stats.enqueued > 1000 || stats.retry_size > 50
      'healthy'
    end

    def resque_health_status
      return 'critical' if Resque.info[:failed] > 100
      return 'warning' if Resque.info[:pending] > 1000
      'healthy'
    end

    def overall_job_status
      statuses = []
      statuses << analyze_sidekiq[:status] if sidekiq_available?
      statuses << analyze_resque[:status] if resque_available?
      
      return 'critical' if statuses.include?('critical') || statuses.include?('error')
      return 'warning' if statuses.include?('warning')
      statuses.empty? ? 'not_configured' : 'healthy'
    end
  end
end