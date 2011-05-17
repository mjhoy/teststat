class ATestModel
  class << self
    attr_accessor :schema_stmt_called
    def schema_stmt
      @schema_stmt_called = true
      "create table atestmodel (id integer primary key)"
    end
  end
end
