class AddMailConfirmationAndPasswordForgottenFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_confirmation_token, :string
    add_column :users, :email_confirmation_last_sent_date, :datetime
    add_column :users, :email_confirmed, :boolean, default: false
    add_column :users, :password_reset_token, :string
    add_column :users, :password_reset_last_sent_at, :datetime
  end
end
