module RailsHealthChecker
  class HealthMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      if env['PATH_INFO'] == '/health'
        health_check_response
      else
        @app.call(env)
      end
    end

    private

    def health_check_response
      status = perform_quick_health_check
      
      [
        status[:code],
        { 'Content-Type' => 'application/json' },
        [status[:body].to_json]
      ]
    end

    def perform_quick_health_check
      begin
        db_healthy = ActiveRecord::Base.connection.active?
        
        {
          code: 200,
          body: {
            status: 'healthy',
            timestamp: Time.current.iso8601,
            database: db_healthy ? 'connected' : 'disconnected',
            rails_version: Rails.version,
            ruby_version: RUBY_VERSION
          }
        }
      rescue => e
        {
          code: 503,
          body: {
            status: 'unhealthy',
            timestamp: Time.current.iso8601,
            error: e.message
          }
        }
      end
    end
  end
end