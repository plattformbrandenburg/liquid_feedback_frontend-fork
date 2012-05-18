local area = param.get("area", "table")

execute.view{ module = "unit", view = "_head", params = { unit = area.unit } }

ui.container{ attr = { class = "area_head" }, content = function()

  execute.view{ module = "delegation", view = "_info", params = { area = area } }

  ui.container{ attr = { class = "title" }, content = function()
    -- area name
    ui.link{
      module = "area", view = "show", id = area.id,
      attr = { class = "area_name" }, content = area.name 
    }
  end }
  
  ui.container{ attr = { class = "content" }, content = function()

    -- actions (members with appropriate voting right only)
    if app.session.member_id then

      -- membership
      local membership = Membership:by_pk(area.id, app.session.member.id)

      if membership then
        
        ui.tag{ content = _"You are participating in this area" }
        
        slot.put(" ")
        
        ui.tag{ content = function()
          slot.put("(")
          ui.link{
            text    = _"Withdraw",
            module  = "membership",
            action  = "update",
            params  = { area_id = area.id, delete = true },
            routing = {
              default = {
                mode = "redirect",
                module = request.get_module(),
                view = request.get_view(),
                id = param.get_id_cgi(),
                params = param.get_all_cgi()
              }
            }
          }
          slot.put(")")
        end }
        
        slot.put(" &middot; ")

      elseif app.session.member:has_voting_right_for_unit_id(area.unit_id) then
        ui.link{
          text   = _"Participate in this area",
          module = "membership",
          action = "update",
          params = { area_id = area.id },
          routing = {
            default = {
              mode = "redirect",
              module = request.get_module(),
              view = request.get_view(),
              id = param.get_id_cgi(),
              params = param.get_all_cgi()
            }
          }
        }

        slot.put(" &middot; ")

      end

      -- create new issue
      if app.session.member:has_voting_right_for_unit_id(area.unit_id) then
        ui.link{
          content = function()
            slot.put(_"Create new issue")
          end,
          module = "initiative",
          view = "new",
          params = { area_id = area.id }
        }
      end

    end

  end }
  
end }