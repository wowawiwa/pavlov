class AddReverseToLists < ActiveRecord::Migration
  def change
    add_column :lists, :reverse, :boolean#, default: false
    List.reset_column_information
    List.update_all( reverse: false)
  end
end
