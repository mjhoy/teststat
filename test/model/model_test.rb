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

  class MockModel
    def self.schema_stmt
      "create table t1 (id integer primary key)"
    end
    def self.table_name
      "t1"
    end
  end

  def test_initialize_model_schema_statement
    CodeStat::Model.initialize_model(MockModel)
    res = nil
    SQLite3::Database.new(@test_database) do |db|
      res = db.execute("select * from t1")
    end
    assert_equal [], res
  end

  def test_dont_execute_schema_statement_if_table_exists
    SQLite3::Database.new(@test_database) do |db|
      res = db.execute("create table t1 (id integer primary key)")
    end

    CodeStat::Model.initialize_model(MockModel)

    res = nil
    SQLite3::Database.new(@test_database) do |db|
      res = db.execute("select * from t1")
    end
    assert_equal [], res
  end

end

class ModelAutoLoadTest < MiniTest::Unit::TestCase
  def setup
    @test_database = File.expand_path('./tmpdb.db')
    @m_src = File.join(File.expand_path(File.dirname(__FILE__)), 'a_test_model.rb')
  end

  def teardown
    File.delete(@test_database)
  end

  def test_load_model_file
    CodeStat::Model.connect({
      :database => @test_database,
      :models_directory => File.join(File.expand_path(File.dirname(__FILE__)), 'test_models')
    })
    assert ATestModel.schema_stmt_called
    assert_equal [ ATestModel ], CodeStat::Model.model_classes
  end

end

module DatabaseSetupAndTeardown
  def setup
    @test_database = File.expand_path('./tmpdb.db')
    CodeStat::Model.connect({
      :database => @test_database
    })
  end

  def teardown
    File.delete(@test_database)
  end
end

class ModelAttributesTest < MiniTest::Unit::TestCase
  include DatabaseSetupAndTeardown

  def test_lives
    assert CodeStat::Model.db
  end

end
