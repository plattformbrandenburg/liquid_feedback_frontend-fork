
local contacts_selector = Contact:new_selector()
  :add_where{ "member_id = ?", app.session.member.id }
  :join("member", nil, "member.id = contact.other_member_id")
  :add_order_by("member.name")

ui.paginate{
  selector = contacts_selector,
  content = function()
    local contacts = contacts_selector:exec()
    if #contacts == 0 then
      ui.field.text{ value = _"You didn't saved any member as contact yet." }
    else
      ui.list{
        records = contacts,
        columns = {
          {
            label = _"Name",
            content = function(record)
              ui.link{
                text = record.other_member.name,
                module = "member",
                view = "show",
                id = record.other_member_id
              }
            end
          },
          {
            label = _"Published",
            content = function(record)
              ui.field.boolean{ value = record.public }
            end
          },
          {
            content = function(record)
              if record.public then
                ui.link{
                  attr = { class = "action" },
                  text = _"Hide",
                  module = "contact",
                  action = "add_member",
                  id = record.other_member_id,
                  params = { public = false },
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
              else
                ui.link{
                  attr = { class = "action" },
                  text = _"Publish",
                  module = "contact",
                  action = "add_member",
                  id = record.other_member_id,
                  params = { public = true },
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
              end
            end
          },
          {
            content = function(record)
              ui.link{
                attr = { class = "action" },
                text = _"Remove",
                module = "contact",
                action = "remove_member",
                id = record.other_member_id,
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
            end
          },
        }
      }
    end
  end
}
