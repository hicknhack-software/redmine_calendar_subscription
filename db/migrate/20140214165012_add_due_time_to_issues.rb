class AddDueTimeToIssues < ActiveRecord::Migration
  def change
    change_column :issues, :due_date, :datetime
  end
end
