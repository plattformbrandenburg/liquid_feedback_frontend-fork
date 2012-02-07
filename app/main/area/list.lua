local unit_id = param.get("unit_id", atom.integer)

local areas_selector = Area:build_selector{ active = true, unit_id = unit_id }

local unit = Unit:by_id(unit_id)


if config.feature_units_enabled then
  slot.put_into("title", unit.name)
else
  slot.put_into("title", encode.html(config.app_title))
end


if not app.session.member_id and config.motd_public then
  local help_text = config.motd_public
  ui.container{
    attr = { class = "wiki motd" },
    content = function()
      slot.put(format.wiki_text(help_text))
    end
  }
end

util.help("area.list", _"Area list")

if app.session.member_id then
  execute.view{
    module = "delegation",
    view = "_show_box",
    params = { unit_id = unit_id }
  }
end


execute.view{
  module = "area",
  view = "_list",
  params = { areas_selector = areas_selector }
}
