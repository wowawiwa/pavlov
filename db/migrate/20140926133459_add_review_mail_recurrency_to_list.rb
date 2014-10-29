class AddReviewMailRecurrencyToList < ActiveRecord::Migration
  def change
    add_column :lists, :review_mail_recurrency, :integer
  end
end
