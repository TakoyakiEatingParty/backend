class CreateJwtTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :jwt_tokens do |t|
      t.string :jti, null: false
      t.datetime :exp, null: false

      t.timestamps
    end
    add_index :jwt_tokens, :jti, unique: true
  end
end
