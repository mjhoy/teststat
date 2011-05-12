class CantReadDBError < Exception; end

module CodeStat

  class DB

    def initialize(database)
      @path = database
    end

    def push(item)
      prev = data
      File.open(@path, "w+") do |f|
        Marshal.dump([item].concat(prev), f)
      end
    end

    def data
      if File.exists? @path
        begin
          File.open(@path, "r") do |f|
            Marshal.load f
          end
        rescue TypeError
          raise CantReadDBError, "Can't load the stats database file."
        end
      else
        []
      end
    end

  end
end

