local id = param.get_id()

local unit = Unit:by_id(id)

if member then
  slot.put_into("title", encode.html(_("Unit: '#{name}'", { name = unit.name })))
else
  slot.put_into("title", encode.html(_"Add new unit"))
end

local units_selector = Unit:new_selector()
  
if member then
  units_selector
    :left_join("privilege", nil, { "privilege.member_id = ? AND privilege.unit_id = unit.id", member.id })
    :add_field("privilege.voting_right", "voting_right")
end

local units = units_selector:exec()
  
ui.form{
  attr = { class = "vertical" },
  module = "admin",
  action = "member_update",
  id = member and member.id,
  record = member,
  readonly = not app.session.member.admin,
  routing = {
    default = {
      mode = "redirect",
      modules = "admin",
      view = "member_list"
    }
  },
  content = function()
    ui.field.text{     label = _"Identification", name = "identification" }
    ui.field.text{     label = _"Notification email", name = "notify_email" }
    ui.field.boolean{  label = _"Admin?",       name = "admin" }

    slot.put("<br />")
    
    for i, unit in ipairs(units) do
      ui.field.boolean{
        name = "unit_" .. unit.id,
        label = unit.name,
        value = unit.voting_right
      }
    end
    slot.put("<br /><br />")

    ui.field.boolean{  label = _"Send invite?",       name = "invite_member" }
    ui.submit{         text  = _"Save" }
  end
}
