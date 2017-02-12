module HalfMoon
  class Database
    class << self
      def sqlite
        Sequel.sqlite("#{Config[:root]}#{Config[:db_path]}#{Config[:db_name]}.db")
      end

      def mysql
        Sequel.mysql(
          Config[:db_name],
          host:     Config[:db_host],
          user:     Config[:db_user],
          password: Config[:db_pass],
          port:     Config[:db_port]
        )
      end

      def connect
        case Config[:db_type]
        when 'sqlite'
          sqlite
        when 'mysql'
          mysql
        end
      end
    end
  end
end
