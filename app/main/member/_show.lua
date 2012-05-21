local show_as_homepage = param.get("show_as_homepage", atom.boolean)

local member = param.get("member", "table")

local tabs = {
  module = "member",
  view = "show_tab",
  static_params = {
    member_id = member.id,
    show_as_homepage = show_as_homepage
  }
}

if show_as_homepage and app.session.member_id == member.id then

  if app.session.member.notify_email_unconfirmed then
    tabs[#tabs+1] = {
      class = "yellow",
      name = "email_unconfirmed",
      label = _"Email unconfirmed",
      module = "member",
      view = "_email_unconfirmed",
      params = {}
    }
  end

  if app.session.member.notify_level == nil then
    tabs[#tabs+1] = {
      class = "yellow",
      name = "notify_level_not_set",
      label = _"Notifications",
      module = "member",
      view = "_notify_level_not_set"
    }
  end
  
  local broken_delegations = Delegation:new_selector()
    :join("issue", nil, "issue.id = delegation.issue_id AND issue.closed ISNULL")
    :join("member", nil, "delegation.trustee_id = member.id")
    :add_where{"delegation.truster_id = ?", member.id}
    :add_where{"member.active = 'f' OR (member.last_activity IS NULL OR age(member.last_activity) > ?::interval)", config.delegation_warning_time }

  if broken_delegations:count() > 0 then
    tabs[#tabs+1] = {
      class = "red",
      name = "broken_delegations",
      label = _"Delegation problems" .. " (" .. tostring(broken_delegations:count()) .. ")",
      icon = { static = "icons/16/table_go.png" },
      module = "delegation",
      view = "_list",
      params = { delegations_selector = broken_delegations, outgoing = true },
    }
  end

  local selector = Issue:new_selector()
    :join("area", nil, "area.id = issue.area_id")
    :join("privilege", nil, { "privilege.unit_id = area.unit_id AND privilege.member_id = ? AND privilege.voting_right", app.session.member_id })
    :left_join("direct_voter", nil, { "direct_voter.issue_id = issue.id AND direct_voter.member_id = ?", app.session.member.id })
    :left_join("interest", nil, { "interest.issue_id = issue.id AND interest.member_id = ?", app.session.member.id })
    :left_join("membership", nil, { "membership.area_id = area.id AND membership.member_id = ? ", app.session.member.id })
    :add_where{ "direct_voter.member_id ISNULL" }
    :add_where{ "interest.member_id NOTNULL OR membership.member_id NOTNULL" }
    :add_where{ "issue.fully_frozen NOTNULL" }
    :add_where{ "issue.closed ISNULL" }
    :add_order_by{ "issue.fully_frozen + issue.voting_time ASC" }
    
  local count = selector:count()
  if count > 0 then
    tabs[#tabs+1] = {
      class = "yellow",
      name = "not_voted_issues",
      label = _"Now in voting" .. " (" .. tostring(count) .. ")",
      icon = { static = "icons/16/email_open.png" },
      module = "issue",
      view = "_list",
      params = {
        issues_selector = selector,
        no_filter = true
      }
    }
  end

  local initiator_invites_selector = Initiative:new_selector()
    :join("issue", "_issue_state", "_issue_state.id = initiative.issue_id")
    :join("initiator", nil, { "initiator.initiative_id = initiative.id AND initiator.member_id = ? AND initiator.accepted ISNULL", app.session.member.id })
    :add_where("_issue_state.closed ISNULL AND _issue_state.half_frozen ISNULL")

  if initiator_invites_selector:count() > 0 then
    tabs[#tabs+1] = {
      class = "yellow",
      name = "initiator_invites",
      label = _"Initiator invites" .. " (" .. tostring(initiator_invites_selector:count()) .. ")",
      icon = { static = "icons/16/user_add.png" },
      module = "index",
      view = "_initiator_invites",
      params = {
        initiatives_selector = initiator_invites_selector
      }
    }
  end

  local updated_drafts_selector = Initiative:new_selector()
    :join("issue", "_issue_state", "_issue_state.id = initiative.issue_id AND _issue_state.closed ISNULL AND _issue_state.fully_frozen ISNULL")
    :join("current_draft", "_current_draft", "_current_draft.initiative_id = initiative.id")
    :join("supporter", "supporter", { "supporter.member_id = ? AND supporter.initiative_id = initiative.id AND supporter.draft_id < _current_draft.id", app.session.member_id })
    :add_where("initiative.revoked ISNULL")

  if updated_drafts_selector:count() > 0 then
    tabs[#tabs+1] = {
      class = "yellow",
      name = "updated_drafts",
      label = _"Updated drafts" .. " (" .. tostring(updated_drafts_selector:count()) .. ")",
      icon = { static = "icons/16/script.png" },
      module = "index",
      view = "_updated_drafts",
      params = {
        initiatives_selector = updated_drafts_selector
      }
    }
  end
end

if not show_as_homepage then
  tabs[#tabs+1] = {
    name = "profile",
    label = _"Profile",
    icon = { static = "icons/16/application_form.png" },
    module = "member",
    view = "_profile",
    params = { member = member },
  }
end


local areas_selector = member:get_reference_selector("areas")
tabs[#tabs+1] = {
  name = "areas",
  label = _"Units",
  icon = { static = "icons/16/package.png" },
  module = "member",
  view = "_area_list",
  params = { areas_selector = areas_selector, member = member, for_member = not show_as_homepage },
}
  
if show_as_homepage then
  tabs[#tabs+1] = {
    name = "timeline",
    label = _"Latest events",
    module = "member",
    view = "_event_list",
    params = { }
  }
else
  tabs[#tabs+1] = {
    name = "timeline",
    label = _"Events",
    module = "event",
    view = "_list",
    params = { for_member = member }
  }
end

tabs[#tabs+1] = {
  name = "open",
  label = _"Open issues",
  module = "issue",
  view = "_list",
  link_params = { 
    filter_interest = not show_as_homepage and "issue" or nil,
  },
  params = {
    for_state = "open",
    for_member = not show_as_homepage and member or nil,
    issues_selector = Issue:new_selector()
      :add_where("issue.closed ISNULL")
      :add_order_by("coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()")
  }
}

tabs[#tabs+1] = {
  name = "closed",
  label = _"Closed issues",
  module = "issue",
  view = "_list",
  link_params = { 
    filter_interest = not show_as_homepage and "issue" or nil,
  },
  params = {
    for_state = "closed",
    for_member = not show_as_homepage and member or nil,
    issues_selector = Issue:new_selector()
      :add_where("issue.closed NOTNULL")
      :add_order_by("issue.closed DESC")

  }
}

if show_as_homepage then
  tabs[#tabs+1] = {
    name = "members",
    label = _"Members",
    module = 'member',
    view   = '_list',
    params = { members_selector = Member:new_selector() }
  }
end



if not show_as_homepage then
  local outgoing_delegations_selector = member:get_reference_selector("outgoing_delegations")
    :left_join("issue", "_member_showtab_issue", "_member_showtab_issue.id = delegation.issue_id")
    :add_where("_member_showtab_issue.closed ISNULL")
  tabs[#tabs+1] = {
    name = "outgoing_delegations",
    label = _"Outgoing delegations" .. " (" .. tostring(outgoing_delegations_selector:count()) .. ")",
    icon = { static = "icons/16/table_go.png" },
    module = "delegation",
    view = "_list",
    params = { delegations_selector = outgoing_delegations_selector, outgoing = true },
  }

  local incoming_delegations_selector = member:get_reference_selector("incoming_delegations")
    :left_join("issue", "_member_showtab_issue", "_member_showtab_issue.id = delegation.issue_id")
    :add_where("_member_showtab_issue.closed ISNULL")
  tabs[#tabs+1] = {
    name = "incoming_delegations",
    label = _"Incoming delegations" .. " (" .. tostring(incoming_delegations_selector:count()) .. ")",
    icon = { static = "icons/16/table_go.png" },
    module = "delegation",
    view = "_list",
    params = { delegations_selector = incoming_delegations_selector, incoming = true },
  }

  local contacts_selector = member:get_reference_selector("saved_members"):add_where("public")
  tabs[#tabs+1] = {
    name = "contacts",
    label = _"Contacts" .. " (" .. tostring(contacts_selector:count()) .. ")",
    icon = { static = "icons/16/book_edit.png" },
    module = "member",
    view = "_list",
    params = { members_selector = contacts_selector },
  }
end

ui.tabs(tabs)
