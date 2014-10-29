module ApplicationHelper

  # Returns the fully qualified title on a page title basis
  def full_title(page_title)
    base_title = I18n.t('application.name')
    page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  end

  # Defines the page title and h1 with args.
  # args is either: [ "title string", :no_i18n] or: [ I18n_argument_list ] in which case the title is given by the result of I18n.t()
  #def provide_title *args
  #  params = args
  #  is_i18n = !params.include?(:no_i18n)
  #  params = params - [:no_i18n]
  #  title = is_i18n ? I18n.t(*params) : params.first

  #  provide :title, title # title defined in the layout
  #  haml_tag :h1, title
  #end

  def provide_title title, subtitle=nil
    browser_title = subtitle.try{|s| "#{s} #{title}"} || title
    provide :title, browser_title
    haml_tag :h1 do
      haml_concat title
      if subtitle
        haml_tag :br
        haml_tag(:i){ haml_concat subtitle }
      end
    end
  end

  # Keyboard shortcuts

  # Returns Mousetrap keybinding
  def access_key action_label
    kb_binding[action_label][:keybinding]
  end

  # Maps the actions (identified with their label) to all their possible expressions (facets)
  # Display in Shortcut page if context != nil using the I18n corresponding to the action labels.
  KB_BINDING = {
    eval_success:   { context: :review,         keybinding: "up",     display: "↑" }, # HTML & JS 
    eval_fail:      { context: :review,         keybinding: "down",   display: "↓" }, # HTML & JS
    correction:     { context: :review,         keybinding: "left",   display: "←" }, # HTML & JS
    tip_show:       { context: :review,         keybinding: "right",  display: "→" }, # only JS
    tip_toggle:     { context: :review,         keybinding: "space"                }, # only JS
    home:           { context: :general,        keybinding: "h"                    },
    new_card:       { context: :general,        keybinding: "c"                    },                       
    new_list:       { context: :general,        keybinding: "l"                    },                       
    review:         { context: nil,             keybinding: "r"                    },
    go_back:        { context: nil,             keybinding: "b"                    },
    kbs:            { context: nil,             keybinding: "?"                    }
  }
  def kb_binding
    KB_BINDING
  end

  # Time converter
  
  # choses the right scale 
  # limits = [ hours_limit, minutes_limit, seconds_limit]
  def scale_computer( seconds, limits=[36, nil, nil])
    decomposition = TimeTools.timespan_decomposition_selector( seconds, limits)
    return { label: decomposition[:label], value: decomposition[:value].first + 1}
  end
end
