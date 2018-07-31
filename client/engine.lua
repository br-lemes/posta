
local fun = require("functions")
local csv = require("client.csvutils")
local eng = { }

function eng.convertdate(date)
	local t = { }
	t.day, t.month, t.year = date:match("(%d%d?)[./-](%d%d?)[./-](%d%d%d%d)")
	if not t.day then
		t.day, t.month, t.year = date:match("(%d%d?)[./-](%d%d?)[./-](%d%d)")
		if not t.day or not t.month or not t.year then
			return nil
		end
		t.year = t.year + 2000
	end
	return os.date("%Y-%m-%d", os.time(t))
end

function eng.late(date, lasttime, today)
	local t = { }
	t.day, t.month, t.year = date:match("(%d%d?)[./-](%d%d?)[./-](%d%d%d%d)")
	if not t.day then
		t.day, t.month, t.year = date:match("(%d%d?)[./-](%d%d?)[./-](%d%d)")
		if not t.day or not t.month or not t.year then
			return true
		end
		t.year = t.year + 2000
	end
	t.day = t.day + lasttime
	if today then
		return os.date("%Y-%m-%d") >= os.date("%Y-%m-%d", os.time(t))
	else
		return os.date("%Y-%m-%d") > os.date("%Y-%m-%d", os.time(t))
	end
end

function eng.load()
	local dsuffix = fun.lastdata()
	fun.dofile("srodata", dsuffix)
	fun.dofile("ldidata", dsuffix)
	eng.delete = { }
	eng.simple = { }
	local arq = io.open("data/delete.csv", "r")
	if arq then
		for line in arq:lines() do
			eng.delete[line:upper():gsub("–", "-"):gsub(",*$", "")] = true
		end
		arq:close()
	end
	arq = io.open("Posta Restante.csv", "r")
	if not arq then return dsuffix end
	for line in arq:lines() do
		line = line:upper():gsub("–", "-"):gsub(",*$", "")
		if line ~= "" and not eng.delete[line] and line ~= "TIPO,DATA,ORDEM,NOME" then
			local t = csv.from(line)
			if type(t) == "table" and type(t[1]) == "string" and type(t[2]) == "string" and type(t[3]) == "string" and type(t[4]) == "string" and t[4] ~= "" then
				if t[3]:find("1%d[. ]?%d%d%d") or t[1]:find("VOL") then
					t.OBJ_TYPE = "volume"
				elseif t[3]:find("2%d[. ]?%d%d%d") or t[1] == "SEDEX" then
					t.OBJ_TYPE = "envsed"
				elseif t[3]:find("3%d[. ]?%d%d%d") or t[1] == "SEED" then
					t.OBJ_TYPE = "envreg"
				elseif t[3]:find("4%d[. ]?%d%d%d") or t[1]:find("CAIXETA") or t[1]:find("CAIXA") or t[1]:find("CX") then
					t.OBJ_TYPE = "intern"
				elseif t[3]:find("5%d[. ]?%d%d%d") or t[1]:find("COBRAR") then
					t.OBJ_TYPE = "cobrar"
				else
					t.OBJ_TYPE = "simple"
				end
				table.insert(eng.simple, t)
			end
		end
	end
	arq:close()
	return dsuffix
end

function eng.upper(pattern, brackets)
	--string.find('sanity check', pattern)
	local tmp = {}
	local i = 1
	while i <= #pattern do              -- 'for' don't let change counter
		local char = pattern:sub(i, i)  -- current char
		if char == '%' then
			tmp[#tmp+1] = char          -- add to tmp table
			i = i+1                     -- next char position
			char = pattern:sub(i, i)
			tmp[#tmp+1] = char
			if char == 'b' then         -- '%bxy' - add next 2 chars
				tmp[#tmp+1] = pattern:sub(i+1, i+2)
				i= i+2
			end
		elseif char == '[' then         -- brackets
			tmp[#tmp+1] = char
			i = i+1
			while i <= #pattern do
				char = pattern:sub(i, i)
				if char == '%' then     -- no '%bxy' inside brackets
					tmp[#tmp+1] = char
					tmp[#tmp+1] = pattern:sub(i+1, i+1)
					i = i+1
				elseif char:match("%a") then    -- letter
					tmp[#tmp+1] = not brackets and char or char:upper()
				else                            -- something else
					tmp[#tmp+1] = char
				end
				if char == ']' then break end   -- close bracket
				i = i+1
			end
		elseif char:match("%a") then    -- letter
			tmp[#tmp+1] = char:upper()
		else
			tmp[#tmp+1] = char          -- something else
		end
		i=i+1
	end
	return table.concat(tmp)
end

function eng.check_options(options)
	if type(options) == "string" then
		local temp = options
		options = { }
		options.search = temp
	elseif type(options) ~= "table" then
		options = { }
	end
	if type(options.search) == "string" then
		options.search = eng.upper(options.search, true)
	else
		options.search = ""
	end
	if options.outros == nil then options.outros = true end
	if options.envreg == nil then options.envreg = true end
	if options.envsed == nil then options.envdex = true end
	if options.simple == nil then options.simple = true end
	if options.cobrar == nil then options.cobrar = true end
	if options.intern == nil then options.intern = true end
	if options.volume == nil then options.volume = true end
	-- options.postal == nil é o mesmo que false
	options.sby    = options.sby   or 2
	options.unit   = options.unit  or "78455970" -- custom
	options.order  = options.order or "CS_NAME"
	return options
end

function eng.search(options)
	local r = { }
	options = eng.check_options(options)
	if options.sby == 1 then -- LDI
		for k,v in pairs(fun.data.ldidata) do
			local a, b
			a, b = pcall(string.find, k, options.search)
			if a and b and v[1].LTD_HITUNITCEP == options.unit then
				table.insert(r, k)
			end
		end
		table.sort(r)
	else
		for _,v in ipairs(fun.data.srodata) do
			local a, b, c
			if options.search:find("^AR%d%d%d%d%d%d%d%d%d%a%a$") then
				a, b = pcall(string.find, v.LTD_ITEMCODE, options.search:gsub("^AR(%d%d%d%d%d%d%d%d%d)%a%a$", "%%a%%a%1%%a%%a"))
			elseif options.search:find("^%a%a%d%d%d%d%d%d%d%d%d%a%a$") then
				a, b = pcall(string.find, v.LTD_ITEMCODE, options.search)
			elseif options.search:find("^%d%d%d%d%d%d%d%d%d%d%d%d$") then
				options.order = "LTD_GROUPNUMBER"
				a, b = pcall(string.find, v.LTD_ID, options.search)
			elseif options.sby == 2 then -- Nome
				a, b = pcall(string.find, v.CS_NAME, options.search)
			elseif options.sby == 3 then -- Comentário
				a, b = pcall(string.find, v.LTD_COMMENT, options.search)
			elseif options.sby == 4 then -- Código
				a, b = pcall(string.find, v.LTD_ITEMCODE, options.search)
			end
			if not options.late then
				c = true
			else
				local duedate = os.date("%Y-%m-%d", os.time()-v.LTD_LASTTIME*24*60*60)
				if options.ltoday then
					c = v.LTD_CREATETIME:sub(1, 10) <= duedate
				else
					c = v.LTD_CREATETIME:sub(1, 10) < duedate
				end
			end
			if a and b and c and v.LTD_HITUNITCEP == options.unit then
				if v.OBJ_TYPE == "outros" and options.outros then
					table.insert(r, v)
				elseif v.OBJ_TYPE == "envreg" and options.envreg then
					table.insert(r, v)
				elseif v.OBJ_TYPE == "envsed" and options.envsed then
					table.insert(r, v)
				elseif v.OBJ_TYPE == "intern" and options.intern then
					table.insert(r, v)
				elseif v.OBJ_TYPE == "volume" and options.volume then
					table.insert(r, v)
				elseif v.OBJ_TYPE == "postal" and options.postal then
					table.insert(r, v)
				elseif v.OBJ_TYPE == "cobrar" and options.cobrar then
					table.insert(r, v)
				end
			end
		end
		for _,v in ipairs(eng.simple) do
			local a, b, c
			if not options.late then
				c = true
			else
				c = eng.late(v[2], 20, options.ltoday)
			end
			if options.sby == 2 then -- Nome
				a, b = pcall(string.find, v[4], options.search)
			elseif options.sby == 4 then -- Número
				a, b = pcall(string.find, v[3], options.search)
			end
			if a and b and c then
				if v.OBJ_TYPE == "simple" and options.simple then
					table.insert(r, v)
				elseif v.OBJ_TYPE == "envreg" and options.envreg then
					table.insert(r, v)
				elseif v.OBJ_TYPE == "envsed" and options.envsed then
					table.insert(r, v)
				elseif v.OBJ_TYPE == "intern" and options.intern then
					table.insert(r, v)
				elseif v.OBJ_TYPE == "volume" and options.volume then
					table.insert(r, v)
				elseif v.OBJ_TYPE == "cobrar" and options.cobrar then
					table.insert(r, v)
				end
			end
		end
		if options.late then
			table.sort(r, eng.sortlate)
		elseif options.order == "CS_NAME" then
			table.sort(r, eng.sortname)
		elseif options.order == "LTD_GROUPNUMBER" then
			table.sort(r, eng.sortgnum)
		end
	end
	return r
end

function eng.sortlate(a, b)
	if a.LTD_ID and b.LTD_ID then
		if a.LTD_ID < b.LTD_ID then
			return true
		elseif a.LTD_ID > b.LTD_ID then
			return false
		elseif a.LTD_GROUPNUMBER < b.LTD_GROUPNUMBER then
			return true
		elseif a.LTD_GROUPNUMBER > b.LTD_GROUPNUMBER then
			return false
		end
	elseif a.LTD_ID and not b.LTD_ID then
		return true
	elseif not a.LTD_ID and b.LTD_ID then
		return false
	elseif not a.LTD_ID and not b.LTD_ID then
		local date_a = eng.convertdate(a[2])
		local date_b = eng.convertdate(b[2])
		if date_a and not date_b then
			return true
		elseif not date_a and not date_b then
			return true
		elseif not date_a and date_b then
			return false
		elseif date_a < date_b then
			return true
		elseif date_a > date_b then
			return false
		else
			return a[3] < b[3]
		end
	end
end

function eng.sortname(a, b)
	local comp_a = a.CS_NAME or a[4]
	local comp_b = b.CS_NAME or b[4]
	comp_a = comp_a:match("^%A*(.*)") or comp_a
	comp_b = comp_b:match("^%A*(.*)") or comp_b
	return (comp_a or a.CS_NAME) < (comp_b or b.CS_NAME)
end

function eng.sortgnum(a, b)
	return a.LTD_GROUPNUMBER < b.LTD_GROUPNUMBER
end

return eng
