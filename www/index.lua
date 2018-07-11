
local day = os.date("%Y-%m-%d")
local ucep = "78455970"
local only = true

package.loaded.lfs = lfs
local fun = require("functions")
local csv = require("client.csvutils")

mg.write([[
HTTP/1.0 200 OK
Content-Type: text/html

<!DOCTYPE html>
<html lang="pt-BR">
<head>
	<meta charset="UTF-8">
	<title>Posta Restante</title>
	<style>
		a:link {
			color: #0074d9;
			font-weight: bold;
			text-decoration: none;
		}
		a:visited { color: #001f3f; }
		a:active, a:hover { text-decoration: underline; }
		h2 { text-align: center; }
		div.qrcode {
			align-items: flex-end;
			display: flex;
			justify-content: space-between;
			width: 100%;
		}
		div.new { border: 15px solid #0074d9; }
		div.old { border: 15px solid #001f3f; }
		div.click { border: 15px solid #2ecc40; }
		div.empty { border: 15px solid #001f3f; height: 32px; width: 32px; }
	</style>
</head>
<body>
]])

function touch(name)
	io.open(string.format("www/img/%s.svg", name), "w"):close()
end

function exists(name)
	local mode = lfs.attributes(string.format("www/img/%s.svg", name), "mode")
	return mode ~= nil
end

function qrencode(name, data)
	if not exists(name) then
		local h = io.popen(string.format("qrencode -t svg -o %q",
			string.format("www/img/%s.svg", name)), "w")
		h:write(data)
		h:close()
		return true
	end
	return false
end

function phone_decode(phone)
	-- Somente DDI de 2 dígitos
	-- DDI padrão 55 - Brasil
	-- DDD padrão 65 - Mato Grosso
	if not phone or phone == "" or phone:find("[^0-9()+%- ]") then return "" end
	phone = phone:gsub(".", function(c) if tonumber(c) ~= nil then return c else return "" end end)
	if #phone == 8 then phone = "5565" .. phone end
	if #phone == 9 and phone:sub(1, 1) == "9" then
		phone = "5565" .. phone:sub(2, -1)
	end
	if #phone == 10 or #phone == 11 or (#phone == 12 and phone:sub(1, 1) == "0") then
		phone = "55" .. phone
	end
	phone = phone:gsub("^550", "55")
	if #phone == 13 and phone:sub(5, 5) == "9" then
		phone = phone:sub(1, 4) .. phone:sub(6, -1)
	end
	return #phone == 12 and phone or ""
end

function phone_encode(phone)
	-- Somente números decodificados
	if #phone ~= 12 then return "" end
	if tonumber(phone:sub(5, 5)) <= 5 then -- fixo
		--return string.format("+%s (%s) %s-%s", phone:match("(%d%d)(%d%d)(%d%d%d%d)(%d%d%d%d)"))
		return string.format("(0%s) %s-%s", phone:match("%d%d(%d%d)(%d%d%d%d)(%d%d%d%d)"))
	else -- móvel
		--return string.format("+%s (%s) 9%d-%d", phone:match("(%d%d)(%d%d)(%d%d%d%d)(%d%d%d%d)"))
		return string.format("(0%s) 9%s-%s", phone:match("%d%d(%d%d)(%d%d%d%d)(%d%d%d%d)"))
	end
end

function capital(w)
	local l = {["da"]=true, ["de"]=true, ["do"]=true, ["dos"]=true, ["e"]=true}
	w = w:lower()
	if l[w] then return w end
	return w:sub(1, 1):upper() .. w:sub(2, -1)
end

-- TODO: enviar para functions
function convert(date)
	local t = { }
	t.day, t.month, t.year = date:match("(%d%d?)[./-](%d%d?)[./-](%d%d%d%d)")
	if not t.day then
		t.day, t.month, t.year = date:match("(%d%d?)[./-](%d%d?)[./-](%d%d)")
		if not t.day or not t.month or not t.year then
			return os.date("%Y-%m-%d")
		end
		t.year = t.year + 2000
	end
	return os.date("%Y-%m-%d", os.time(t))
end

function deadline(date, lasttime)
	local t = { }
	t.year, t.month, t.day = date:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
	t.day = t.day + lasttime
	return os.date("%d/%m/%Y", os.time(t))
end

-- TODO ignorar excluidos
function simples(ret)
	local h = io.open("//MMT24043101/Users/84292270/Posta_Restante/Posta Restante.csv", "r")
	if h then
		for line in h:lines() do
			line = line:upper():gsub("–", "-"):gsub(",*$", ""):gsub("%s$", "")
			if line ~= "" then
				local t = csv.from(line)
				if type(t) == "table" and type(t[1]) == "string" and type(t[2]) == "string" and type(t[3]) == "string" and type(t[4]) == "string" and type(t[5]) == "string" then
					local name    = t[4]:gsub("^[%A]+", ""):gsub("[%A]+$", ""):gsub("%f[%a]%a-%f[%A]", capital)
					local phone   = phone_decode(t[5])
					local date    = convert(t[2])
					if name ~= "" and phone ~= "" and not (day and day ~= date) then
						table.insert(ret, {
							heading  = string.format("%s - %s - %s", t[3], t[4], t[1]),
							name     = name,
							fname    = name:gsub("[\\/:*?\"<>|]", "~"),
							phone    = phone,
							cell     = "",
							date     = date,
							deadline = deadline(date, 20),
							lock     = string.format("%s-%s-%s", date, t[3], name:gsub("[\\/:*?\"<>|]", "~")),
							origin   = "simples",
						})
					end
				end
			end
		end
		h:close()
	end
end

function sro(ret)
	local dsuffix = fun.lastdata()
	if dsuffix then
		fun.dofile("data/ready.lua")
		if dsuffix ~= fun.data.ready then
			dsuffix = fun.prevdata()
		end
		fun.dofile(string.format("data/srodata-%s.lua", dsuffix))
	else
		fun.data.srodata = { }
		fun.data.ldidata = { }
		fun.data.ready   = ""
	end
	for i,v in ipairs(fun.data.srodata) do
		repeat
			if v.LTD_HITUNITCEP ~= ucep then break end
			if not v.CS_NAME or v.CS_NAME == "" then break end
			local name = v.CS_NAME:gsub("^[%A]+", ""):gsub("[%A]+$", ""):gsub("%f[%a]%a-%f[%A]", capital)
			if name == "" then break end
			local phone = phone_decode(v.CS_PHONENUMBER)
			local cell = phone_decode(v.CS_CELLNUMBER)
			if only and phone == "" and cell == "" then break end
			local date = v.LTD_CREATETIME:sub(1, 10)
			if day and day ~= date then break end
			local lasttime = v.LTD_LASTTIME
			if lattime == "" or lasttime == "0" or lasttime == 0 then
				local default = {
					{"^A" , 20},
					{"^BF",  7},
					{"^B" , 20},
					{"^C" , 20},
					{"^D" ,  7},
					{"^E" ,  7},
					{"^F" , 20},
					{"^I" , 20}, -- ???
					{"^J" , 20},
					{"^LA",  7},
					{"^LB",  7}, -- Internacional 20, nacional 7
					{"^LP",  7},
					{"^LS",  7},
					{"^LV",  7},
					{"^L" , 20},
					{"^MH", 20},
					{"^M" ,  7},
					{"^N" , 20},
					{"^O" ,  7},
					{"^P" ,  7}, -- Reembolso postal PR (ainda existe) Passaporte PA e PF ???
					{"^R" , 20},
					{"^S" ,  7},
					{"^T" , 20}, -- Teste
					{"^V" , 20},
					{"^X" , 20}, -- ???
				}
				if v.LTD_ITEMCODE ~= "BR" then
					lasttime = 20
				else
					for i, v in pairs(default) do
						if v.LTD_ITEMCODE:match(v[1]) then
							lasttime = v[2]
							break
						end
					end
				end
			end
			table.insert(ret, {
				heading = string.format("%s - %s", v.CS_NAME, v.LTD_ITEMCODE),
				name     = name,
				fname    = name:gsub("[\\/:*?\"<>|]", "~"),
				phone    = phone,
				cell     = cell,
				date     = date,
				deadline = deadline(date, lasttime),
				lock     = v.LTD_ITEMCODE,
				origin   = v.LTD_ITEMCODE:match("BR$") and "nacional" or "internacional"
			})
		until true
	end
end

local ret = { }
simples(ret)
sro(ret)

local first = true
for i,v in pairs(ret) do
	if not exists(v.lock) then
		touch(v.lock)
		if fisrt then
			mg.write('\t<h2>[ <a href="#', i, '">Próximo</a> ]</h2>')
			first = false
		end
		mg.write("\t<h1 id=", i, ">", v.heading, "</h1>\n")
		mg.write('\t<div class="qrcode">\n')
		local fmt = '\t\t<div class="%s"><img src="img/%s.svg"></div>\n'
		if qrencode(v.fname, v.name) then
			mg.write(string.format(fmt, "new", v.fname))
		else
			mg.write(string.format(fmt, "old", v.fname))
		end
		local vcard = "BEGIN:VCARD\nVERSION:3.0\nFN:C - %s\nTEL;TYPE=CELL:%s\nNOTE:Origem: Encomenda %s\nEND:VCARD\n"
		if phone ~= "" and cell ~= "" then
			vcard = "BEGIN:VCARD\nVERSION:3.0\nFN:C - %s\nTEL;TYPE=CELL:%s\nTEL;TYPE=CELL:%s\nNOTE:Origem: Encomenda %s\nEND:VCARD\n"
			vcard = string.format(vcard, v.name, phone_encode(v.phone), phone_encode(v.cell), v.origin)
		else
			if phone ~= "" then
				vcard = string.format(vcard, v.name, phone_encode(v.phone), v.origin)
			end
			if cell ~= "" then
				vcard = string.format(vcard, v.name, phone_encode(v.cell), v.origin)
			end
		end
		if phone ~= "" or cell ~= "" then
			if qrencode(v.fname .. "vcf", vcard) then
				mg.write(string.format(fmt, "new", v.fname .. "vcf"))
			else
				mg.write(string.format(fmt, "old", v.fname .. "vcf"))
			end
		else
			if exists(v.fname .. "vcf") then
				mg.write(string.format(fmt, "old", v.fname .. "vcf"))
			else
				mg.write('\t\t<div class="empty"></div>\n')
			end
		end
		local msg = "%s? %s! Eu trabalho nos Correios. Tem uma encomenda para você. Precisa vir buscar aqui na agência. O prazo é até dia %s. Se você precisar que outra pessoa retire para você, precisa de uma autorização por escrito e cópia ou original da sua identidade."
		msg = string.format(msg, v.name, tonumber(os.date("%H")) < 12 and "Bom dia" or "Boa tarde", v.deadline)
		if phone ~= "" then
			if qrencode(v.fname .. v.date, string.format("https://api.whatsapp.com/send?phone=%s&text=%s",
				v.phone, mg.url_encode(msg))) then
				mg.write(string.format(fmt, "click", v.fname .. v.date))
			else
				mg.write(string.format(fmt, "old", v.fname .. v.date))
			end
		else
			if qrencode(v.name .. v.date, msg) then
				mg.write(string.format(fmt, "new", v.fname .. v.date))
			else
				mg.write(string.format(fmt, "old", v.fname .. v.date))
			end
		end
		mg.write('\t</div>\n')
	end
end

mg.write([[
</body>
</html>
]])