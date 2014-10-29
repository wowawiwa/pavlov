class AddIndexes < ActiveRecord::Migration
  def change
    add_index :lists, :user_id # ?

    add_index :cards, :user_id
    add_index :cards, :list_id
    add_index :cards, [:evaluable_id, :evaluable_type]

    add_index :evaluations, :card_id
    add_index :evaluations, :created_at

    add_index :card_metas, :card_id
    add_index :card_metas, :last_evaluation_date
    add_index :card_metas, :next_evaluation_date
  end
end
