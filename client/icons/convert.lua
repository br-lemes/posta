
local iup = require("iuplua")

local arq = io.open("../icons.lua", "w")
arq:write('\nlocal iup = require("iuplua")\nlocal ico = { }\n\n')

local function convert(name)
	dofile(name)
	name = name:sub(1, -5)
	local ico = _G["load_image_" .. name .. "_png"]()
	arq:write(string.format("ico.%s = iup.imagergba {\n\twidth  = %d,\n\theight = %d,\n\tpixels = {",
		name, ico.width, ico.height))
	local count = 0
	for i, v in ipairs(ico.pixels) do
		if count == 0 then
			arq:write("\n\t\t")
		end
		count = count + 1
		if count == tonumber(ico.width) * 4 then count = 0 end
		arq:write(string.format("%3d,%s", v, count == 0 and "" or " "))
	end
	arq:write("\n\t}\n}\n")
end

for _, v in ipairs(arg) do
	convert(v)
	arq:write("\n")
end

arq:write("return ico\n")
arq:close()
