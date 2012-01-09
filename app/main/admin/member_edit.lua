local id = param.get_id()

local member = Member:by_id(id)

if member then
  slot.put_into("title", encode.html(_("Member: '#{login}' (#{name})", { login = member.login, name = member.name })))
else
  slot.put_into("title", encode.html(_"Register new member"))
end

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
    ui.field.text{     label = _"Login",          name = "login" }
    ui.field.text{     label = _"Name",           name = "name" }
    ui.field.password{ label = _"Password",       name = "password", value = (member and member.password) and "********" or "" }
    ui.field.boolean{  label = _"Active?",        name = "active" }
    ui.field.boolean{  label = _"Admin?",         name = "admin" }
    ui.submit{         text  = _"Save" }
  end
}
