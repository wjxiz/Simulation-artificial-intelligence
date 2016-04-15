----------------------------------
-- Dialogue
----------------------------------

-- Dialogue manager :
-- A simple manager that deals with the start of a new dialogue,
-- and which is called regularly by the game .update(), if a dialogue is
-- currently running, to update the state of the dialogue.

-- Dialogue class :
-- Each instance of this class will run a specific list of states (of a finite state automaton),
-- each state being a function that'll add a new message to the dialogue taking place
-- between Gus and an NPC (according to criteria you'll set)


----------------------------------
-- Dialogue manager
----------------------------------

Dialogue_manager = {
	current_dialogue = {
		dialogue = nil;
		interlocutor = nil;
		next_state = nil;
	};
	current_state = {
		speaker = "";
	};
	message = DIALOGUE_INIT;
	queue = {};
}

function Dialogue_manager.addToQueue(dialogue, npc_label)
	-- add this dialogue to the queue
	table.insert(Dialogue_manager.queue, {dialogue, npc_label})
end

function Dialogue_manager.fetchFromQueue()
	-- returns the first element of the queue
	return Dialogue_manager.queue[1]
end

-- This function should not be called directly if you want to start a new dialogue
-- Call Gus.interaction.initiateDialogue(dialogue, npc) instead
function Dialogue_manager.startDialogue(dialogue, npc_label)
	-- Add this dialogue to the queue
	Dialogue_manager.addToQueue(dialogue, npc_label)
	-- Run the dialogue
	Dialogue_manager.runDialogue()
end

function Dialogue_manager.stop()
	-- The current dialogue is over, remove it from the queue
	table.remove(Dialogue_manager.queue, 1)
	-- Reinit the dialogue manager
	Dialogue_manager.current_dialogue.dialogue = nil
	Dialogue_manager.current_dialogue.interlocutor = nil
	Dialogue_manager.current_dialogue.next_state = nil
	Dialogue_manager.message = nil
end

function Dialogue_manager.runDialogue()
	local message, next_state
	local d = Dialogue_manager.current_dialogue

	if Dialogue_manager.current_dialogue.dialogue == nil then
	-- there is no current dialogue
		-- get the first dialogue in the queue
		local l = Dialogue_manager.fetchFromQueue()
		if l then
			dialogue, npc_label = unpack(l)
			
			Dialogue_manager.current_dialogue.dialogue = dialogue
			Dialogue_manager.current_dialogue.interlocutor = npc_label
			Dialogue_manager.current_dialogue.next_state = nil
			Dialogue_manager.message = DIALOGUE_INIT
			
			-- run the initial state of the dialogue
			message, next_state = d.dialogue:runState(d.dialogue.init_state)
			Dialogue_manager.message = message
			d.next_state = next_state
			Dialogue_manager.runDialogue()
		else
			-- if there's no dialogue left, reinit the dialogue manager
			Dialogue_manager.stop()
		end
	else
		-- If the message has been set to "NEXT", we run the next_state currently present in the dialogue manager:
		if Dialogue_manager.message == DIALOGUE_NEXT then
			message, next_state = d.dialogue:runState(d.next_state)
			Dialogue_manager.message = message
			d.next_state = next_state
			Dialogue_manager.runDialogue()
		-- If the message is "STOP", we stop the dialogue (we reinit the parameters of the dialogue manager)
		elseif Dialogue_manager.message == DIALOGUE_STOP then
			Dialogue_manager.stop()
		end
	end
end

----------------------------------
-- Dialogue class
----------------------------------

-- Each dialogue is an instance of the Dialogue class

Dialogue = {
	init_state = nil;
	isRunning = false;
}

function Dialogue:new (o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function Dialogue:runState(state_data)
	local message, next_state
	
	local func, speaker = unpack(state_data)
		
	-- If the speaker is an NPC, we retrieve its name, so as
	-- to display for example "[NPC4] Salut !" instead of "[NPC] Salut !"
	if speaker == NPC_LABEL then speaker = Dialogue_manager.current_dialogue.interlocutor.label end
	
	Dialogue_manager.current_state.speaker = speaker
	
	-- We run the function associated to this state
	message, next_state = func()
	
	if message == "STOP" then
		self.isRunning = false
	else
		self.isStopped = true
	end
	-- We send the return value of the function to the dialogue manager
	return message, next_state
end

function Dialogue:setInitState(state_data)
	self.init_state = state_data
end