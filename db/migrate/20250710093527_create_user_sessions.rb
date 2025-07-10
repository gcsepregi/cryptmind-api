class CreateUserSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :user_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :user_agent
      t.string :ip_address
      t.datetime :last_seen_at
      t.string :jwt_jti

      t.timestamps
    end
  end
end
