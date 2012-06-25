ui.tag{ tag = "ul", content = function()
  
  ui.tag{ tag = "li", content = function()

    ui.link{
      text = _"Show profile",
      module = "member",
      view = "show",
      id = app.session.member_id
    }
    
  end }
   
  ui.tag{ tag = "li", content = function()

    ui.link{
      content = function()
          slot.put(_"Edit profile")
      end,
      module = "member",
      view = "edit"
    }

  end }
   
  ui.tag{ tag = "li", content = function()

    ui.link{
      content = function()
          slot.put(_"Upload avatar/photo")
      end,
      module = "member",
      view = "edit_images"
    }

  end }
    
  ui.tag{ tag = "li", content = function()

    ui.link{
      content = _"Contacts",
      module = 'contact',
      view   = 'list'
    }

  end }
   
  ui.tag{ tag = "li", content = function()

    ui.link{
      text   = _"Settings",
      module = "member",
      view = "settings"
    }

  end }
   
  ui.tag{ tag = "li", content = function()

    ui.link{
      text   = _"Logout",
      module = 'index',
      action = 'logout',
      routing = {
        default = {
          mode = "redirect",
          module = "index",
          view = "index"
        }
      }
    }
  end }

  for i, lang in ipairs(config.available_languages) do
    ui.tag{ tag = "li", content = function()
      ui.link{
        content = _('Select language "#{langcode}"', { langcode = lang }),
        module = "index",
        action = "set_lang",
        params = { lang = lang },
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
    end }
  end

end }

