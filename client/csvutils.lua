
local csv = { }

function csv.from(s)
	if s:sub(-1, -1) ~= ',' then s = s .. ',' end
	local t = { }
	local fieldstart = 1
	repeat
		-- next field is quoted? (start with `"'?)
		if s:find('^"', fieldstart) then
			local c
			local i  = fieldstart
			repeat
				-- find closing quote
				_, i, c = s:find('"("?)', i + 1)
			until c ~= '"' -- quote not followed by quote?
			if not i then error('unmatched "') end
			local f = s:sub(fieldstart + 1, i - 1)
			table.insert(t, (f:gsub('""', '"')))
			fieldstart = s:find(',', i) + 1
		else -- unquoted; find next comma
			local nexti = s:find(',', fieldstart)
			table.insert(t, s:sub(fieldstart, nexti - 1))
			fieldstart = nexti + 1
		end
	until fieldstart > #s
	return t
end

local function escape(s)
	if s:find('[,"]') then
		s = '"' .. s:gsub('"', '""') .. '"'
	end
	return s
end

function csv.to(t)
	local s = ""
	for _,p in ipairs(t) do
		s = s .. "," .. escape(p)
	end
	return string.sub(s, 2) -- remove first comma
end

return csv
