class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.integer :card_id
      t.boolean :result
      t.timestamps
    end
  end
end
