slot.set_layout("rss")

local function rss_channel(channel)
  for key, val in pairs(channel) do
    slot.put("<", key, ">", val, "</", key, ">")
  end
end

local function rss_item(item)
  slot.put("<item>")
  for key, val in pairs(item) do
    slot.put("<", key, ">", val, "</", key, ">")
  end
  slot.put("</item>")
end


local initiative = Initiative:by_id(param.get_id())

rss_channel{
  title = initiative.name,
  description = initiative.current_draft.content,
  language = "de",
  copyright = initiative.current_draft.author.name,
  pubDate = "Tue, 8 Jul 2008 2:43:19"
}

for i, suggestion in ipairs(initiative.suggestions) do
  
  local text = suggestion.name

  text = text .. " ("
  text = text .. tostring(suggestion.plus2_unfulfilled_count + suggestion.plus2_unfulfilled_count) .. "++ "
  text = text .. tostring(suggestion.plus1_unfulfilled_count + suggestion.plus1_unfulfilled_count) .. "+ "
  text = text .. tostring(suggestion.minus1_unfulfilled_count + suggestion.minus1_unfulfilled_count) .. "- "
  text = text .. tostring(suggestion.minus2_unfulfilled_count + suggestion.minus2_unfulfilled_count) .. "--"

  text = text .. ")"

  rss_item{
    title = text,
    description = suggestion.content,
    link = "http://localhost/lf/suggestion/show/" .. tostring(suggestion.id) .. ".html",
    author = "",
    guid = "guid",
    pubDate = "Tue, 8 Jul 2008 2:43:19"
  }

end