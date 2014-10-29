class ChangeCardMetaLastEvalConvention < ActiveRecord::Migration
  def up
    CardMeta.never_evaluated.update_all( last_evaluation_date: nil)
  end
  def down
    CardMeta.never_evaluated.each do |c|
      c.update_attribute( :last_evaluation_date, c.created_at)
    end
  end
end
