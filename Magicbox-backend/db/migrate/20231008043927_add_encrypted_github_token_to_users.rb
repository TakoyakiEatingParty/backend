class AddEncryptedGithubTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :encrypted_github_token, :string
    add_column :users, :encrypted_github_token_iv, :string
  end
end
