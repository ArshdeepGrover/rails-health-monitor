module RailsHealthMonitor
  class SystemAnalyzer
    def analyze
      {
        rails_info: rails_system_info,
        required_libs: check_required_libraries,
        optional_libs: check_optional_libraries,
        server_requirements: check_server_requirements,
        cable_info: check_action_cable,
        environment_info: environment_details
      }
    end

    private

    def rails_system_info
      {
        version: Rails.version,
        environment: Rails.env,
        root: Rails.root.to_s,
        config_loaded: Rails.application.config.loaded?,
        eager_load: Rails.application.config.eager_load,
        cache_classes: Rails.application.config.cache_classes
      }
    rescue => e
      { error: e.message }
    end

    def check_required_libraries
      required = {
        'bundler' => { required: true, available: defined?(Bundler), purpose: 'Dependency management' },
        'rack' => { required: true, available: defined?(Rack), purpose: 'Web server interface' },
        'activerecord' => { required: true, available: defined?(ActiveRecord), purpose: 'Database ORM' },
        'actionpack' => { required: true, available: defined?(ActionPack), purpose: 'Web framework core' },
        'activesupport' => { required: true, available: defined?(ActiveSupport), purpose: 'Core extensions' }
      }
      
      required.each do |name, info|
        info[:status] = info[:available] ? 'loaded' : 'missing'
        info[:version] = get_gem_version(name) if info[:available]
      end
      
      required
    end

    def check_optional_libraries
      optional = {
        'sidekiq' => { available: defined?(Sidekiq), purpose: 'Background job processing' },
        'resque' => { available: defined?(Resque), purpose: 'Background job processing' },
        'redis' => { available: defined?(Redis), purpose: 'In-memory data store' },
        'puma' => { available: defined?(Puma), purpose: 'Web server' },
        'unicorn' => { available: defined?(Unicorn), purpose: 'Web server' },
        'passenger' => { available: defined?(PhusionPassenger), purpose: 'Web server' },
        'devise' => { available: defined?(Devise), purpose: 'Authentication' },
        'cancancan' => { available: defined?(CanCan), purpose: 'Authorization' },
        'turbo-rails' => { available: defined?(Turbo), purpose: 'SPA-like experience' },
        'stimulus-rails' => { available: defined?(Stimulus), purpose: 'JavaScript framework' },
        'bootsnap' => { available: defined?(Bootsnap), purpose: 'Boot optimization' },
        'sprockets' => { available: defined?(Sprockets), purpose: 'Asset pipeline' }
      }
      
      optional.each do |name, info|
        info[:status] = info[:available] ? 'loaded' : 'not_loaded'
        info[:version] = get_gem_version(name) if info[:available]
      end
      
      optional
    end

    def check_server_requirements
      {
        web_server: detect_web_server,
        database: detect_database_adapter,
        cache_store: detect_cache_store,
        session_store: detect_session_store,
        asset_host: (Rails.application.config.asset_host rescue nil)
      }
    end

    def check_action_cable
      return { available: false } unless defined?(ActionCable)
      
      {
        available: true,
        adapter: (ActionCable.server.config.cable[:adapter] rescue 'unknown'),
        url: (ActionCable.server.config.cable[:url] rescue nil),
        allowed_request_origins: (ActionCable.server.config.allowed_request_origins rescue []),
        status: action_cable_status
      }
    end

    def environment_details
      {
        ruby_version: RUBY_VERSION,
        ruby_platform: RUBY_PLATFORM,
        rails_env: Rails.env,
        rack_env: ENV['RACK_ENV'],
        database_url: ENV['DATABASE_URL'] ? 'configured' : 'not_set',
        redis_url: ENV['REDIS_URL'] ? 'configured' : 'not_set',
        secret_key_base: ENV['SECRET_KEY_BASE'] ? 'configured' : 'not_set'
      }
    end

    def get_gem_version(gem_name)
      Gem.loaded_specs[gem_name]&.version&.to_s || 'unknown'
    rescue
      'unknown'
    end

    def detect_web_server
      return 'puma' if defined?(Puma)
      return 'unicorn' if defined?(Unicorn)
      return 'passenger' if defined?(PhusionPassenger)
      return 'thin' if defined?(Thin)
      return 'webrick' if defined?(WEBrick)
      'unknown'
    end

    def detect_database_adapter
      ActiveRecord::Base.connection.adapter_name
    rescue
      'unknown'
    end

    def detect_cache_store
      cache_class = Rails.cache.class.name
      {
        type: cache_class,
        explanation: get_cache_explanation(cache_class),
        recommendation: get_cache_recommendation(cache_class)
      }
    rescue
      {
        type: 'unknown',
        explanation: 'Unable to detect cache store',
        recommendation: 'Check Rails cache configuration'
      }
    end

    def detect_session_store
      Rails.application.config.session_store.name
    rescue
      'unknown'
    end

    def action_cable_status
      return 'healthy' if ActionCable.server.config.cable[:adapter] != 'test'
      'not_configured'
    rescue
      'error'
    end

    def get_cache_explanation(cache_class)
      explanations = {
        'ActiveSupport::Cache::NullStore' => 'No caching (common in development)',
        'ActiveSupport::Cache::MemoryStore' => 'In-memory caching (single process)',
        'ActiveSupport::Cache::FileStore' => 'File-based caching (disk storage)',
        'ActiveSupport::Cache::RedisStore' => 'Redis-based caching (recommended for production)',
        'ActiveSupport::Cache::MemCacheStore' => 'Memcached-based caching (production ready)',
        'ActiveSupport::Cache::RedisCacheStore' => 'Redis caching with Rails 5.2+ features'
      }
      explanations[cache_class] || 'Custom or unknown cache store'
    end

    def get_cache_recommendation(cache_class)
      case cache_class
      when 'ActiveSupport::Cache::NullStore'
        Rails.env.production? ? 'Configure Redis or Memcached for production' : 'OK for development'
      when 'ActiveSupport::Cache::MemoryStore'
        'Consider Redis/Memcached for multi-server deployments'
      when 'ActiveSupport::Cache::FileStore'
        'Consider Redis/Memcached for better performance'
      when 'ActiveSupport::Cache::RedisStore', 'ActiveSupport::Cache::RedisCacheStore'
        'Excellent choice for production'
      when 'ActiveSupport::Cache::MemCacheStore'
        'Good choice for production'
      else
        'Verify cache store configuration'
      end
    end
  end
end