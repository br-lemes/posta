
os.setlocale("pt_BR")
os.setlocale("C", "numeric")

local iup = require("iuplua")
local gui = require("server.layout")
local act = require("server.action")

iup.SetGlobal("UTF8MODE", "YES")
iup.SetGlobal("UTF8MODE_FILE", "YES")
iup.SetGlobal("LANGUAGE", "PORTUGUESE")

gui.dialog:show()
iup.MainLoop()
