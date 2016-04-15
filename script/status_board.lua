status_board = {
	font = nil;	-- The font object that'll be used for printing info
	fontInfo = {"assets//font//Gravity-Book.otf", 16};
	color_mode = STATUS_BOARD_REGULAR_MODE;
	title = {
		x = 575;
		y = 30;
		content = BOARD_MESSAGE_GREETINGS;		-- That's the title that will be displayed
	};
	message = {
		x = 575;
		y = 80;
		content = "";			-- That's an additional message that will be displayed
	};
	dialogue = {
		font = nil;
		fontInfo = {"assets//font//Gravity-Book.otf", 12};
		x = 575;
		y = 200;
		content = {};				-- The dialogue history that'll be displayed
		board_speaker;
		line_spacing = 14;			-- Vertical space between the lines
		maximum_number_of_lines = 15;	-- Max number of displayed lines (vertical arrangement)
		maximum_characters_per_line = 35;	-- Max number of characters on a row (horizontal arrangement)
	};
	x = 560;
	y = 0;
	img = nil;
	imgfile = "assets/img/Status_Board.png";
}

-- Displays the title, message and dialogue of the status board
-- /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
-- This method is called for each tick of the draw thread:
-- don't update the status board contents here!
-- /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
function status_board.PrintContent()

	love.graphics.setFont(status_board.font)

	-- Select the font color for the title
	local color = STATUS_BOARD_REGULAR_MODE
	if status_board.color_mode == STATUS_BOARD_REGULAR_MODE then
		color = STATUS_BOARD_REGULAR_COLOR
	elseif status_board.color_mode == STATUS_BOARD_ALERT_MODE then
		color = STATUS_BOARD_ALERT_COLOR
	end
	love.graphics.setColor(unpack(color))

	-- Print the title
	local title = status_board.title
	love.graphics.print(title.content, title.x, title.y)

	-- Get back to the regular color for the message
	love.graphics.setColor(unpack(STATUS_BOARD_REGULAR_COLOR))

	-- Print the message
	local message = status_board.message
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print(message.content, message.x, message.y)

	-- Print dialogues
	local dialogue = status_board.dialogue
	love.graphics.setFont(dialogue.font)
	love.graphics.setColor(0, 0, 0, 255)
	for i, v in ipairs(dialogue.content) do
		love.graphics.print(v, dialogue.x, dialogue.y + i * dialogue.line_spacing)
	end

end

-- Updates what has to be printed on the board.
-- Should be called each time something relevant happens in
-- the context of the game.
-- When you call it, make sure it doesn't trigger for each
-- update of the game.
function status_board.UpdateContent()
	if not Gus.interaction.state then
	-- Gus isn't interacting with an NPC
	-- For now, we don't have much to print
		status_board.title.content = BOARD_MESSAGE_GREETINGS
		status_board.color_mode = STATUS_BOARD_REGULAR_MODE
		status_board.message.content = BOARD_MESSAGE_NO_DATA
	else
	-- Gus is interacting with an NPC
	-- We display everything we know about it
		status_board.title.content = BOARD_MESSAGE_NPC_ENCOUNTERED
		status_board.color_mode = STATUS_BOARD_ALERT_MODE

		status_board.message.content = status_board.getNPCdata()
	end
end

-- Cut dialogue sentences so that they don't go beyond
-- the right border of the screen.
-- Crop the first items of the dialogue sentences list, so
-- that only the x last ones appear on screen.
function status_board.dialogue.trimAndAdd(addition)

	local function cut_sentence(s)
		addition_array = split(s)
		local new_s = ""; local rest_s = ""; local addNewWords = true

		for i, word in ipairs(addition_array) do
			if string.len(new_s.." "..word) < status_board.dialogue.maximum_characters_per_line and addNewWords then
				new_s = new_s.." "..word
			else
				rest_s = rest_s.." "..word; addNewWords = false
			end
		end
		table.insert(status_board.dialogue.content, new_s)

		if string.len(rest_s) > 0 then
			cut_sentence(rest_s)
		end
	end
	cut_sentence(addition)

	-- Only display the last x lines on screen (x being the maximum_number_of_lines)
	if table.getn(status_board.dialogue.content) > status_board.dialogue.maximum_number_of_lines then
		table.remove(status_board.dialogue.content, 1)	-- This content is lost
	end
end

-- Updates the dialogue log with the new entry, in the format "[speaker] What the speaker said."
-- In: identity of the speaker (string), sentence pronounced (string)
function status_board.dialogue.addDialogue(speaker, sentence)
	local new_addition = "["..speaker.."] "..sentence
	status_board.dialogue.trimAndAdd(new_addition)
end

-- Retrieve information about the current NPC in Gus' memory
-- Out: a formatted string ready to be printed in the status_board message section
function status_board.getNPCdata()
	npc = Gus.interaction.npcIdentity
	if not npc then return "" end
	local result, v

	local s = "%s: %s\n%s: %s\n%s: %s\n%s: %s"

	-- If Gus has never met this NPC
	if not Gus.memory.npcs[npc.label] then
		npc_already_met = BOARD_MESSAGE_NO
		npc_identity = BOARD_MESSAGE_NO_DATA
		npc_profile = BOARD_MESSAGE_NO_DATA
		npc_quest_completed = BOARD_MESSAGE_NO
	else
		-- Retrieve if it's the first time Gus meets it
		result, value = Gus.memory.retrieveInfo(Gus.memory.npcs[npc.label], "first_met")

		if value then npc_first_met = BOARD_MESSAGE_YES else npc_first_met = BOARD_MESSAGE_NO end
		-- Retrieve the name of the NPC
		result, value = Gus.memory.retrieveInfo(Gus.memory.npcs[npc.label], "name")
		if result then npc_identity = value else npc_identity = BOARD_MESSAGE_NO_DATA end
		-- Retrieve the profile
		result, value = Gus.memory.retrieveInfo(Gus.memory.npcs[npc.label], "profile")
		if result then npc_profile = value else npc_profile = BOARD_MESSAGE_NO_DATA end
		-- Retrieve the state of the NPC quest
		result, value = Gus.memory.retrieveInfo(Gus.memory.npcs[npc.label], "quest_complete")
		if result then npc_quest_complete = BOARD_MESSAGE_YES else npc_quest_complete = BOARD_MESSAGE_NO end
	end

	s = s:format(BOARD_LABEL_FIRST_ENCOUNTER, npc_first_met, BOARD_LABEL_IDENTITY, npc_identity, BOARD_LABEL_PROFILE, npc_profile, BOARD_LABEL_QUEST_COMPLETED, npc_quest_complete)
	print("logging1")
	print(s)
	print("logging")
	return s
end
