class AddAlgo2FieldsToCardMetas < ActiveRecord::Migration

  def find_max_in_eval_scope( eval_scope, created_at_init)
    max = 0
    id = nil
    created_at = created_at_init
    eval_scope.order(:created_at).each do |e|
      if e.result == true
        if e.created_at - created_at > max
          max = e.created_at - created_at
          id = e.id
          created_at = e.created_at
        end
      end
    end
    return id, max, created_at
  end

  def up
    add_column :card_metas, :success_count_since_record, :integer
    add_column :card_metas, :fail_count_since_record, :integer
    add_column :card_metas, :record_timespan, :integer
    add_column :card_metas, :current_timespan, :integer

    # Compute values of the fields ... TODO move in the app ?
    CardMeta.reset_column_information
    CardMeta.all.each do |c|
      next if c.evaluations.count == 0
      max_eval_id, max_value, max_created_at = find_max_in_eval_scope(c.evaluations, c.created_at)
      
      if max_eval_id
        after_evals = c.evaluations.where( "evaluations.created_at > ?", max_created_at)
        success_count = after_evals.where( result: true).count
        fail_count = after_evals.where( result: false).count
        current_timespan = if after_evals.present?
                             cur_eval_id, cur_val, cur_created_at = find_max_in_eval_scope( after_evals, max_created_at)
                             cur_eval_id ? cur_val : 0
                           else
                             max_value
                           end
        attrs = {
          :success_count_since_record => success_count,
          :fail_count_since_record => fail_count,
          :record_timespan => max_value,
          :current_timespan => current_timespan
        }
        puts attrs.inspect
        c.update_attributes(
          attrs
        )
      end
    end
  end
  def down
    remove_column :card_metas, :success_count_since_record
    remove_column :card_metas, :fail_count_since_record
    remove_column :card_metas, :record_timespan
    remove_column :card_metas, :current_timespan
  end
end
