class AddHelpToUsers < ActiveRecord::Migration
  def up
    add_column :users, :guide, :text
    User.reset_column_information
    User.all.each do |u|
      u.update_attribute( :guide, {})
    end
  end
  def down
    remove_column :users, :guide
  end
end
