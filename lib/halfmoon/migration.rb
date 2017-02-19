module HalfMoon
  # model migration
  class Migration
    def initialize
      @db = Database.connect
    end
  end
end
