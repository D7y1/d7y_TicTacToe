fx_version 'adamant'
games {'gta5'}

description 'Tic Tac Toe (X - O) Game , Ui Credit Goes to Zed Dash on codepen , Lua and Js Writtin by Me (D7y#0511)'

ui_page "html/index.html"
files {
  "html/index.html",
  "html/style.css",
}

shared_script "Config.lua"
client_scripts {
  'Client.lua',
}

server_scripts {
  "Server.lua"
}