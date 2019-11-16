class AddStateToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :state, :integer, default: 1
  end
end
