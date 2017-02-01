module HalfMoon
  class DB
    class << self
      def sqlite
        Sequel.sqlite(Config[:root] + Config[:db_path] + Config[:db_name])
      end
    end
  end
end
