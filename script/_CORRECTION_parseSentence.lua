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
