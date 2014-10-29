class CreateCardMetas < ActiveRecord::Migration
  def up
    create_table :card_metas do |t|
      t.integer   :card_id
      t.datetime  :last_evaluation_date
      t.datetime  :next_evaluation_date
      t.integer   :current_successful_timespan
      t.integer   :ever_successful_timespan
      t.integer   :success_count_since_ever
      t.integer   :fail_count_since_ever
      
      t.timestamps
    end
    Card.all.each do |c|
      c.meta = CardMeta.new
      c.save
    end
  end
  def down
    drop_table :card_metas
  end
end
