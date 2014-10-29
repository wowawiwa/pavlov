class AddPreviousToCardMetas < ActiveRecord::Migration
  def change
    add_column :card_metas, :previous, :text
  end
end
