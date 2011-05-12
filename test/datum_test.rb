$: << File.expand_path(File.dirname(__FILE__) + "/../lib/")
require 'codestat'
require 'minitest/autorun'

class DatumTest < MiniTest::Unit::TestCase

  def test_loads
    assert CodeStat::Datum
  end

  def test_analyze_output
    output = Proc.new do |d|
      <<-FOO
Loaded suite test_test
Started
.
Finished in 0.000806 seconds.

1 tests, 1 assertions, #{d[:failures]} failures, #{d[:errors]} errors, 0 skips

Test run options: --seed 25626
    FOO
    end

    stat1 = CodeStat::Datum.new(output.call(:failures => 0, :errors => 0))
    assert_equal 0, stat1.data[:failures]
    assert_equal 0, stat1.data[:errors]

    stat2 = CodeStat::Datum.new(output.call(:failures => 1, :errors => 2))
    assert_equal 1, stat2.data[:failures]
    assert_equal 2, stat2.data[:errors]
  end

end
