--------------------
-- Dialogue: Ask for name
--------------------

-- Each dialogue is represented as a finite state automaton.
-- In its current state, the dialogue is extremely simple:
-- Gus asks for the NPC name (state1), the NPC gives it (state2), Gus says "nice to meet you" (state3)

-- We create a new instance of Dialogue
dialogue_meet_again = Dialogue:new{}

function Gus_meetAgain()
  local npc = Dialogue_manager.current_dialogue.interlocutor
	local gus_name = Gus.label
  local _, NPC_name = Gus.memory.retrieveInfo(Gus.memory.npcs[npc.label], "name")
	local sentence = DIALOGUE_GUS_MEET_AGAIN:format(NPC_name, gus_name)

	-- Send this sentence to the status_board dialogue section, along with the speaker's name
	status_board.dialogue.addDialogue(Dialogue_manager.current_state.speaker, sentence)

	-- Declare what will be the next state
	next_state = DIALOGUE_STATES_MEET_AGAIN["NPC_cava"]

	-- Return two element (that'll be used by the dialogue manager) :
	-- that the dialogue shall continue (DIALOGUE_NEXT)
	-- and that the next state to run will be next_state
	return DIALOGUE_NEXT, next_state
end

function NPC_ca_va()
	local npc = Dialogue_manager.current_dialogue.interlocutor
 -- npc is willing to give him/her name.
	local sentence = DIALOGUE_NPC_MEET_AGAIN
	 status_board.dialogue.addDialogue(Dialogue_manager.current_state.speaker, sentence)
	return DIALOGUE_STOP
end


-- We list all the states
DIALOGUE_STATES_MEET_AGAIN = {}
-- I use numerical indexes here, but you can also use string values, up to you!
-- The table contains: the function that'll be called when we run this state and the speaker
DIALOGUE_STATES_MEET_AGAIN["Bonjour"] = {Gus_meetAgain, Gus.label}
DIALOGUE_STATES_MEET_AGAIN["NPC_cava"] = {NPC_ca_va, NPC_LABEL}



-- We tell what's the dialogue's initial state (i.e. in which state does the dialogue have to start)
  dialogue_meet_again:setInitState(DIALOGUE_STATES_MEET_AGAIN["Bonjour"])
