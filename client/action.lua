
local iup = require("iuplua")
local eng = require("client.engine")
local gui = require("client.layout")
local ico = require("client.icons")
local act = { min = 1 }

-- action functions

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

act.timer = iup.timer{
	time      = 1000 * (act.min * 60),
	run       = "YES",
	action_cb = function () eng.load() end
}

act.select_timer = iup.timer{
	time      = 5000,
	run       = "NO",
	action_cb = function () gui.search.selection = "ALL" end
}

act.clipboard = iup.clipboard{}

-- special action/callback functions

-- custom [[
local cfg_unit = { "78455970", "78455971", "78455972", "78455973" }
-- custom ]]

function gui.rload()
	gui.result.removeitem = "ALL"
	gui.rtable = eng.search{
		search = gui.search.value,
		outros = gui.error.value       == "ON",
		envreg = gui.mail_white.value  == "ON",
		envsed = gui.mail_yellow.value == "ON",
		simple = gui.mail_black.value  == "ON",
		intern = gui.package.value     == "ON",
		volume = gui.box.value         == "ON",
		postal = gui.mail_box.value    == "ON",
		unit   = cfg_unit[tonumber(gui.cfg_unit.value)],
		sby    = tonumber(gui.cfg_sby.value),
	}
	gui.load_timer.run = "NO"
	gui.details.title = ""
	gui.b_zbox.value = gui.icons_box
	iup.SetIdle(gui.iload)
end

gui.load_timer = iup.timer{
	time      = 500,
	run       = "NO",
	action_cb = gui.rload
}

function gui.iload()
	local n = gui.result.count + 1
	local v = gui.rtable[n]
	if v and type(v) == "table" then
		if v.CS_NAME then
			gui.result.appenditem = v.CS_NAME
			if v.OBJ_TYPE == "outros" then
				gui.result["image" .. n] = ico.error
			elseif v.OBJ_TYPE == "envreg" then
				gui.result["image" .. n] = ico.mail_white
			elseif v.OBJ_TYPE == "envsed" then
				gui.result["image" .. n] = ico.mail_yellow
			elseif v.OBJ_TYPE == "intern" then
				gui.result["image" .. n] = ico.package
			elseif v.OBJ_TYPE == "volume" then
				gui.result["image" .. n] = ico.box
			elseif v.OBJ_TYPE == "postal" then
				gui.result["image" .. n] = ico.mail_box
			end
		elseif v[3] then
			gui.result.appenditem = v[3]
			gui.result["image" .. n] = ico.mail_black
		end
	elseif v then
		gui.result.appenditem = v
	else
		iup.SetIdle(nil)
		if gui.search.value:find("^%a%a%d%d%d%d%d%d%d%d%d%a%a$") and gui.result.count == "1" then
			gui.result.value = "1"
			--gui.result:valuechanged_cb()
			gui.search.value = ""
		end
	end
end

-- callback functions

function gui.dialog:close_cb()
	if act.question("Sair do Posta Restante?") then
		self:hide()
	else
		return iup.IGNORE
	end
end

function gui.dialog:k_any(k)
	if k == iup.K_ESC then
		if gui.zbox.value == gui.config_box then
			gui.zbox.value = gui.result_box
		else
			self:close_cb()
		end
	elseif k == iup.K_F3 then
		gui.menusearch:action()
	elseif k == iup.K_F5 then
		gui.menuconf:action()
	elseif k == iup.K_DOWN and iup.GetFocus() == gui.search then
		iup.SetFocus(gui.result)
		gui.result.value = "1"
		gui.result:valuechanged_cb()
	elseif k == iup.K_UP and iup.GetFocus() == gui.result and gui.result.value == "1" then
		iup.SetFocus(gui.search)
		gui.result.value = nil
		gui.result:valuechanged_cb()
		gui.b_zbox.value = gui.icons_box
		return iup.IGNORE
	elseif k == iup.K_CR then
		if gui.zbox.value == gui.result_box then
			if iup.GetFocus() == gui.search then
				if gui.search.value:find("^%a%a%d%d%d%d%d%d%d%d%d%a%a$") or gui.search.value:find("^%d%d%d%d%d%d%d%d%d%d%d%d$") then
					gui.rload()
				end
			elseif iup.GetFocus() == gui.result then
				gui.result:dblclick_cb(tonumber(gui.result.value))
			end
		end
	elseif gui.zbox.value == gui.config_box and (k == iup.K_H or k == iup.K_h) then
		gui.cfg_today.value = "TOGGLE"
		return iup.IGNORE
	elseif gui.zbox.value == gui.config_box and (k == iup.K_V or k == iup.K_v) then
		gui.cfg_late:action()
		return iup.IGNORE
--	elseif (k == iup.K_cC or iup.K_cc) and iup.GetFocus() == gui.result and gui.result.value ~= nil and gui.result.value ~= "0" then
	elseif (k == 805306435 or k == 536870979) and iup.GetFocus() == gui.result and gui.result.value ~= nil and gui.result.value ~= "0" then
		gui.result:dblclick_cb(tonumber(gui.result.value), nil, true)
	end
end

function gui.menubutton:action()
	gui.menu:popup(iup.MOUSEPOS, iup.MOUSEPOS)
end

function gui.menusearch:action(late)
	gui.menuconf.value   = "OFF"
	gui.menusearch.value = "ON"
	gui.menubutton.image = ico.magnifier
	gui.zbox.value = gui.result_box
	iup.SetFocus(gui.search)
end

function gui.menuconf:action()
	gui.menusearch.value = "OFF"
	gui.menuconf.value   = "ON"
	gui.menubutton.image = ico.cog
	gui.zbox.value = gui.config_box
	iup.SetFocus(gui.search)
end

function gui.search:valuechanged_cb()
	if gui.zbox.value == gui.result_box then
		act.select_timer.run = "NO"
		act.select_timer.run = "YES"
	end
	gui.load_timer.run  = "YES"
end

function gui.result:valuechanged_cb()
	local n = tonumber(gui.result.value) or 0
	if n > 0 then
		local v = gui.rtable[n]
		if type(v) == "table" then
			gui.b_zbox.value = gui.details_box
			if v.CS_NAME then
				gui.details.title = string.format(
					"Objeto: %s - %s: %s - Data: %s\nComentário: %s",
					v.LTD_ITEMCODE,
					v.LTD_EVENTTYPECODE or "LDI",
					v.LTD_ID,
					v.LTD_CREATETIME:sub(1, 10),
					v.LTD_COMMENT)
				if v.LTD_CREATETIME:sub(1, 10) <
					os.date("%Y-%m-%d", os.time()-v.LTD_LASTTIME*24*60*60) then
					gui.details.fgcolor = "255 0 0"
				else
					gui.details.fgcolor = "0 0 0"
				end
			elseif v[3] then
				gui.details.title = string.format("Número: %s - Data: %s\n", v[2], v[1])
				-- TODO late
			end
		end
	end
end

function gui.cfg_late:action()
	gui.result.removeitem = "ALL"
	gui.rtable = eng.search{
		postal = true,
		late   = true,
		ltoday = gui.cfg_today.value == "ON"
	}
	gui.load_timer.run = "NO"
	iup.SetIdle(gui.iload)
	gui.menusearch:action(true)
end

function gui.result:dblclick_cb(item, text, copy)
	local v = gui.rtable[item]
	if type(v) == "table" then
		if v.LTD_ITEMCODE then
			act.clipboard.text = nil
			act.clipboard.text = v.LTD_ITEMCODE
			gui.details.fgcolor = "0 0 255"
		end
	else
		if not copy then
			gui.cfg_sby.value = "2"
			gui.search.value = v
			gui.rload()
		else
			local s = ""
			for i,v in ipairs(ldidata[v]) do
				s = string.format("%s%s,,%d,%s,,%s,,,,,,,,,%s,%s\n", s, v.LTD_ITEMCODE, v.LTD_GROUPNUMBER, v.CS_NAME, v.LTD_COMMENT, v.LTD_ID, v.OBJ_TYPE)
			end
			act.clipboard.text = nil
			act.clipboard.text = s
		end
	end
end

return act
