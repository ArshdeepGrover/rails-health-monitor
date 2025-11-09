module RailsHealthMonitor
  class DashboardMiddleware
    def initialize(app)
      @app = app
      require 'rack/auth/basic'
    end

    def call(env)
      if env['PATH_INFO'] == '/health'
        authenticate(env) ? dashboard_response : unauthorized_response
      else
        @app.call(env)
      end
    end

    private

    def authenticate(env)
      auth = Rack::Auth::Basic::Request.new(env)
      auth.provided? && auth.basic? && auth.credentials && 
        auth.credentials == [username, password]
    end

    def username
      ENV['HEALTH_USERNAME'] || 'admin'
    end

    def password
      ENV['HEALTH_PASSWORD'] || 'health123'
    end

    def unauthorized_response
      [
        401,
        {
          'Content-Type' => 'text/html',
          'WWW-Authenticate' => 'Basic realm="Health Dashboard"'
        },
        ['<h1>401 Unauthorized</h1><p>Please provide valid credentials.</p>']
      ]
    end

    def dashboard_response
      results = RailsHealthMonitor::Checker.new.run
      
      [
        200,
        { 'Content-Type' => 'text/html' },
        [generate_dashboard_html(results)]
      ]
    end

    def generate_dashboard_html(results)
      <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <title>Rails Health Dashboard</title>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f7fa; }
            .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
            .header { text-align: center; margin-bottom: 30px; }
            .header h1 { color: #2d3748; font-size: 2.5rem; margin-bottom: 10px; }
            .timestamp { color: #718096; font-size: 0.9rem; }
            .search-container { margin: 20px 0; text-align: center; }
            .search-box { padding: 12px 20px; border: 2px solid #e2e8f0; border-radius: 25px; width: 300px; font-size: 1rem; outline: none; }
            .search-box:focus { border-color: #4299e1; }
            .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }
            .card { background: white; border-radius: 12px; padding: 24px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; }
            .card h3 { color: #2d3748; margin-bottom: 16px; font-size: 1.2rem; display: flex; align-items: center; gap: 8px; }
            .status-healthy { color: #38a169; }
            .status-warning { color: #d69e2e; }
            .status-error { color: #e53e3e; }
            .status-loaded { color: #38a169; }
            .status-missing { color: #e53e3e; }
            .status-not_loaded { color: #718096; }
            .metric { display: flex; justify-content: space-between; align-items: center; padding: 8px 0; border-bottom: 1px solid #f7fafc; }
            .metric:last-child { border-bottom: none; }
            .metric-label { color: #4a5568; }
            .metric-value { font-weight: 600; }
            .lib-item { padding: 6px 12px; margin: 2px 0; background: #f7fafc; border-radius: 4px; display: flex; justify-content: space-between; align-items: center; font-size: 0.9rem; }
            .lib-required { border-left: 3px solid #4299e1; }
            .lib-optional { border-left: 3px solid #38a169; }
            .lib-missing { background: #fed7d7; }
            .expandable { max-height: 200px; overflow-y: auto; }
            .health-score { text-align: center; padding: 20px; }
            .score-circle { width: 120px; height: 120px; border-radius: 50%; margin: 0 auto 16px; display: flex; align-items: center; justify-content: center; font-size: 2rem; font-weight: bold; color: white; }
            .score-excellent { background: linear-gradient(135deg, #38a169, #48bb78); }
            .score-good { background: linear-gradient(135deg, #d69e2e, #ecc94b); }
            .score-warning { background: linear-gradient(135deg, #ed8936, #f6ad55); }
            .score-critical { background: linear-gradient(135deg, #e53e3e, #fc8181); }
            .gem-list { max-height: 200px; overflow-y: auto; }
            .gem-item { padding: 8px 12px; margin: 4px 0; background: #f7fafc; border-radius: 6px; display: flex; justify-content: space-between; }
            .gem-outdated { background: #fed7d7; }
            .actions { background: white; border-radius: 12px; padding: 24px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
            .action-item { padding: 12px; margin: 8px 0; border-radius: 8px; display: flex; align-items: center; gap: 12px; }
            .action-critical { background: #fed7d7; border-left: 4px solid #e53e3e; }
            .action-high { background: #fef5e7; border-left: 4px solid #d69e2e; }
            .action-medium { background: #e6fffa; border-left: 4px solid #38a169; }
            .refresh-btn { position: fixed; bottom: 20px; right: 20px; background: #4299e1; color: white; border: none; padding: 12px 24px; border-radius: 25px; cursor: pointer; box-shadow: 0 4px 12px rgba(66, 153, 225, 0.3); }
            .refresh-btn:hover { background: #3182ce; }
            .auto-refresh-btn { position: fixed; bottom: 20px; right: 180px; background: #38a169; color: white; border: none; padding: 12px 24px; border-radius: 25px; cursor: pointer; box-shadow: 0 4px 12px rgba(56, 161, 105, 0.3); }
            .auto-refresh-btn:hover { background: #2f855a; }
            .auto-refresh-btn.disabled { background: #718096; }
            .auto-refresh-btn.disabled:hover { background: #4a5568; }
            .hidden { display: none; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>🏥 Rails Health Dashboard</h1>
              <div class="timestamp">Last updated: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}</div>
              <div class="search-container">
                <input type="text" class="search-box" placeholder="Search libraries (e.g., sidekiq, redis, puma...)" id="libSearch">
              </div>
            </div>

            <div class="grid">
              #{system_overview_card(results)}
              #{libraries_card(results)}
              #{database_card(results)}
              #{gems_card(results)}
              #{security_card(results)}
              #{jobs_card(results)}
            </div>

            #{health_score_card(results)}
            #{priority_actions_card(results)}
          </div>

          <button class="auto-refresh-btn" id="autoRefreshBtn" onclick="toggleAutoRefresh()">⏸️ Auto-Refresh: ON</button>
          <button class="refresh-btn" onclick="location.reload()">🔄 Refresh</button>

          <script>
            let autoRefreshEnabled = true;
            let refreshTimer;
            
            function startAutoRefresh() {
              if (autoRefreshEnabled) {
                refreshTimer = setTimeout(() => location.reload(), 30000);
              }
            }
            
            function toggleAutoRefresh() {
              const btn = document.getElementById('autoRefreshBtn');
              autoRefreshEnabled = !autoRefreshEnabled;
              
              if (autoRefreshEnabled) {
                btn.textContent = '⏸️ Auto-Refresh: ON';
                btn.classList.remove('disabled');
                startAutoRefresh();
              } else {
                btn.textContent = '▶️ Auto-Refresh: OFF';
                btn.classList.add('disabled');
                clearTimeout(refreshTimer);
              }
            }
            
            // Start auto-refresh on page load
            startAutoRefresh();
            
            // Search functionality
            document.getElementById('libSearch').addEventListener('input', function(e) {
              const searchTerm = e.target.value.toLowerCase();
              const libItems = document.querySelectorAll('.lib-item');
              
              libItems.forEach(item => {
                const libName = item.querySelector('.lib-name').textContent.toLowerCase();
                const libPurpose = item.querySelector('.lib-purpose').textContent.toLowerCase();
                
                if (libName.includes(searchTerm) || libPurpose.includes(searchTerm)) {
                  item.classList.remove('hidden');
                } else {
                  item.classList.add('hidden');
                }
              });
            });
          </script>
        </body>
        </html>
      HTML
    end

    def system_overview_card(results)
      rails_status = results[:rails_version][:status]
      ruby_status = results[:ruby_version][:status]
      system = results[:system]
      
      <<~HTML
        <div class="card">
          <h3>🔧 System Overview</h3>
          <div class="metric">
            <span class="metric-label">Rails Version</span>
            <span class="metric-value status-#{rails_status}">#{results[:rails_version][:current]}</span>
          </div>
          <div class="metric">
            <span class="metric-label">Ruby Version</span>
            <span class="metric-value status-#{ruby_status}">#{results[:ruby_version][:current]}</span>
          </div>
          <div class="metric">
            <span class="metric-label">Environment</span>
            <span class="metric-value">#{system[:environment_info][:rails_env]}</span>
          </div>
          <div class="metric">
            <span class="metric-label">Web Server</span>
            <span class="metric-value">#{system[:server_requirements][:web_server].capitalize}</span>
          </div>
          <div class="metric">
            <span class="metric-label">Database</span>
            <span class="metric-value">#{system[:server_requirements][:database]}</span>
          </div>
          <div class="metric">
            <span class="metric-label">Cache Store</span>
            <span class="metric-value">#{system[:server_requirements][:cache_store][:type].split('::').last}</span>
          </div>
          <div style="font-size: 0.8rem; color: #718096; margin-top: 4px;">#{system[:server_requirements][:cache_store][:explanation]}</div>
          <div style="font-size: 0.8rem; color: #4299e1; margin-top: 2px;">💡 #{system[:server_requirements][:cache_store][:recommendation]}</div>
        </div>
      HTML
    end

    def database_card(results)
      db_status = results[:database][:status]
      status_class = db_status == 'healthy' ? 'status-healthy' : 'status-error'
      
      <<~HTML
        <div class="card">
          <h3>💾 Database</h3>
          <div class="metric">
            <span class="metric-label">Connection Status</span>
            <span class="metric-value #{status_class}">#{db_status.capitalize}</span>
          </div>
          <div class="metric">
            <span class="metric-label">Connected</span>
            <span class="metric-value">#{results[:database][:connected] ? '✅ Yes' : '❌ No'}</span>
          </div>
        </div>
      HTML
    end

    def gems_card(results)
      outdated_count = results[:gems][:outdated]
      total_count = results[:gems][:total]
      
      <<~HTML
        <div class="card">
          <h3>📦 Gem Dependencies</h3>
          <div class="metric">
            <span class="metric-label">Total Gems</span>
            <span class="metric-value">#{total_count}</span>
          </div>
          <div class="metric">
            <span class="metric-label">Outdated</span>
            <span class="metric-value status-#{outdated_count > 0 ? 'warning' : 'healthy'}">#{outdated_count}</span>
          </div>
          <div class="gem-list">
            #{gem_list_html(results[:gems][:details])}
          </div>
        </div>
      HTML
    end

    def gem_list_html(gems)
      gems.first(10).map do |gem|
        css_class = gem[:outdated] ? 'gem-item gem-outdated' : 'gem-item'
        status = gem[:outdated] ? '⚠️' : '✅'
        <<~HTML
          <div class="#{css_class}">
            <span>#{gem[:name]}</span>
            <span>#{status} #{gem[:version]}</span>
          </div>
        HTML
      end.join
    end

    def security_card(results)
      security_status = results[:security][:status]
      outdated_count = results[:security][:outdated_count]
      
      <<~HTML
        <div class="card">
          <h3>🔒 Security</h3>
          <div class="metric">
            <span class="metric-label">Status</span>
            <span class="metric-value status-#{security_status == 'secure' ? 'healthy' : 'warning'}">#{security_status.capitalize}</span>
          </div>
          <div class="metric">
            <span class="metric-label">Issues Found</span>
            <span class="metric-value">#{outdated_count}</span>
          </div>
        </div>
      HTML
    end

    def health_score_card(results)
      score = calculate_health_score(results)
      score_class, score_text = get_score_class_and_text(score)
      reasons = get_dashboard_score_reasons(results)
      
      <<~HTML
        <div class="card health-score">
          <h3>🏆 Overall Health Score</h3>
          <div class="score-circle #{score_class}">#{score}</div>
          <div style="font-size: 1.2rem; font-weight: 600; color: #2d3748; margin-bottom: 16px;">#{score_text}</div>
          #{reasons}
        </div>
      HTML
    end

    def priority_actions_card(results)
      actions = generate_priority_actions(results)
      
      <<~HTML
        <div class="actions">
          <h3>🎯 Priority Actions</h3>
          #{actions.empty? ? '<p style="text-align: center; color: #38a169; font-size: 1.1rem;">✅ No critical actions required!</p>' : actions.join}
        </div>
      HTML
    end

    def calculate_health_score(results)
      score = 100
      score -= 20 if results[:rails_version][:status] == 'outdated'
      score -= 15 if results[:ruby_version][:status] == 'outdated'
      score -= 30 if results[:database][:status] == 'unhealthy'
      score -= (results[:gems][:outdated] * 2)
      score -= (results[:security][:outdated_count] * 3)
      [score, 0].max
    end

    def get_score_class_and_text(score)
      case score
      when 90..100 then ['score-excellent', 'Excellent']
      when 70..89 then ['score-good', 'Good']
      when 50..69 then ['score-warning', 'Needs Attention']
      else ['score-critical', 'Critical']
      end
    end

    def jobs_card(results)
      jobs = results[:jobs]
      job_status = jobs[:status]
      status_class = case job_status
                     when 'healthy' then 'status-healthy'
                     when 'warning' then 'status-warning'
                     when 'critical', 'error' then 'status-error'
                     else 'status-warning'
                     end
      
      <<~HTML
        <div class="card">
          <h3>⚙️ Background Jobs</h3>
          <div class="metric">
            <span class="metric-label">Overall Status</span>
            <span class="metric-value #{status_class}">#{job_status.capitalize}</span>
          </div>
          #{job_details_html(jobs)}
        </div>
      HTML
    end

    def job_details_html(jobs)
      details = []
      
      if jobs[:sidekiq][:available]
        sidekiq = jobs[:sidekiq]
        if sidekiq[:error]
          details << '<div class="metric"><span class="metric-label">Sidekiq</span><span class="metric-value status-error">Error</span></div>'
          details << "<div style=\"font-size: 0.8rem; color: #e53e3e; margin-top: 4px;\">#{sidekiq[:error]}</div>"
        else
          details << "<div class=\"metric\"><span class=\"metric-label\">Sidekiq Enqueued</span><span class=\"metric-value\">#{sidekiq[:enqueued]}</span></div>"
          details << "<div class=\"metric\"><span class=\"metric-label\">Sidekiq Failed</span><span class=\"metric-value\">#{sidekiq[:failed]}</span></div>"
        end
      end
      
      if jobs[:resque][:available]
        resque = jobs[:resque]
        if resque[:error]
          details << '<div class="metric"><span class="metric-label">Resque</span><span class="metric-value status-error">Error</span></div>'
          details << "<div style=\"font-size: 0.8rem; color: #e53e3e; margin-top: 4px;\">#{resque[:error]}</div>"
        else
          details << "<div class=\"metric\"><span class=\"metric-label\">Resque Pending</span><span class=\"metric-value\">#{resque[:pending]}</span></div>"
          details << "<div class=\"metric\"><span class=\"metric-label\">Resque Failed</span><span class=\"metric-value\">#{resque[:failed]}</span></div>"
        end
      end
      
      if jobs[:active_job][:available]
        active_job = jobs[:active_job]
        details << "<div class=\"metric\"><span class=\"metric-label\">ActiveJob Adapter</span><span class=\"metric-value\">#{active_job[:adapter]}</span></div>"
      end
      
      details.empty? ? '<div class="metric"><span class="metric-label">Status</span><span class="metric-value">Not Configured</span></div>' : details.join
    end

    def generate_priority_actions(results)
      actions = []
      
      if results[:database][:status] == 'unhealthy'
        actions << '<div class="action-item action-critical">🔴 <strong>CRITICAL:</strong> Fix database connection immediately</div>'
      end
      
      if results[:jobs][:status] == 'critical'
        actions << '<div class="action-item action-critical">🔴 <strong>CRITICAL:</strong> Background job system failure</div>'
      end
      
      if results[:rails_version][:status] == 'outdated'
        actions << '<div class="action-item action-high">🟡 <strong>HIGH:</strong> Update Rails framework</div>'
      end
      
      if results[:security][:outdated_count] > 5
        actions << '<div class="action-item action-high">🟡 <strong>HIGH:</strong> Address security vulnerabilities</div>'
      end
      
      if results[:jobs][:status] == 'warning'
        actions << '<div class="action-item action-medium">🟡 <strong>MEDIUM:</strong> Check background job queues</div>'
      end
      
      if results[:gems][:outdated] > 10
        actions << '<div class="action-item action-medium">🟢 <strong>MEDIUM:</strong> Update outdated gems</div>'
      end
      
      actions
    end

    def get_dashboard_score_reasons(results)
      score = calculate_health_score(results)
      return '' if score >= 90
      
      reasons = []
      
      if results[:database][:status] == 'unhealthy'
        reasons << '<div style="color: #e53e3e; font-size: 0.9rem; margin: 4px 0;">❌ Database connection failed</div>'
      end
      
      if results[:rails_version][:status] == 'outdated'
        reasons << '<div style="color: #d69e2e; font-size: 0.9rem; margin: 4px 0;">⚠️ Rails version outdated</div>'
      end
      
      if results[:gems][:outdated] > 20
        reasons << '<div style="color: #d69e2e; font-size: 0.9rem; margin: 4px 0;">⚠️ Many outdated gems (#{results[:gems][:outdated]})</div>'
      end
      
      if results[:security][:outdated_count] > 10
        reasons << '<div style="color: #d69e2e; font-size: 0.9rem; margin: 4px 0;">⚠️ Security vulnerabilities (#{results[:security][:outdated_count]})</div>'
      end
      
      if results[:jobs][:status] == 'critical'
        reasons << '<div style="color: #e53e3e; font-size: 0.9rem; margin: 4px 0;">❌ Background jobs critical</div>'
      end
      
      return '' if reasons.empty?
      
      '<div style="margin-top: 12px; padding-top: 12px; border-top: 1px solid #e2e8f0;">' +
      '<div style="font-size: 0.9rem; font-weight: 600; color: #4a5568; margin-bottom: 8px;">Issues affecting score:</div>' +
      reasons.join +
      '</div>'
    end

    def libraries_card(results)
      system = results[:system]
      required_libs = system[:required_libs]
      optional_libs = system[:optional_libs]
      
      <<~HTML
        <div class="card">
          <h3>📚 Required Libraries</h3>
          <div class="expandable">
            #{library_list_html(required_libs, 'required')}
          </div>
          <h3 style="margin-top: 20px;">🔌 Optional Libraries</h3>
          <div class="expandable">
            #{library_list_html(optional_libs, 'optional')}
          </div>
        </div>
      HTML
    end

    def library_list_html(libraries, type)
      libraries.map do |name, info|
        status_class = "status-#{info[:status]}"
        lib_class = "lib-item lib-#{type}"
        lib_class += " lib-missing" if info[:status] == 'missing'
        
        version_text = info[:version] ? " (#{info[:version]})" : ''
        status_text = info[:status] == 'loaded' ? '✅' : (info[:status] == 'missing' ? '❌' : '⏸️')
        
        <<~HTML
          <div class="#{lib_class}">
            <div>
              <span class="lib-name">#{name}#{version_text}</span>
              <div class="lib-purpose" style="font-size: 0.8rem; color: #718096;">#{info[:purpose]}</div>
            </div>
            <span class="#{status_class}">#{status_text}</span>
          </div>
        HTML
      end.join
    end
  end
end