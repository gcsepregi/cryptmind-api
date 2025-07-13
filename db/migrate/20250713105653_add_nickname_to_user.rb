class AddNicknameToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :nickname, :string, null: false
  end
end
