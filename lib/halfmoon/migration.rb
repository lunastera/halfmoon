module HalfMoon
  # model migration
  class Migration
    def initialize
      @db = Database.connect
    end

    def create
      # rake
      # db:create table_name
    end

    def drop
      # rake
      # db:change table_name
    end
  end
end
