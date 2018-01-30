-- Base64-decoding
-- Sourced from http://en.wikipedia.org/wiki/Base64
-- Author Daniel Lindsley
-- License BSD https://github.com/toastdriven/lua-base64

local index_table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function to_binary(integer)
	local remaining = tonumber(integer)
	local bin_bits = ''

	for i = 7, 0, -1 do
		local current_power = math.pow(2, i)

		if remaining >= current_power then
			bin_bits = bin_bits .. '1'
			remaining = remaining - current_power
		else
			bin_bits = bin_bits .. '0'
		end
	end

	return bin_bits
end

local function from_binary(bin_bits)
	return tonumber(bin_bits, 2)
end


local function from_base64(to_decode)
	local padded = to_decode:gsub('%s', '')
	local unpadded = padded:gsub('=', '')
	local bit_pattern = ''
	local decoded = ''

	for i = 1, #unpadded do
		local char = to_decode:sub(i, i)
		local offset, _ = index_table:find(char)
		if offset == nil then
			error("Invalid character '" .. char .. "' found.")
		end

		bit_pattern = bit_pattern .. to_binary(offset-1):sub(3)
	end

	for i = 1, #bit_pattern, 8 do
		local byte = bit_pattern:sub(i, i+7)
		decoded = decoded .. string.char(from_binary(byte))
	end

	local padding_length = #padded-#unpadded

	if (padding_length == 1 or padding_length == 2) then
		decoded = decoded:sub(1,-2)
	end
	return decoded
end

return { decode = from_base64 }
