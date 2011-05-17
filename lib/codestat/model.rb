require 'sqlite3'

class String
  # Naive implementaion of ActiveSupport's classify.
  # 'a_test_class' => 'ATestClass'
  def classify
    gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end
end

module CodeStat
  class Model

    def schema_stmt; raise 'Must override.' end

    class << self
      attr_accessor :model_classes
      attr_accessor :db

      def connect(opts)
        @model_classes = []
        self.db = opts[:database]
        setup_database
        load_model_classes
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
        SQLite3::Database.new(self.db, &block)
      end

      def load_model_classes
        Dir[File.expand_path(File.dirname(__FILE__)) + '/models/*'].each do |model|
          load model
          class_name = File.basename(model).chomp('.rb').classify
          @model_classes << class_eval(class_name)
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
