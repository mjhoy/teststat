module CodeStat

  class Datum

    attr_accessor :data

    # Minitest output:
    # 1 tests, 1 assertions, 1 failures, 0 errors, 0 skips
    TEST_REGEX = /(\d) tests?, (\d) assertions?, (\d) failures?, (\d) errors?/

    def initialize(res)
      ts = Time.now
      tests, assertions, failures, errors =
        res.match(TEST_REGEX).captures
      @data = {
        :tests => tests.to_i,
        :assertions => assertions.to_i,
        :failures => failures.to_i,
        :errors => errors.to_i,
        :timestamp => ts
      }
    end

    def output_stats
      failures, errors = @data[:failures], @data[:errors]
      puts "\n"
      puts "-----"
      puts "CAPTURING TEST (stats): #{failures} failures and #{errors} errors."
    end

  end

end
