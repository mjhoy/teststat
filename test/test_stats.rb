$: << File.expand_path(File.dirname(__FILE__))
require 'test_helper'

class StatsTest < MiniTest::Unit::TestCase

  def setup
    @data = [
      { :errors => 0, :failures => 1 },
      { :errors => 1, :failures => 1 },
      { :errors => 0, :failures => 0 }
    ]

  end

  def test_total_runs

    s = CodeStat::Stats.new(@data)
    assert_equal 3, s.total_runs

  end

  def test_stat
    s = CodeStat::Stats.new(@data)
    error_stat = s.stat(:errors)

    assert_equal 1, error_stat[:sum]
    assert_equal 1.0/3, error_stat[:mean]
  end

  def test_successes
    s = CodeStat::Stats.new(@data)
    success_stat = s.stat(:success)

    assert_equal 1, success_stat[:sum]
    assert_equal 1.0/3, success_stat[:mean]
  end

  def test_print_stats
    s = CodeStat::Stats.new(@data)
    error_stat = s.stat(:errors)

    out = s.print_stats

    assert_match /out of 3 total runs/i, out
    assert_match /1 errors/i, out
    assert_match /2 failures/i, out
    assert_match /1 successes/i, out

  end

end
