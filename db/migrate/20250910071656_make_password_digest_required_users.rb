class MakePasswordDigestRequiredUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :password_digest, false
    change_column_default :users, :password_digest, from: nil, to: nil
  end
end
