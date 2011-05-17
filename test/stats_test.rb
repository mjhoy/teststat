$: << File.expand_path(File.dirname(__FILE__))
require 'test_helper'

class StatsTest < MiniTest::Unit::TestCase

  def setup
    @data = [
      { :errors => 0, :failures => 1, :exitstatus => 0 },
      { :errors => 1, :failures => 1, :exitstatus => 0 },
      { :errors => 0, :failures => 0, :exitstatus => 0 },
      { :errors => 0, :failures => 0, :exitstatus => 1 },
    ]

  end

  def test_total_runs
    s = CodeStat::Stats.new(@data)
    assert_equal 4, s.total_runs
  end

  def test_stat
    s = CodeStat::Stats.new(@data)
    error_stat = s.stat(:errors)

    assert_equal 1, error_stat[:sum]
    assert_equal 1.0/4, error_stat[:mean]
  end

  def test_successes
    s = CodeStat::Stats.new(@data)
    success_stat = s.stat(:success)

    assert_equal 1, success_stat[:sum]
    assert_equal 1.0/4, success_stat[:mean]
  end

  def test_print_stats
    s = CodeStat::Stats.new(@data)
    error_stat = s.stat(:errors)

    out = s.print_stats

    assert_match /out of 4 total runs/i, out
    assert_match /1 errors/i, out
    assert_match /2 failures/i, out
    assert_match /1 bad exits/i, out
    assert_match /1 successes/i, out
  end

  def test_other_exit_statuses
    data = [
      { :errors => 0, :failures => 1, :exitstatus => 1 },
      { :errors => 1, :failures => 1, :exitstatus => 3 },
    ]
    s = CodeStat::Stats.new(data)
    out = s.print_stats
    assert_match /2 bad exits/i, out
  end

end
