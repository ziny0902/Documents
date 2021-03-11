#!/usr/bin/lua

local script_path = string.gsub(arg[0], '/[^/]*%.lua$', '')
package.path = package.path .. ";" .. script_path .."/?.lua;".. script_path .."/luash/?.lua;" .. script_path .. "/plterm/?.lua"

local ex_home = "$HOME/Documents/example"
local sh = require('sh')
local DIRECTORY = 0
local FILE = 1


function create_item( path,  flag)
  local action=""
  if flag == DIRECTORY then action = "' /^d/{print $9} '" end
  if flag == FILE then action = "' /^[-]/{print $9} '" end
  local cmd_result = tostring((ls ("-l " .. path) : awk (action) ))

  local items={}
  local cnt  = 1;

  for item in string.gmatch(cmd_result, "[^\n]+") do
    items[cnt] = item
    cnt = cnt + 1
  end
  return items
end


local menu_level = 1 -- 1: lanague 2: category 3: example

local layout = require('layout')
local level_item = {
  { 
    path = ex_home,
    prompt = "Select Menu [Quit(q)] : " ,
    menu_keys = {'q'},
    menu=create_item(ex_home, DIRECTORY),
    flag = DIRECTORY
  },
  { 
    path = ex_home,
    prompt = "Select Category [Back(b), Quit(q)] : ",
    menu_keys = {'b', 'q'},
    menu = {},
    flag = DIRECTORY
  },
  {
    path = ex_home,
    prompt = "Select Example [Home(h), Back(b), Quit(q)] : ",
    menu_keys = {'h', 'b', 'q'},
    menu = {},
    flag = FILE
  }
}

--[
while true do
  layout.display_menu(
    level_item[menu_level].menu,
    level_item[menu_level].prompt,
    level_item[menu_level].menu_keys
  )
  local ret = layout.input_loop()

  if ret == string.byte('q') then 
    print("\nQuit")
    break 
  end

  if ret == string.byte('b') then 
    if menu_level > 1 then
      menu_level = menu_level - 1
    end
    ret = 0
  end
  if ret == string.byte('h') then 
    menu_level = 1
    ret = 0
  end

  -- TODO pdf viwer
  -- file view
  if ret > 0 and level_item[menu_level].flag == FILE then
    local path = level_item[menu_level].path .. "/" .. level_item[menu_level].menu[ret]
    os.execute("bat --paging always " .. path)
    ret = 0
  end


  if ret > 0 and menu_level < 3 then 
    local path = level_item[menu_level].path .. "/" .. level_item[menu_level].menu[ret]
    menu_level = menu_level + 1 
    level_item[menu_level].path = path

    local flag = level_item[menu_level].flag
    level_item[menu_level].menu = create_item(path, flag) 
  end


end
--]]
