class Job < CodeStat::Model
  table "jobs"
  column :name, :string
  column :job_id, :string, 
    :null => false, 
    :unique => true
end
