class AddDetailsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :name, :string
    add_column :users, :level, :string
    add_column :users, :github_link, :string
  end
end
