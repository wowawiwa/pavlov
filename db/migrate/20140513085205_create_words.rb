class CreateWords < ActiveRecord::Migration
  def up
    create_table :words do |t|
      t.text  :content
      t.text  :tip

      t.timestamps
    end
    Card.all.each do |c|
      c.evaluable = Word.new(
        content:  c.content,
        tip:      c.tip
      )
      c.save
    end
    remove_column :cards, :content
    remove_column :cards, :tip
  end
  def down
    drop_table :words
  end
end
