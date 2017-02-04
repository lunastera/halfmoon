class UserMigration < HalfMoon::Migration
  def change
    @db.create_table users do
      primary_key id
      String name
      String pass
      
    end
  end
end
