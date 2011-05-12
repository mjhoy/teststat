$: << File.expand_path(File.dirname(__FILE__) + "/../lib/")
require 'codestat'
require 'minitest/autorun'

class ParserTest < MiniTest::Unit::TestCase

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

    stat = CodeStat::Parser.new(output.call(:failures => 0, :errors => 0))
    assert_equal 0, stat.data[:failures]
    assert_equal 0, stat.data[:errors]

    stat = CodeStat::Parser.new(output.call(:failures => 1, :errors => 2))
    assert_equal 1, stat.data[:failures]
    assert_equal 2, stat.data[:errors]
    
    stat = CodeStat::Parser.new(output.call(:failures => 10, :errors => 2))
    assert_equal 10, stat.data[:failures]
  end

end
