class AddCurrentSuccessCountToCardMeta < ActiveRecord::Migration
  def up
    add_column :card_metas, :current_success_count, :integer

    CardMeta.reset_column_information
    CardMeta.all.each do |c|
      next if c.evaluations.count == 0

      last_f_eval = c.evaluations.where( result: false).order(:created_at).last
      created_limit = last_f_eval ? last_f_eval.created_at : c.created_at

      s_count = c.evaluations.where( "evaluations.created_at > ?", created_limit).count
      c.update_attribute( :current_success_count, s_count)
      puts "#{s_count} for card_meta#id #{c.id}"
    end
  end

  def down
    remove_column :card_metas, :current_success_count
  end
end
