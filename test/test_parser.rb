$: << File.expand_path(File.dirname(__FILE__) + "/../lib/")
require 'codestat'
require 'minitest/autorun'

class ParserTest < MiniTest::Unit::TestCase

  def setup
    @output = Proc.new do |d|
      <<-FOO
Loaded suite test_test
Started
.
Finished in 0.000806 seconds.

1 tests, 1 assertions, #{d[:failures]} failures, #{d[:errors]} errors, 0 skips

Test run options: --seed 25626
    FOO
    end
  end

  def test_analyze_output_with_no_failures
    pid = spawn("exit;")
    rc, status = Process::waitpid2(pid)

    res = @output.call(:failures => 0, :errors => 0)
    stat = CodeStat::Parser.new(res, status)
    assert_equal 0, stat.data[:failures]
    assert_equal 0, stat.data[:errors]
    assert_equal 0, stat.data[:exitstatus]
  end

  def test_analyize_output_with_test_errors_and_failures
    pid = spawn("exit;")
    rc, status = Process::waitpid2(pid)
    res = @output.call(:failures => 1, :errors => 2)
    stat = CodeStat::Parser.new(res, status)
    assert_equal 1, stat.data[:failures]
    assert_equal 2, stat.data[:errors]
  end

  def test_analyze_output_with_bad_exit
    pid = spawn("exit 1;")
    rc, status = Process::waitpid2(pid)
    res = @output.call(:failures => 10, :errors => 2)
    stat = CodeStat::Parser.new(res, status)

    assert_equal 10, stat.data[:failures]
    assert_equal 1, stat.data[:exitstatus]
  end

end
