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
    class << self

      attr_accessor :model_classes

      def connect(opts)
        @model_classes = []
        @@database = opts[:database]
        setup_database unless File.exist? opts[:database]
        load_model_classes
      end

      private

      def load_model_classes
        Dir[File.expand_path(File.dirname(__FILE__)) + '/models/*'].each do |f|
          load f
          class_name = File.basename(f).chomp('.rb').classify
          @model_classes << class_eval(class_name)
        end
      end

      def setup_database
        db = SQLite3::Database.new @@database
      end
    end
  end
end
