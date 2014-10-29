# WARN: nil values when ordering dates - nil is considered the most recent. (thus, first when asked for DESC, last when asked for ASC)
# TODO delete stat method and @ and transform into module again
class Program::Chronos

  def initialize
  end
  
  # Interface of the card selection pipeline.
  # Returns the card to be reviewed or nil if no card should be reviewed.
  def select( cards, now, remaining_capacity, one_or_all_at_once=:one)
    @remaining_capacity = remaining_capacity.inspect
    return nil if cards.empty?

    selectable = CardMeta.where( card_id: cards.pluck(:id)).next_eval_before(now)
    #@selectable = selectable.order("next_evaluation_date DESC")
    selected_meta = remaining_capacity ? card_elector_with_capacity( selectable, now, remaining_capacity, one_or_all_at_once) : card_elector( selectable, now)
    return nil unless selected_meta

    if remaining_capacity and one_or_all_at_once == :all_at_once
      Card.where( id: selected_meta.pluck(:card_id))
    else
      selected_meta.card
    end
  end

  def stats
    Hash[ instance_variables.map { |name| [name, instance_variable_get(name)] } ]
  end

  private

  def card_elector( selectable, now)
    @method = :card_elector
    # favor evaluated already but not too closely
    selected_card = selectable
      .once_evaluated
      .exclude_x_most_recently_evaluated( 7)#.exclude_x_most_recently_reverse_evaluated( 7)
      .order( "last_evaluation_date ASC")[0] # TODO seems that .first unscopes

    # favor most recently created
    selected_card ||= selectable
      .never_evaluated
      .order( "created_at ASC")[-1]

    # closely evaluated, for longest time first
    selected_card ||= selectable
      .order( "last_evaluation_date ASC")[0]
  end

  def card_elector_with_capacity( selectable, now, remaining_capacity, one_or_all_at_once=:one)
    @method = :card_elector_with_capacity
    return nil if remaining_capacity <= 0

    # Take the remaining_capacity-th ordered by last evaluation date, most recent first.
    # This way, priority is given to cards that have been reviewed at least once,
    # but a rotation of the cards is ensured when making successive evaluations.
    selected = selectable
      .order( "last_evaluation_date IS NULL, last_evaluation_date DESC") # most recent first, nil at the end
      .exclude_x_most_recently_reverse_evaluated( now - 5.minutes)
      .limit( remaining_capacity) # selection

    if selected.empty?
      selected = selectable
        .order( "last_evaluation_date IS NULL, last_evaluation_date DESC") # most recent first, nil at the end
        .limit( remaining_capacity) # selection
    end
    (one_or_all_at_once == :all_at_once) ? selected : selected.last
  end

  def random_card_elector( selectable)
    selectable[ rand( selectable.count)]
  end
end
