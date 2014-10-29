class MakeCardsPolymorphic < ActiveRecord::Migration
  def change
    change_table :cards do |t|
      t.references :evaluable, polymorphic: true
    end
  end
end
