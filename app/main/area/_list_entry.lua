local area = param.get("area", "table")

ui.container{ attr = { class = "area" }, content = function()

  execute.view{ module = "area", view = "_head", params = { area = area, hide_unit = true, show_content = true } }
  
  ui.container{ attr = { class = "content" }, content = function()
    ui.tag{ content = _"Issues:" }
    slot.put(" ")
    ui.link{ 
      module = "area", view = "show", id = area.id, params = { tab = "open", filter = "new" },
      text = _("#{count} new", { count = area.issues_new_count }) 
    }
    slot.put(" &middot; ")
    ui.link{ 
      module = "area", view = "show", id = area.id, params = { tab = "open", filter = "discussion" },
      text = _("#{count} in discussion", { count = area.issues_discussion_count }) 
    }
    slot.put(" &middot; ")
    ui.link{ 
      module = "area", view = "show", id = area.id, params = { tab = "open", filter = "verification" },
      text = _("#{count} in verification", { count = area.issues_frozen_count }) 
    }
    slot.put(" &middot; ")
    ui.link{ 
      module = "area", view = "show", id = area.id, params = { tab = "open", filter = "voting" },
      text = _("#{count} in voting", { count = area.issues_voting_count }) 
    }
    slot.put(" &middot; ")
    ui.link{ 
      module = "area", view = "show", id = area.id, params = { tab = "closed", filter = "finished" },
      text = _("#{count} finished", { count = area.issues_finished_count }) 
    }
    slot.put(" &middot; ")
    ui.link{ 
      module = "area", view = "show", id = area.id, params = { tab = "closed", filter = "cancelled" },
      text = _("#{count} cancelled", { count = area.issues_cancelled_count }) 
    }
  end }

end }
