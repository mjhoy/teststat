class User < CodeStat::Model
  table "users"
  column :email, :string, :null => false, :unique => true
  column :name, :string
end
