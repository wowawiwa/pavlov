class MainController < ApplicationController

  def home
    if signed_in?
      now = Time.zone.now
      @lists_global_report = List.build_id_hash(current_user.lists){|l| l.scope_report}
      @lists_charge_report = List.build_id_hash(current_user.lists){|l| l.chronos_report_flow(now)}
      @lists_coming_spans_report = List.build_id_hash(current_user.lists){|l| l.chronos_report_scheduled(now)}
    else
      redirect_to new_user_path
    end
  end
end
