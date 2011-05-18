$: << File.expand_path(File.dirname(__FILE__) + "/../../lib/")
require 'codestat/model'
require 'minitest/autorun'

module JobDatabaseSetupAndTeardown
  def setup
    @test_database = File.expand_path('./tmpdb.db')
    CodeStat::Model.connect({:database => @test_database})
  end

  def teardown
    File.delete(@test_database)
  end
end

class JobTest < MiniTest::Unit::TestCase
  include JobDatabaseSetupAndTeardown

  def test_job_id_is_not_nil
    assert_raises SQLite3::ConstraintException do
      Job.new({:name => "foo"}).save
    end
  end

  def test_job_id_is_unique
    Job.new({:job_id => "foo"}).save
    assert_raises SQLite3::ConstraintException do
      Job.new({:job_id => "foo"}).save
    end
  end
end
