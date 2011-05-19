$: << File.expand_path(File.dirname(__FILE__) + "/../../lib/")
require 'codestat/model'
require 'minitest/autorun'

module TestRunDatabaseSetupAndTeardown
  def setup
    @test_database = File.expand_path('./tmpdb.db')
    CodeStat::Model.connect({:database => @test_database})
  end

  def teardown
    File.delete(@test_database)
  end
end

class TestRunTest < MiniTest::Unit::TestCase
  include TestRunDatabaseSetupAndTeardown

  def test_requires_error_failure_exitstatus
    assert_raises SQLite3::ConstraintException do
      TestRun.new({
        :failures => 1,
        :errors => 1,
        :milliseconds_run => 100
      }).save
    end
    assert_raises SQLite3::ConstraintException do
      TestRun.new({
        :errors => 1,
        :exitstatus => 0,
        :milliseconds_run => 100
      }).save
    end
    assert_raises SQLite3::ConstraintException do
      TestRun.new({
        :failures => 1,
        :exitstatus => 0,
        :milliseconds_run => 100
      }).save
    end
    assert_raises SQLite3::ConstraintException do
      TestRun.new({
        :failures => 1,
        :errors => 1,
        :exitstatus => 0
      }).save
    end
  end
end
