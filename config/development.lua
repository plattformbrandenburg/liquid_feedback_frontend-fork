config.absolute_base_url = "http://10.8.33.34/lf/"

execute.config("default")

config.formatting_engine_executeables = {
  rocketwiki= "/opt/rocketwiki/rocketwiki-lqfb",
  compat = "/opt/rocketwiki/rocketwiki-lqfb-compat"
}

config.mail_from = "LiquidFeedback"
config.mail_reply_to = "liquid-support@localhost"

config.issue_discussion_url_func = function(issue) return "http://example.com/issue_" .. tostring(issue.id) end