module HalfMoon
  # model migration
  class Migration
    def initialize
      @db = DB.sqlite
    end

    def create
      # rake
      # db:create table_name
    end

    def change
      # rake
      # db:change table_name
    end
  end
end
