local unit = Unit:by_id(param.get_id()) or Unit:new()

param.update(unit, "parent_id", "name", "description", "external_reference", "active")

unit:save()
