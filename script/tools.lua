-----------------------------------
-- TOOLS
-- Several common useful functions
-- Edit at your will!
----------------------------------

-- Safely opens a file
-- In: filename (str), opening mode (str)
-- Out: handle or nil
function safeopen(filename, mode)
	if DEBUG_MODE then print (filename, mode) end
	if pcall(io.open(filename, mode)) then
		return (io.open(filename, mode))
	end
	print ("Couldn't open file named "..tostring(filename))
	return nil
end

-- Checks whether the table is a hash (list of pairs key->value) or a table indexed with integers
-- In: table
-- Out: true if it's a hash, false otherwise
function isAssociativeArray(t)
	local i = 0
	for _ in pairs(t) do
		i = i + 1
		if t[i] == nil then return false end
	end
	return true
end

-- Prints correctly the data contained in a variable, whatever its type
-- In: any printable variable
-- Out: no return value. Prints the variable content (or variable type if the type isn't listed)
function tprint (item)
	if type(item) == "string" or type(item) == "number" or type(item) == "boolean" or type(item) == "nil" then
		print (item)
	elseif type(item) == "table" then
		if isAssociativeArray(item) then
			for i, v in ipairs(item) do
				print (i, v)
			end
		else
			for i, v in pairs(item) do
				print (i, v)
			end
		end
	else
		print (item, ": type is "..type(item))
	end
end

-- Printing for debugging mode
-- In: any printable item
-- Out: no return value. Only a print.
function dprint (s)
	if DEBUG_MODE then tprint (s) end
end

-- Constrain a value between a min and a max
-- In: (numbers) value to constrain, minimum value, maximum value
-- Out: value constrained between min and max
function keepBetweenMinMax(x, mini, maxi)
	if x<mini then
		return mini
	elseif x >maxi then
		return maxi
	else
		return x
	end
end

-- Round to x decimals
-- Int: number[, number of decimals]
-- Out: rounded number
function round(num, nb_decimals)
	local mult = 10^(nb_decimals or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- Checks whether a table contains an element or not
-- In: table, element to look for
-- Out: true if table contains this element, false otherwise
function table.contains(t, item)
	for _, v in pairs(t) do
		if v == item then
			return true
		end
	end
	return false
end

-- Get a normalized value
-- In: original value (number), minimum of the origin interval, maximum of the origin interval, minimum of the target interval, maximum of the target interval
-- Out: normalized value (number)
function norm(origin_val, origin_min, origin_max, target_min, target_max)
	norm_value = (origin_val - origin_min) * (target_max - target_min) / (origin_max - origin_min) + target_min
	return norm_value
end

-- Iterator through ordered keys
-- (http://www.lua.org/pil/19.3.html)
function pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end

-- Splits a string into an array
-- In: sentence to split (string)
-- Out: array containing each string
function split(s)
	local l = {}
	-- for i in string.gmatch(s, "%S+") do
	for i in string.gmatch(s, "[^ ]+") do
		table.insert(l, i)
	end
	return l
end


-- Splits a string into an array containing words
-- This function is a bit more NLP-ish than split(),
-- In: sentence to split (string)
-- Out: array containing each word
function parseSentence(s)

	accent_list = "ÀÂÄÇÉÈÊËÎÏÔÖÙÛÜŸÆŒàâäçéèêëîïôöùûüÿæœ"

	l = {
		{"aujourd", "hui", "aujourd'hui"},
		{"rendez", "vous", "rendez-vous"},
	}
	local words = {}
	local r = ""
	local expected_word_data = nil

	for w in string.gmatch(s, "[aA-zZ"..accent_list.."]+") do
		w = string.lower(w)
		if expected_word_data then
			if expected_word_data[2] == w then
				r = r .. "|" .. expected_word_data[3]
				table.insert(words, expected_word_data[3])
			end
			expected_word_data = nil
		else
			for i, v in ipairs(l) do
				if v[1] == w then
					expected_word_data = v
				end
			end
			if not expected_word_data then
				r = r .. "|" .. w
				table.insert(words, w)
			end
		end
	end

	print (r)
	return words
end
