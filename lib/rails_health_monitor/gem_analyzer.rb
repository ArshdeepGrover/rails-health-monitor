module RailsHealthMonitor
  class GemAnalyzer
    def analyze
      gems = Bundler.load.specs
      outdated = check_outdated_gems
      
      {
        total: gems.count,
        outdated: outdated.count,
        vulnerable: check_vulnerable_gems.count,
        details: gem_details(gems, outdated)
      }
    end

    private

    def check_outdated_gems
      `bundle outdated --parseable`.split("\n").map do |line|
        line.split(" ")[0] if line.include?("(")
      end.compact
    end

    def check_vulnerable_gems
      # Simple check - in production, integrate with bundler-audit
      []
    end

    def gem_details(gems, outdated)
      gems.map do |gem|
        {
          name: gem.name,
          version: gem.version.to_s,
          outdated: outdated.include?(gem.name),
          path: gem.gem_dir
        }
      end
    end
  end
end