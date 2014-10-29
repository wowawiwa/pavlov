class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.integer :user_id
      t.integer :list_id
      t.text    :content
      t.text    :tip

      t.timestamps
    end
  end
end
