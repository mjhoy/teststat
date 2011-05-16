module CodeStat
  class Stats

    attr_accessor :total_runs

    def initialize(stats)
      @stats = stats
      @total_runs = stats.length
    end

    def stat(key)
      if key == :success
        success_stat
      elsif key == :badexits
        bad_exit_stat
      else
        d = { :sum => 0, :any => 0 }
        @stats.each { |s| d[:sum] += (s[key] || 0) }
        d[:mean] = d[:sum].to_f / @total_runs
        d
      end
    end

    def bad_exit_stat
      d = { :sum => 0 }
      @stats.each do |s| 
        d[:sum] += 1 unless s[:exitstatus] == 0
      end
      d
    end

    def success_stat
      d = { :sum => 0 }
      @stats.each do |s| 
        d[:sum] += 1 unless ((s[:errors] || 0) + 
                             (s[:failures] || 0) +
                             (s[:exitstatus] || 0)) > 0
      end
      d[:mean] = d[:sum].to_f / @total_runs
      d
    end

    def print_stats
      buf = "Out of #{@total_runs} total runs, " +  
        "you had #{stat(:errors)[:sum]} errors, " +
        "#{stat(:failures)[:sum]} failures, " +
        "#{stat(:badexits)[:sum]} bad exits, " +
        "and #{stat(:success)[:sum]} successes."
    end

    def output_stats
      puts print_stats
    end
  end
end
