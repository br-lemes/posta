
local iup = require("iuplua")
local fun = require("functions")
local gui = require("server.layout")
local sro = require("server.import")
local act = { min = 1 }

-- action functions

function act.clean()
	local data = fun.alldata()
	for i,v in pairs(data) do
		local diffdata = fun.diffdata(v)
		if diffdata > 30 * 24 * 60 or (diffdata > 60  and v:match("(%d%d)m") ~= "00") then
			os.remove(string.format("data/srodata-%s.lua", v))
			os.remove(string.format("data/ldidata-%s.lua", v))
			os.remove(string.format("data/objdata-%s.lua", v))
			os.remove(string.format("data/csvdata-%s.csv", v))
		end
	end
end

function act.question(message)
	local dlg = iup.messagedlg{
		title      = "Confirmar",
		value      = message,
		buttons    = "YESNO",
		dialogtype = "QUESTION"
	}
	dlg:popup()
	return dlg.buttonresponse == "1"
end

-- callback functions

function gui.dialog:close_cb()
	if act.question("Sair do Servidor de Posta Restante?") then
		gui.dialog.tray = "NO"
		self:hide()
	else
		return iup.IGNORE
	end
end

function gui.dialog:k_any(k)
	if k == iup.K_ESC then
		self:close_cb()
	end
end

local count = 0

function gui.dialog:trayclick_cb(b, press, dclick)
	if b == 1 and press then
		if count == 0 then
			if self.visible == "YES" then
				self.hidetaskbar = "YES"
			else
				self.hidetaskbar = "NO"
			end
			count = 1
		else
			count = 0
		end
	end
end

gui.timer = iup.timer{
	time = 1000 * (act.min * 60)
}

function gui.timer:action_cb()
	act.clean()
	if not act.force then
		local date = os.date("*t")
		if date.hour < 7 or date.hour > 19 or date.wday == 1
			or date.wday == 7 then return end -- custom sábado
	end
	gui.status.title = sro.import()
end

gui.server.title = "Concentrador SRO: " .. sro.server

function gui.init()
	local diffdata = fun.diffdata()
	if not diffdata or diffdata >= 1.5 then
		gui.timer:action_cb()
		gui.timer.run = "YES"
	else
		h = io.open("data/server", "r")
		local server = h:read("*a")
		h:close()
		gui.status.title = string.format(
	[[
Sua última sincronização foi a menos
de %d minuto. Talvez já tenha um servidor
rodando. Senão tente mais tarde.
Servidor: %s]], act.min, server)
	end
end

return act
