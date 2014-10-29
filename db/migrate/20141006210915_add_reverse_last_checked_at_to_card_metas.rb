class AddReverseLastCheckedAtToCardMetas < ActiveRecord::Migration
  def change
    add_column :card_metas, :reverse_last_evaluation_date, :datetime
  end
end
