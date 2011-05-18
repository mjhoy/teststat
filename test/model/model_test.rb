$: << File.expand_path(File.dirname(__FILE__) + "/../../lib/")
require 'codestat/model'
require 'minitest/autorun'

TEST_MODELS = File.join(File.expand_path(File.dirname(__FILE__)), 'test_models')

class DBSetupTest < MiniTest::Unit::TestCase

  def setup
    @test_database = File.expand_path('./tmpdb.db')
  end

  def teardown
    File.delete(@test_database)
  end

  def test_db_initialize
    CodeStat::Model.connect({
      :database => @test_database,
      :skip_load_models => true
    })

    assert File.exist? @test_database
    assert_equal [], CodeStat::Model.model_classes
  end

end

class ModelTest < MiniTest::Unit::TestCase

  def setup
    @test_database = File.expand_path('./tmpdb.db')
    CodeStat::Model.connect({
      :database => @test_database,
      :skip_load_models => true
    })
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
    assert_equal [], CodeStat::Model.model_classes

    CodeStat::Model.connect({
      :database => @test_database,
      :models_directory => TEST_MODELS
    })

    assert ATestModel.schema_stmt_called
    assert_equal [ ATestModel ], CodeStat::Model.model_classes
  end

end

module DatabaseSetupAndTeardown
  def setup
    @test_database = File.expand_path('./tmpdb.db')
    CodeStat::Model.connect({
      :database => @test_database,
      :skip_load_models => true
    })
  end

  def teardown
    File.delete(@test_database)
  end
end

class ModelAttributesTest < MiniTest::Unit::TestCase
  include DatabaseSetupAndTeardown

  class SimpleModelTest < CodeStat::Model
    table "simplemodels"
    column :name, :string, :null => false
    column :number, :integer
    column :email, :string, :null => false, :unique => true
  end

  def test_table_name_dsl
    assert_equal "simplemodels", SimpleModelTest.table_name
  end

  def test_column_name_attribute_dsl
    m = SimpleModelTest.new
    assert_respond_to m, :name
    assert_respond_to m, :name=
    m.name = "foo"
    assert_equal "foo", m.name
  end

  def test_columns_to_sql_list
    actual = SimpleModelTest.columns_to_sql_list
    assert_equal [:id, :integer, {:primary_key => true}], SimpleModelTest.columns[-1]
    assert_equal [:name, :string, {:null => false}], SimpleModelTest.columns[0]
    assert_equal [:email, :string, {:null => false, :unique => true}], SimpleModelTest.columns[2]
    assert_match /name string not null,number integer,email string unique not null/, actual
  end

  def test_sets_schema_stmt_accordingly
    CodeStat::Model.initialize_model(SimpleModelTest)
    res = nil
    SQLite3::Database.new @test_database do |db|
      res = db.execute "select name, number from simplemodels"
    end
    assert_equal [], res
  end

  def test_doesnt_double_set_stmt_on_more_loads
    CodeStat::Model.initialize_model(SimpleModelTest)
    assert_equal 4, SimpleModelTest.columns.length
    CodeStat::Model.initialize_model(SimpleModelTest)
    assert_equal 4, SimpleModelTest.columns.length
  end

  def test_adds_primary_key
    CodeStat::Model.initialize_model(SimpleModelTest)
    res = nil
    SQLite3::Database.new @test_database do |db|
      res = db.execute "select id from simplemodels"
    end
    assert_equal [], res
  end

end

class TestUser < CodeStat::Model
  table "testusers"
  column :name, :string, :null => false
  column :number, :integer, :null => false
end

class ModelFinderTest < MiniTest::Unit::TestCase
  include DatabaseSetupAndTeardown

  def test_find_id
    CodeStat::Model.initialize_model(TestUser)

    id = nil
    CodeStat::Model.q do |db|
      db.execute('insert into testusers ( name, number ) values ( "foo", 1 )')
      id = db.last_insert_row_id
    end

    user = TestUser.find(id)
    assert_equal "foo", user.name
    assert_equal 1, user.number
  end
end

class ModelSaveTest < MiniTest::Unit::TestCase
  include DatabaseSetupAndTeardown

  def test_new_and_save
    CodeStat::Model.initialize_model(TestUser)

    user = TestUser.new({
      :name => "michael hoy",
      :number => 2
    })

    assert_equal "michael hoy", user.name
    assert_nil user.id

    assert_equal true, user.save
    refute_nil user.id

    assert_equal TestUser.find(user.id).name, user.name
  end

  def test_new_not_valid
    CodeStat::Model.initialize_model(TestUser)

    user = TestUser.new({
      :number => 2
    })
    assert_equal nil, user.name

    assert_raises SQLite3::ConstraintException do
      user.save
    end
  end

  def test_update
    CodeStat::Model.initialize_model(TestUser)

    user = TestUser.new({
      :name => "michael hoy",
      :number => 2
    })
    user.save

    new_u = TestUser.find(user.id)
    new_u.name = "foobar"
    new_u.save

    assert_equal "foobar", TestUser.find(user.id).name
  end

  def test_find_by_attribute
    CodeStat::Model.initialize_model(TestUser)

    user = TestUser.new({
      :name => "michael hoy",
      :number => 2
    })
    user.save

    assert_equal user.id, TestUser.find_by_attribute(:name, "michael hoy").id
  end
end
