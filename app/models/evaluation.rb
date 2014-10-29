class Evaluation < ActiveRecord::Base
  validates_inclusion_of :result, :in => [true, false]

  belongs_to :card
  validates_presence_of :card
  validates_associated :card

  has_one :card_meta, through: :card, source: :meta

  scope :created_between, lambda {|start_date, end_date| where("#{table_name}.created_at >= ? AND #{table_name}.created_at <= ?", start_date, end_date )}

  # TODO put in Chronos::Evaluation
  after_save :report_result_to_programs

  private

  def report_result_to_programs
    just_created = created_at_changed? 
    # TODO
    # created_or_updated = created_at_changed? ? :created : :updated
    Program::Chronos::EvaluationHook.report_result( self.card, self.result, !just_created)
  end
end
