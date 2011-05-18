class User < CodeStat::Model
  table "users"
  column :email, :string, :null => false
  column :name, :string
end
