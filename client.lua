
os.setlocale("pt_BR")
os.setlocale("C", "numeric")

local iup = require("iuplua")
local eng = require("client.engine")
local gui = require("client.layout")
local act = require("client.action")

iup.SetGlobal("UTF8MODE", "YES")
iup.SetGlobal("UTF8MODE_FILE", "YES")
iup.SetGlobal("LANGUAGE", "PORTUGUESE")

eng.load()
gui.dialog:show()
gui.rload()
iup.MainLoop()
