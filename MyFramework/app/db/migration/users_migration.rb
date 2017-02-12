# Model Migration test
class UserMigration < HalfMoon::Migration
  def change
    @db.create_table :users do
      primary_key :id
      String :name
      String :pass
    end
    # @db.drop_table :users
  end
end
