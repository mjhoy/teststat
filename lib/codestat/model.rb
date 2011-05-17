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
        db = setup_database(opts[:database])
        load_model_classes
      end

      def initialize_model(klass)
        schema_stmt = klass.schema_stmt
        db.execute(schema_stmt)
      end

      private

      def load_model_classes
        Dir[File.expand_path(File.dirname(__FILE__)) + '/models/*'].each do |model|
          load model
          class_name = File.basename(model).chomp('.rb').classify
          @model_classes << class_eval(class_name)
        end
      end

      def setup_database(database)
        SQLite3::Database.new database
      end
    end
  end
end
