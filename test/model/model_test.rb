$: << File.expand_path(File.dirname(__FILE__) + "/../../lib/")
require 'codestat/model'
require 'minitest/autorun'
require 'fileutils'

class DBSetupTest < MiniTest::Unit::TestCase

  def setup
    @test_database = File.expand_path('./tmpdb.db')
  end

  def teardown
    File.delete(@test_database)
  end

  def test_db_initialize
    CodeStat::Model.connect({
      :database => @test_database
    })

    assert File.exist? @test_database
  end

end

class ModelTest < MiniTest::Unit::TestCase

  def setup
    @test_database = File.expand_path('./tmpdb.db')
    CodeStat::Model.connect({:database => @test_database})
  end

  def teardown
    File.delete(@test_database)
  end

  def mock_db(db)
    CodeStat::Model.db = db
  end

  def test_schema_method
    m = CodeStat::Model.new
    assert_raises RuntimeError do
      m.schema_stmt
    end
  end

  def test_initialize_model
    m = MiniTest::Mock.new
    m.expect(:schema_stmt, "create table t1", [])

    db = MiniTest::Mock.new
    db.expect(:execute, nil, ["create table t1"])

    mock_db(db)
    CodeStat::Model.initialize_model(m)
  end

end

class ModelAutoLoadTest < MiniTest::Unit::TestCase
  def setup
    @test_database = File.expand_path('./tmpdb.db')
    @m_src = File.join(File.expand_path(File.dirname(__FILE__)), 'a_test_model.rb')
    @m_dst = File.expand_path(File.join(File.dirname(__FILE__) + "/../../lib/codestat/models/a_test_model.rb"))
    FileUtils.cp(@m_src, @m_dst)
  end

  def teardown
    File.delete(@m_dst)
    File.delete(@test_database)
  end

  def test_delete
    CodeStat::Model.connect({
      :database => @test_database
    })
    assert File.exist?(@m_dst)
    assert ATestModel
    assert_equal [ ATestModel ], CodeStat::Model.model_classes
  end

end
