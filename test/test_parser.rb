$: << File.expand_path(File.dirname(__FILE__) + "/../lib/")
require 'codestat'
require 'minitest/autorun'

class ParserTest < MiniTest::Unit::TestCase

  # Helper to generate output.
  def run_output(opts)
    out = <<-FOO
Loaded suite test_test
Started
.
Finished in 0.000806 seconds.

1 tests, 1 assertions, #{opts[:failures]} failures, #{opts[:errors]} errors, 0 skips

Test run options: --seed 25626
    FOO
  end

  def test_analyze_output_with_no_failures
    status = MiniTest::Mock.new
    status.expect(:exitstatus, 0, [])

    res = run_output(:failures => 0, :errors => 0)
    stat = CodeStat::Parser.new(res, status)

    assert_equal 0, stat.data[:failures]
    assert_equal 0, stat.data[:errors]
    assert_equal 0, stat.data[:exitstatus]
  end

  def test_analyize_output_with_test_errors_and_failures
    status = MiniTest::Mock.new
    status.expect(:exitstatus, 0, [])

    res = run_output(:failures => 1, :errors => 2)
    stat = CodeStat::Parser.new(res, status)

    assert_equal 1, stat.data[:failures]
    assert_equal 2, stat.data[:errors]
  end

  def test_analyze_output_with_bad_exit
    status = MiniTest::Mock.new
    status.expect(:exitstatus, 1, [])

    res = run_output(:failures => 10, :errors => 2)
    stat = CodeStat::Parser.new(res, status)

    assert_equal 10, stat.data[:failures]
    assert_equal 1, stat.data[:exitstatus]
  end

end
