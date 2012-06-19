-- forward compatibility for webmcp 1.2
if not os.pfilter then
  os.pfilter = extos.pfilter
end
if not os.listdir then
  os.listdir = extos.listdir
end
if not os.crypt then
  os.crypt = extos.crypt
end

config.app_name = "LiquidFeedback"
config.app_version = "2.beta7"

config.instance_name = request.get_config_name()

config.app_title = config.app_name .. " " .. config.instance_name

config.app_logo = nil

config.app_service_provider = "Snake Oil<br/>10000 Berlin<br/>Germany"

--config.footer_html = '<a href="somewhere">some link</a>'

config.use_terms = "=== Terms of Use ===\nNothing is allowed."
--config.use_terms_html = ""

config.use_terms_checkboxes = {
  {
    name = "terms_of_use_v1",
    html = "I accept the terms of use.",
    not_accepted_error = "You have to accept the terms of use to be able to register."
  }
}

config.locked_profile_fields = {
  field_name = true,
}

config.member_image_content_type = "image/jpeg"
config.member_image_convert_func = {
  avatar = function(data) return os.pfilter(data, "convert", "jpeg:-", "-thumbnail",   "48x48", "jpeg:-") end,
  photo =  function(data) return os.pfilter(data, "convert", "jpeg:-", "-thumbnail", "240x240", "jpeg:-") end
}

config.member_image_default_file = {
  avatar = "avatar.jpg",
  photo = nil
}

config.default_lang = "de"

-- after how long is a user considered inactive and the trustee will see warning
-- notation is according to postgresql intervals
config.delegation_warning_time = '6 months'

config.mail_subject_prefix = "[LiquidFeedback] "

config.fastpath_url_func = nil

config.download_dir = nil

config.download_use_terms = "=== Nutzungsbedingungen ===\nAlles ist verboten"

config.public_access = false  -- Available options: "anonymous", "pseudonym"

config.api_enabled = true

config.feature_rss_enabled = false -- feature is broken

config.single_unit_id = false

-- OpenID authentication is not fully implemented yet, DO NOT USE BEFORE THIS NOTICE HAS BEEN REMOVED!
config.auth_openid_enabled = false
config.auth_openid_https_as_default = true
config.auth_openid_identifier_check_func = function(uri) return false end

request.set_allowed_json_request_slots{ "title", "actions", "support", "default", "trace", "system_error" }


if request.get_json_request_slots() then
  request.force_absolute_baseurl()
end

request.set_404_route{ module = 'index', view = '404' }

-- uncomment the following two lines to use C implementations of chosen
-- functions and to disable garbage collection during the request, to
-- increase speed:
--
require 'webmcp_accelerator'
collectgarbage("stop")

-- open and set default database handle
db = assert(mondelefant.connect{
  engine='postgresql',
  dbname='liquid_feedback'
})
at_exit(function() 
  db:close()
end)
function mondelefant.class_prototype:get_db_conn() return db end

-- enable output of SQL commands in trace system
function db:sql_tracer(command)
  return function(error_info)
    local error_info = error_info or {}
    trace.sql{ command = command, error_position = error_info.position }
  end
end

request.set_absolute_baseurl(config.absolute_base_url)



-- TODO abstraction
-- get record by id
function mondelefant.class_prototype:by_id(id)
  local selector = self:new_selector()
  selector:add_where{ 'id = ?', id }
  selector:optional_object_mode()
  return selector:exec()
end
