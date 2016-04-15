----------------------------------
-- GUS
-- That's the main character.
----------------------------------

Gus = {
	imgfile = "assets/img/Gus.png",
	x = GUS_INITIAL_POSITION_X,	-- Gus' position on x-axis (initial position. Will be updated in the course of the game)
	y = GUS_INITIAL_POSITION_Y,	-- Gus' position on y-axis.
	step_size = GUS_STEP_SIZE_MAX,	-- Gus' step size. By default, max size. Will be updated.
	moveRandomly = false,	-- Is Gus moving randomly?
	vigor = GUS_VIGOR_MAX,	-- Initial value of Gus' vigor (by default, it's max)
	sociability = GUS_SOCIABILITY_MAX,		-- Initial value of Gus' sociability
	movement = {		-- Will store all the methods/variables dedicated to movement.
		currentDirection = nil,
	},
	memory = {		-- All the relevant information retrieved by Gus
		npcs = {},
	},
	interaction = {			-- Everything related to interactions that Gus can start with NPCs
		state = false,			-- Is Gus currently interacting with an NPC?
		npcIdentity = nil,			-- Identity of the NPC he's interacting with (the NPC instance)
	},
	label = "Gus",		-- String representation of Gus's name
}

Gus.movement.randomMoving = {
	desireToTurn = 0,
	maxDesireToTurn = GUS_DESIRE_TO_TURN_MAX,	-- Maximum number of steps before Gus wants to select a new direction (in random move mode)
	directions = {DIRECTION_LEFT, DIRECTION_RIGHT, DIRECTION_UP, DIRECTION_DOWN},
	journeyLength = 0,	-- Every time Gus takes a step, it'll increment by 1.
	currentdirection = nil,
}

function Gus.movement:selectNewDirection()
	-- Select the new direction randomly and return it
	rand = math.random(1,4)
	direction = Gus.movement.randomMoving.directions[rand]
	Gus.movement.randomMoving.currentdirection = direction
	return direction
end

function Gus.movement.randomMoving.resetDesireToTurn()
	-- Gus has turned, reset the desire to turn
	Gus.movement.randomMoving.desireToTurn = 0
	Gus.movement.randomMoving.currentdirection = nil
end

function Gus.movement.randomMoving.setDesireToTurn()
	-- Increase the desire to turn by a random value [0-1]
	Gus.movement.randomMoving.desireToTurn = Gus.movement.randomMoving.desireToTurn + math.random()
	if Gus.movement.randomMoving.desireToTurn > Gus.movement.randomMoving.maxDesireToTurn then
		Gus.movement.randomMoving.resetDesireToTurn()
	end
end

-- Gus tries to move to the next (x,y) position.
-- Out: true if Gus has successfully moved, false otherwise
function Gus.movement.move(next_x, next_y)

	-- Reset any previous interaction info
	Gus.interaction.npcIdentity = nil

	-- Check if Gus will still be inside the room if he takes this next step:
	if inner_room:IsPositionInside(Gus.img:getHeight(), Gus.img:getWidth(), next_x, next_y) then

		-- If Gus is close to any of the NPCs, it'll set Gus in Interaction mode.
		for _, npc in ipairs(NPC_group) do
			if npc.area:IsAreaTouched(Gus.img:getHeight(), Gus.img:getWidth(), next_x, next_y) then
				-- Setting this variable to true will impact love.update() (in main.lua)
				-- Gus isn't allowed to move as long as it's set to true
				Gus.interaction.state = true
				Gus.interaction.npcIdentity = npc
				-- Manage the interaction: some information may be added to Gus' memory in the course of the interaction
				Gus.manageInteraction()
				return false
			end
		end

		Gus.x = next_x
		Gus.y = next_y
		Gus.updateVigor()
		Gus.updateSociability()
		status_board.UpdateContent()
		return true
	end
	return false
end

function Gus.movement.random(dt)
-- Each time it's called, Gus will make a random move.

	local r

	-- If Gus' desire to turn is below a certain threshold, Gus will move forward.
	if Gus.movement.randomMoving.desireToTurn <= Gus.movement.randomMoving.maxDesireToTurn then
		-- If there's no current direction set, select a new one.
		if Gus.movement.randomMoving.currentdirection == nil then
			Gus.movement.currentDirection = Gus.movement.selectNewDirection()
		else
			-- Move forward according to the current direction, taking into account the room's walls.
			if Gus.movement.currentDirection == DIRECTION_LEFT then
				r = Gus.movement.move(Gus.x - (Gus.step_size*dt), Gus.y)
			elseif Gus.movement.currentDirection == DIRECTION_RIGHT then
				r = Gus.movement.move(Gus.x + Gus.step_size*dt, Gus.y)
			elseif Gus.movement.currentDirection == DIRECTION_UP then
				r = Gus.movement.move(Gus.x, Gus.y - (Gus.step_size*dt))
			elseif Gus.movement.currentDirection == DIRECTION_DOWN then
				r = Gus.movement.move(Gus.x, Gus.y + (Gus.step_size*dt))
			end
			-- If Gus has successfully moved (i.e. the step he wanted to take didn't take him
			-- through the room's walls), then we update his desire to turn, else we make him select a new direction.
			if r then Gus.movement.randomMoving.setDesireToTurn() else Gus.movement.randomMoving.resetDesireToTurn() end
		end
	end
end

function Gus.movement.keyboard(dt)
-- Selects the correct parameters for Gus' moves according to
-- the key that's being pressed.

	if love.keyboard.isDown(unpack(SHORTCUT_MOVEUP)) then
		Gus.movement.move(Gus.x, Gus.y - (Gus.step_size*dt))
	elseif love.keyboard.isDown(unpack(SHORTCUT_MOVEDOWN)) then
		Gus.movement.move(Gus.x, Gus.y + (Gus.step_size*dt))
	end
	if love.keyboard.isDown(unpack(SHORTCUT_MOVERIGHT)) then
		Gus.movement.move(Gus.x + Gus.step_size*dt, Gus.y)
	elseif love.keyboard.isDown(unpack(SHORTCUT_MOVELEFT)) then
		Gus.movement.move(Gus.x - (Gus.step_size*dt), Gus.y)
	end

end

-- Update the Vigor of Gus
-- May have to be generalized to deal with different dimensions
function Gus.updateVigor()
	-- Constrain the value between the min and max
	Gus.vigor = keepBetweenMinMax(round(Gus.vigor,3) - GUS_VIGOR_STEP, GUS_VIGOR_MIN, GUS_VIGOR_MAX)
	-- Update Gus' speed accordingly
	Gus.updateStepSize()
end

function Gus.updateSociability()
	Gus.sociability = keepBetweenMinMax(round(Gus.sociability,3) - 0.1, GUS_SOCIABILITY_MIN,GUS_SOCIABILITY_MAX)
end

-- Updates the size of the steps Gus takes (representation of his speed)
function Gus.updateStepSize()
	Gus.step_size = norm(Gus.vigor, GUS_VIGOR_MIN, GUS_VIGOR_MAX, GUS_STEP_SIZE_MIN, GUS_STEP_SIZE_MAX)
end



function Gus.manageInteraction()
	npc = Gus.interaction.npcIdentity

	-- If an entry exists for this NPC, it means Gus has already met it
	if Gus.memory.npcs[npc.label] then
		-- This isn't the first interaction anymore

		Gus.memory.npcs[npc.label]["first_met"] = false

		local alreadyKnownName,_ = Gus.memory.retrieveInfo(Gus.memory.npcs[npc.label], "name")

		if alreadyKnownName == true then
			--meet the second time when knowing npc's name
			Gus.interaction.initiateDialogue(dialogue_meet_again)
		else
			--meet the second time and ask for the name again
			Gus.interaction.initiateDialogue(dialogue_ask_for_name_again)
		end

	else
		-- Creation of an array for this NPC is Gus' memory:
		Gus.memory.npcs[npc.label] = {}
		-- This is the first interaction:
		Gus.memory.npcs[npc.label]["first_met"] = true
		print(Gus.memory.npcs[npc.label]["first_met"])
		-- Gus tries to get the NPC name through a dialogue:
		Gus.interaction.initiateDialogue(dialogue_ask_for_name, npc)



	end
	-- Update the content of the status board (so that any new change will be reflected)

	if npc.quest ~= nil then
     if not npc.quest:checkCompletion(npc) then
      	npc.quest:startQuest(npc)
      end
	end
	status_board.UpdateContent()
end

-- Start the given dialogue with the given npc.
-- Start a dialogue with this function, rather than directly with Dialogue_manager.startDialogue,
-- because in the initiateDialogue function you will manage Gus' desire to truly start the dialogue.
function Gus.interaction.initiateDialogue(dialogue, npc)
	npc = Gus.interaction.npcIdentity
	Dialogue_manager.startDialogue(dialogue, npc)
end

-- Add data to Gus' memory. Call this any time Gus has learnt something, otherwise it'll be lost!
-- In: a domain (string) which represents the area of knowledge, and some data (table, string, number...)
function Gus.memory.addInfo(domain, data)
	-- Add a case for each domain (data won't always be represented in a same structure type)
	if domain == "NPCs" then
		-- data should be something like {"NPC4", "name", "NPC4"}
		npc_label, tag, value = unpack(data)
		if not Gus.memory.npcs[npc_label] then Gus.memory.npcs[npc_label] = {} end
		Gus.memory.npcs[npc_label][tag] = value
	end

	-- Always update the status board to possibly reflect the new changes
	status_board.UpdateContent()
end

-- Retrieve an information from Gus' memory. The content of this function may have to be changed in the future.
-- In: an object from Gus' memory, and its tag
-- Out: true & value of the element (if the element is present in memory), or false & nil
function Gus.memory.retrieveInfo(object, tag)
	if object[tag] then
		return true, object[tag]
	else
		return false, nil
	end
end


-- gus will guess the profile of the npc by his sentence
function Gus.interaction.guessProfile(answer_sentence)
	local profile_guessed
	if string.match(answer_sentence, "chou") ~= nil then
		profile_guessed = "charmer"
	elseif string.match(answer_sentence, "distingue") ~= nil then
		profile_guessed = "arrogant"
	elseif string.match(answer_sentence, "con") ~= nil then
		profile_guessed = "agressive"
	elseif string.match(answer_sentence, "Enchante") ~= nil then
		profile_guessed = "timide"
	end
	print("profile_guessed is ")
	print(profile_guessed)
	return profile_guessed
end
