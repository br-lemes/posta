
local iup = require("iuplua")
local ico = require("server.icons")
local gui = { }

gui.dialog = iup.dialog{
	size      = "QUARTERxQUARTER",
	title     = "Servidor de Posta Restante",
	font      = "HELVETICA, BOLD 12",
	tray      = "YES",
	traytip   = "Servidor de Posta Restante",
	trayimage = ico.webmail,
	iup.vbox{
		margin = "10x10",
		gap    = "10",
		iup.label{ name  = "server" },
		iup.label{ name  = "status" },
	},
}

function gui.iupnames(self, elem)
	if type(elem) == "userdata" then
		if elem.name ~= "" and elem.name ~= nil then
			self[elem.name] = elem
		end
	end
	local i = 1
	while elem[i] do
		self:iupnames(elem[i])
		i = i + 1
	end
end

gui:iupnames(gui.dialog)

return gui
