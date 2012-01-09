local issue = param.get("issue", "table")

local policy = issue.policy
ui.form{
  record = issue,
  readonly = true,
  attr = { class = "vertical" },
  content = function()
    ui.field.text{       label = _"Population",            name = "population" }
    ui.field.text{       label = _"State",                 name = "state" }
    ui.field.timestamp{  label = _"Created at",            name = "created" }
    ui.field.text{       label = _"Admission time",        value = issue.admission_time }
    ui.field.text{
      label = _"Issue quorum",
      value = format.percentage(policy.issue_quorum_num / policy.issue_quorum_den)
    }
    if issue.population then
      ui.field.text{
        label = _"Currently required",
        value = math.ceil(issue.population * policy.issue_quorum_num / policy.issue_quorum_den)
      }
    end
    ui.field.timestamp{  label = _"Accepted at",           name = "accepted" }
    ui.field.text{       label = _"Discussion time",       value = issue.discussion_time }
    ui.field.vote_now{   label = _"Vote now",              name = "vote_now" }
    ui.field.vote_later{ label = _"Vote later",            name = "vote_later" }
    ui.field.timestamp{  label = _"Half frozen at",        name = "half_frozen" }
    ui.field.text{       label = _"Verification time",     value = issue.verification_time }
    ui.field.text{
      label   = _"Initiative quorum",
      value = format.percentage(policy.initiative_quorum_num / policy.initiative_quorum_den)
    }
    if issue.population then
      ui.field.text{
        label   = _"Currently required",
        value = math.ceil(issue.population * (issue.policy.initiative_quorum_num / issue.policy.initiative_quorum_den)),
      }
    end
    ui.field.timestamp{  label = _"Fully frozen at",       name = "fully_frozen" }
    ui.field.text{       label = _"Voting time",           value = issue.voting_time }
    ui.field.timestamp{  label = _"Closed",                name = "closed" }
  end
}
ui.form{
  record = issue.policy,
  readonly = true,
  content = function()
  end
}
