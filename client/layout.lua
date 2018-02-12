
local iup = require("iuplua")
local ico = require("client.icons")
local gui = { }

gui.menu = iup.menu{
	radio = "YES",
	iup.item{
		name  = "menusearch",
		title = "Pesquisa\tF3",
		value = "ON",
	},
	iup.item{
		name  = "menuconf",
		title = "Opções\tF5",
		value = "OFF",
	},
}

gui.dialog = iup.dialog{
	rastersize = "600x440",
	title      = "Posta Restante",
	font       = "HELVETICA, BOLD 12",
	iup.vbox{
		margin = "10x10",
		gap    = "10",
		iup.hbox{
			margin = "0",
			iup.text{
				name       = "search",
				expand     = "HORIZONTAL",
				rastersize = "x24",
			},
			iup.button{
				name  = "menubutton",
				image = ico.magnifier,
			},
		},
		iup.zbox{
			name   = "zbox",
			margin = "0",
			iup.vbox{
				name = "result_box",
				iup.list{
					name           = "result",
					visiblelines   = "1",
					visiblecolumns = "1",
					expand         = "YES",
					showimage      = "YES",
				},
				iup.zbox{
					name       = "b_zbox",
					rastersize = "x50",
					iup.vbox{
						name = "icons_box",
						iup.fill{},
						iup.hbox{
							flat   = "YES",
							iup.fill{},
							iup.toggle{
								name   = "error",
								image  = ico.error,
								value  = "ON",
								tip    = "Objeto qualificado",
								action = function () gui.rload() end,
							},
							iup.toggle{
								name   = "mail_white",
								image  = ico.mail_white,
								value  = "ON",
								tip    = "Envelope registrado",
								action = function () gui.rload() end,
							},
							iup.toggle{
								name   = "mail_yellow",
								image  = ico.mail_yellow,
								value  = "ON",
								tip    = "Envelope sedex",
								action = function () gui.rload() end,
							},
							iup.toggle{
								name   = "mail_black",
								image  = ico.mail_black,
								value  = "ON",
								tip    = "Envelope simples",
								action = function () gui.rload() end,
							},
							iup.toggle{
								name   = "mail_red",
								image  = ico.mail_red,
								value  = "ON",
								tip    = "Objetos a cobrar ou tributados",
								action = function () gui.rload() end,
							},
							iup.toggle{
								name   = "package",
								image  = ico.package,
								value  = "ON",
								tip    = "Pacotes internacionais ou registrados",
								action = function () gui.rload() end,
							},
							iup.toggle{
								name   = "box",
								image  = ico.box,
								value  = "ON",
								tip    = "Volume",
								action = function () gui.rload() end,
							},
							iup.toggle{
								name   = "mail_box",
								image  = ico.mail_box,
								value  = "OFF",
								tip    = "Caixa postal",
								action = function () gui.rload() end,
							},
							iup.fill{},
						},
						iup.fill{},
					},
					iup.vbox{
						name = "details_box",
						iup.label{
							name      = "details",
							expand    = "HORIZONTAL",
							alignment = "ACENTER",
							title     = "\n",
						},
					},
					iup.vbox{
						name = "ancient_box",
						iup.label{
							name      = "ancient",
							expand    = "HORIZONTAL",
							alignment = "ACENTER",
							title     = "Dados muito antigos. Pode não haver um\n" ..
							            "servidor de posta restante funcionando.",
							fgcolor   = "255 0 0",
						},
					},
				},
			},
			iup.hbox{
				name = "config_box",
				iup.vbox{
					iup.frame{
						title = "Prazo de Guarda",
						iup.vbox{
							margin = "10x5",
							iup.hbox{
								margin = "0",
								iup.frame{
									bgcolor = "0 0 0",
									margin  = "5x5",
									gap     = "5",
									iup.vbox{
										iup.hbox{
											iup.fill{},
											iup.label{
												fgcolor = "0 0 255",
												title   = "SEDEX/PAC",
											},
											iup.label{
												fgcolor = "255 0 0",
												title   = os.date("%d", os.time()-8*24*60*60),
											},
											iup.label{
												fgcolor = "255 127 0",
												title   = os.date("%d", os.time()-7*24*60*60),
											},
											iup.label{
												fgcolor = "255 255 0",
												title   = os.date("%d", os.time()-6*24*60*60),
											},
											iup.label{
												fgcolor = "127 255 0",
												title   = os.date("%d", os.time()-5*24*60*60),
											},
											iup.label{
												fgcolor = "0 255 0",
												title   = os.date("%d", os.time()-4*24*60*60),
											},
											iup.fill{},
										},
										iup.hbox{
											iup.fill{},
											iup.label{
												fgcolor = "0 0 255",
												title   = "INT/REG",
											},
											iup.label{
												fgcolor = "255 0 0 ",
												title   = os.date("%d", os.time()-21*24*60*60),
											},
											iup.label{
												fgcolor = "255 127 0",
												title   = os.date("%d", os.time()-20*24*60*60),
											},
											iup.label{
												fgcolor = "255 255 0",
												title   = os.date("%d", os.time()-19*24*60*60),
											},
											iup.label{
												fgcolor = "127 255 0",
												title   = os.date("%d", os.time()-18*24*60*60),
											},
											iup.label{
												fgcolor = "0 255 0",
												title   = os.date("%d", os.time()-17*24*60*60),
											},
											iup.fill{},
										},
									},
								},
							},
						},
					},
					iup.frame{
						title = "Pesquisa",
						iup.vbox{
							margin = "10x10",
							iup.list{
								name     = "cfg_unit",
								dropdown = "YES",
								expand   = "HORIZONTAL",
								value    = 1,
								action   = function () gui.rload() end,
-- custom [[
								"Lucas do Rio Verde",
								"Groslândia",
								"Itambiquara",
								"Tessele Jr",
								"Todas",
-- custom ]]
							},
							iup.list{
								name     = "cfg_sby",
								dropdown = "YES",
								expand   = "HORIZONTAL",
								value    = 2,
								action   = function () gui.rload() end,
								"LDI",
								"Nome",
								"Comentário",
								"Código",
							},
							iup.button{
								name   = "cfg_late",
								title  = "&Vencidos",
								expand = "HORIZONTAL",
							},
							iup.toggle{
								name   = "cfg_today",
								title  = "Vencer &hoje",
								action = function () gui.rload() end,
							},
						},
					},
				},
			},
		},
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
gui:iupnames(gui.menu)

return gui
