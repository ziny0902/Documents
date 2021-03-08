#!/usr/bin/lua
package.path = package.path .. ";luash/?.lua;plterm/?.lua"
local  term = require "plterm"

layout = {
  input = "",
  display_item,
  prompt,
  menu_keys,
  menu_max_str_len,
  start_row = 1,
  selected = 0,
  max_row = 0,
  max_col = 0
}

--[[
-- menu의 문자열 최대 길이를 계산한다.
-- 터미널에서 커서가 움직여 다닐 수 있도록 mode를 바꾼다.
-- 터미널의 크기를 읽어 들이고 메뉴가 시작될 열의 위치를 계산한다.
-- 화면 가운데 정렬해서 메뉴를 표시한다.
--]]

function layout.display_menu(menu_item, prompt_msg, keys)
  layout.display_item = menu_item
  layout.prompt = prompt_msg
  layout.menu_keys = keys
  layout.menu_max_str_len = 0
  layout.selected = 0
  layout.input = ""
  for i = 1, #menu_item do
    local len = string.len(menu_item[i])
    if len > layout.menu_max_str_len then 
      layout.menu_max_str_len = len
    end
  end
--  print("menu string max length : " .. menu_max_str_len .. "\n")

  terminal_open()

  update_display()

  terminal_close()
end

function update_display()
  local screen_col = (layout.max_col - layout.menu_max_str_len)//2
  local screen_row = ((layout.max_row - 2) - #layout.display_item)//2
  --print("start column : ", screen_col)

  if screen_col <= 0 then screen_col = 1 end
  if screen_row < 0 then screen_row = 0 end

  for i = layout.start_row, #layout.display_item do
  --  term.outf(string.format("selected[%d]", selected))
    if (i + 1 - layout.start_row) >= layout.max_row - 1 then break end
    term.golc(screen_row + i + 1 - layout.start_row, screen_col)
    if  layout.selected == i then
      term.color(term.colors.green)
    else
      term.color(term.colors.normal)
    end
    term.outf(string.format("[%d] %s", i, layout.display_item[i]))
  end
  term.color(term.colors.normal)
  -- output prompt
  screen_col = (layout.max_col - string.len(layout.prompt))//2 
  if screen_col <= 0 then screen_col = 1 end
  term.golc(screen_row + #layout.display_item+2, screen_col)
  term.cleareol()
  term.outf(layout.prompt)
end

function input_validate(key)
  for i = 1, #layout.menu_keys do
    if(key == string.byte(layout.menu_keys[i])) then return true end
  end
  return false 
end

function layout.input_loop()
  local ret = 0
  terminal_open()
  update_display()
  local input_ready = term.input()
  while true do
    local code = input_ready()
    term.cleareol()
    process_input(code)
    if input_validate(code) then 
      layout.selected = code 
      break 
    end
    -- return key
    if tonumber(code) == 13  then
      local s = layout.input
      --[
      if string.len(s) > 0 and tonumber(s) <= #layout.display_item then
        layout.selected = tonumber(s)
      end
      --]]
      break
    end
  end
  terminal_close()
  return layout.selected
end

function process_input(key)
  term.golc(layout.max_row, 2)

  -- key up
  if key == 0xffed then 
    -- term.outf("key is up")
    if layout.selected > 1 then layout.selected = layout.selected - 1 end
    if layout.selected < layout.start_row then
      layout.start_row = layout.selected
    end
    layout.input = tostring(layout.selected)
   -- key down
  elseif key == 0xffec then 
    -- term.outf("key is down")
    if layout.selected < #layout.display_item then layout.selected = layout.selected + 1 end
    if (layout.selected - layout.start_row) >= layout.max_row - 2 then
      layout.start_row =  layout.start_row + 1
    end
    layout.input = tostring(layout.selected)
  end

  term.clear()
  update_display()

  -- back space
  if key == 0x7f then
    local s = layout.input
    if (string.len(s) > 0) then
      layout.input = string.sub(s, 1, string.len(s) - 1)
    end
  end
  if key >= string.byte('1') and key <= string.byte(tostring(#layout.display_item)) then
    layout.input = layout.input .. term.keyname(key)
  end
  term.outf(layout.input)
end

--[
-- terminal control
function terminal_open()
  term.clear()
  mode = term.savemode()
  term.setrawmode() -- required to enable getcurpos()

  layout.max_row, layout.max_col = term.getscrlc()
end

function terminal_close()
  term.golc(layout.max_row, 1)
  term.restoremode(mode)
end
--]]

return layout
