$: << File.expand_path(File.dirname(__FILE__) + "/../../lib/")
require 'codestat/model'
require 'minitest/autorun'
require 'fileutils'

module UserDatabaseSetupAndTeardown
  def setup
    @test_database = File.expand_path('./tmpdb.db')
    # Use the default model path
    CodeStat::Model.connect({
      :database => @test_database,
    })
  end

  def teardown
    File.delete(@test_database)
  end
end

class ModelAttributesTest < MiniTest::Unit::TestCase
  include UserDatabaseSetupAndTeardown

  def test_user_is_loaded
    assert User
  end

  def test_email_is_not_null
    assert_raises SQLite3::ConstraintException do
      User.new({:name => "foo"}).save
    end
  end

  def test_email_is_unique
    attrs = {
      :name => "michael hoy",
      :email => "michael.john.hoy@gmail.com"
    }
    user = User.new(attrs)
    user.save

    assert_raises SQLite3::ConstraintException do
      duplicate = User.new(attrs)
      duplicate.save
    end
  end

end
