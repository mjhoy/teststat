require 'sqlite3'

class String
  # Naive implementaion of ActiveSupport's classify.
  # 'a_test_class' => 'ATestClass'
  def classify
    gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end
end

class Object
  def metaclass
    class << self; self; end
  end
end

module FinderMethods

  def find_by_attribute(col, val)
    rec = nil
    if String === val
      val = '"' + SQLite3::Database.quote(val) + '"'
    end
    CodeStat::Model.q do |db|
      rows = db.execute("select * from #{table_name} where #{col}=#{val}")
      rec = self.new
      rows[0].each_key do |k|
        if String === k
          rec.send("#{k}=", rows[0][k])
        end
      end
    end
    rec
  end

  def find(id)
    find_by_attribute(:id, id)
  end

end

module AttributeMethods
  
  # Define the table name associated with the model.
  # ex:
  #
  # class SimpleModels < CodeStat::Model
  #   table "simplemodels"
  # end
  def table(name)
    metaclass.instance_eval do
      define_method :table_name do
        name
      end
    end
  end

  # Define the column names associated with the model attributes.
  # ex:
  #
  # class SimpleModels < CodeStat::Model
  #   table "simplemodels"
  #
  #   column :name, :string, :null => false
  #   column :number, :integer, :null => false
  # end
  def column(name, *args)
    define_method name do
      instance_variable_get("@_#{name}")
    end
    define_method "#{name}=" do |val|
      instance_variable_set("@_#{name}", val)
    end
    self.columns = columns.concat([[name].concat(args)])
  end

  def has_primary_key?
    columns.any? do |c|
      c[2] and c[2][:primary_key]
    end
  end

  def constraints_to_sql(opts)
    return nil unless Hash === opts
    opts = opts.dup
    if opts[:null] == false
      opts[:not_null] = true
    end
    consts = []
    opts.each_key do |k|
      if opts[k]
        str = case k
               when :primary_key
                 "primary key"
               when :not_null
                 "not null"
               when :unique
                 "unique"
               else
                 raise RuntimeError, "unknown constraint #{k}"
               end
        consts.push str
      end
    end
    consts.join(" ")
  end

  def columns_to_sql_list
    unless has_primary_key?
      self.column :id, :integer, :primary_key => true
    end
    sql = columns.map do |c|
      opts = c[2]
      str = c[0].to_s + " " + c[1].to_s
      constraints = constraints_to_sql(opts)
      str = str + " " + constraints if constraints
      str
    end.join(",")
    sql
  end

  def schema_stmt
    "create table #{table_name} (" + columns_to_sql_list + ")"
  end
end

module CodeStat
  class Model

    extend AttributeMethods
    extend FinderMethods

    def initialize(attrs = {})
      attrs.each_key do |k|
        self.send("#{k}=", attrs[k])
      end
    end

    def save
      cols = []; vals = []
      self.class.columns.each do |c|
        if val = self.send("#{c[0]}")
          cols.push c[0]
          val = "'" + val + "'" if String === val
          vals.push val
        end
      end
      colstr = cols.join(",")
      valstr = vals.join(",")
      res = false
      CodeStat::Model.q do |db|
        if !self.id
          sql ="insert into #{self.class.table_name} (#{colstr}) values (#{valstr});" 
        else
          sets = "set " + cols.map.with_index {|c, i| "#{c}=#{vals[i]}"}.join(",")
          sql = "update #{self.class.table_name} #{sets} where id=#{self.id}"
        end
        db.execute(sql)
        n = db.last_insert_row_id
        if db.changes > 0
          self.id = n
          res = true
        end
      end
      res
    end

    def self.inherited(subclass)
      subclass.metaclass.class_eval do
        attr_accessor :columns
      end
      subclass.columns = []
    end

    class << self
      attr_accessor :model_classes
      attr_accessor :db
      attr_accessor :models_directory

      def connect(opts)
        @model_classes ||= []
        self.db = opts[:database]
        unless opts[:skip_load_models]
          self.models_directory = opts[:models_directory] ||
            File.expand_path(File.dirname(__FILE__)) + '/models'
        end
        setup_database
        load_model_classes if self.models_directory
      end

      def initialize_model(klass)
        schema_stmt = klass.schema_stmt
        raise ArgumentError unless String === schema_stmt
        unless table_exist? klass.table_name
          q do |db|
            db.execute(schema_stmt)
          end
        end
      end

      def table_exist?(table_name)
        res = []
        q do |db|
          res = db.execute("SELECT name FROM sqlite_master " +
                           "WHERE type='table' AND name='#{table_name}'")
        end
        !res.empty?
      end

      def q(&block)
        SQLite3::Database.new(self.db, :results_as_hash => true, &block)
      end

      def load_model_classes
        @_loaded_modules ||= []
        Dir[models_directory + '/*'].each do |model|
          unless @_loaded_modules.include? model
            load model
            @_loaded_modules.push model
            class_name = File.basename(model).chomp('.rb').classify
            klass = class_eval(class_name)
            @model_classes.push klass
          end
        end
        @model_classes.each do |klass|
          initialize_model(klass)
        end
      end

      def setup_database
        tmp = SQLite3::Database.new( self.db )
        tmp.close
      end
    end
  end
end

