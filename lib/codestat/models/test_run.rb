class TestRun < CodeStat::Model
  table "testruns"
  column :failures, :integer, :null => false
  column :errors, :integer, :null => false
  column :exitstatus, :integer, :null => false
  column :milliseconds_run, :integer, :null => false
  column :timestamp, :integer, :null => false

  # Associations
  column :job_id, :string
  column :email, :string
end
