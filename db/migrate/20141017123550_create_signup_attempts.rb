class CreateSignupAttempts < ActiveRecord::Migration
  def change
    create_table :signup_attempts do |t|
      t.string :name
      t.string :email
      t.string :invite_code
      t.timestamps
    end
  end
end
