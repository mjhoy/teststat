$: << File.expand_path(File.dirname(__FILE__) + "/../lib/")
require 'codestat'
require 'minitest/autorun'

class TestDB < MiniTest::Unit::TestCase
  def setup
    @tmpfile = "/tmp/test.db"
  end

  def teardown
    File.delete(@tmpfile)
  end

  def test_writes_to_file_if_doesnt_exist

    refute File.exists?(@tmpfile)
    db = CodeStat::DB.new(@tmpfile)
    db.push({:foo => 'bar'})
    assert File.exists?(@tmpfile)

  end

  def test_pushes_items_as_arrays_and_retrieves
    db = CodeStat::DB.new(@tmpfile)
    db.push(:foo)

    db = CodeStat::DB.new(@tmpfile)
    db.push(:bar)

    db = CodeStat::DB.new(@tmpfile)
    data = db.data

    assert_equal [ :bar, :foo ], db.data
  end

  def test_raises_warning_if_file_cant_load
    File.open(@tmpfile, "w") do |f|
      f << "foo"
    end

    assert_raises CantReadDBError do
      db = CodeStat::DB.new(@tmpfile)
      db.push(:foo)
    end
  end

end
