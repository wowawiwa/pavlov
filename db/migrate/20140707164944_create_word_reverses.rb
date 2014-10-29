class CreateWordReverses < ActiveRecord::Migration
  def change
    create_table :word_reverses do |t|
      t.integer :word_id
    end
    add_index :word_reverses, :word_id
    remove_index :cards, name: :index_cards_on_evaluable_id_and_evaluable_type
    add_index :cards, [:evaluable_id, :evaluable_type], unique: true
    Word.all.each do |w|
      w.save
    end
  end
end
