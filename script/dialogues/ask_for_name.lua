--------------------
-- Dialogue: Ask for name
--------------------

-- Each dialogue is represented as a finite state automaton.
-- In its current state, the dialogue is extremely simple:
-- Gus asks for the NPC name (state1), the NPC gives it (state2), Gus says "nice to meet you" (state3)

-- We create a new instance of Dialogue

local times_ask_for_name = 0   --a variable to record the times that gus has asked for a name
dialogue_ask_for_name = Dialogue:new{}
function Gus_askName()
	times_ask_for_name = 0
	local sentence = DIALOGUE_GUS_WHATS_YOUR_NAME

	-- Send this sentence to the status_board dialogue section, along with the speaker's name
	status_board.dialogue.addDialogue(Dialogue_manager.current_state.speaker, sentence)
	--times + 1
	times_ask_for_name = times_ask_for_name + 1

	-- Declare what will be the next state
	next_state = DIALOGUE_STATES_ASK_FOR_NAME["NPC_Answer"]
	print("times_ask_for_name")
	print(times_ask_for_name)

	-- Return two element (that'll be used by the dialogue manager) :
	-- that the dialogue shall continue (DIALOGUE_NEXT)
	-- and that the next state to run will be next_state
	return DIALOGUE_NEXT, next_state
end



-- npc answer Gus's question :give or not give his/her name
function NPC_Answer()
	local npc = Dialogue_manager.current_dialogue.interlocutor
 -- npc is willing to give him/her name.
 -- get his name and his profile!
	if npc:isWillingToProvidePersonalData() == true then


	 local sentence
	 if npc.label == "Alain" then
		 sentence = DIALOGUE_NPC_GIVENAME_ARROGANT:format(Gus.label, npc.label)
	 elseif npc.label == "Bimon" then
		 sentence = DIALOGUE_NPC_GIVENAME_CHARMEUR:format(npc.label)
	 elseif npc.label == "Chris" then
		 sentence = DIALOGUE_NPC_GIVENAME_AGRESSIF:format(npc.label)
	 else
		 sentence = DIALOGUE_NPC_GIVENAME_TIMIDE:format(npc.label,Gus,label)
	 end
	 status_board.dialogue.addDialogue(Dialogue_manager.current_state.speaker, sentence)
	 -- add Gus's sociability 10
	 Gus.sociability = keepBetweenMinMax(round(Gus.sociability,3) + GUS_SOCIABILITY_STEP, GUS_SOCIABILITY_MIN, GUS_SOCIABILITY_MAX)
	 --add Gus's vigor
	 Gus.vigor = keepBetweenMinMax(round(Gus.vigor,3) + (GUS_VIGOR_MAX - Gus.vigor)* 0.5, GUS_VIGOR_MIN, GUS_VIGOR_MAX)
	 -- NPC gave its name. Add this to Gus' memory
	 Gus.memory.addInfo("NPCs", {npc.label, "name", npc.label})

	 print("sentece is ")
	 print(sentence)
	 local profile = Gus.interaction.guessProfile(sentence)
	 --add profile into Gus's memory.
	 Gus.memory.addInfo("NPCs", {npc.label, "profile", profile})
	 print(Gus.memory.npcs[npc.label]["profile"])


	 next_state = DIALOGUE_STATES_ASK_FOR_NAME["Gus_niceToMeetU"]
	 return DIALOGUE_NEXT, next_state
  else
		-- npc will not give him/her name
		local sentence
		if npc.profile == NPC_PROFILE_ARROGANT then
			sentence = DIALOGUE_ARROGANT_REFUSE
		elseif npc.profile == NPC_PROFILE_CHARMER then
			sentence = DIALOGUE_CHARMEUR_REFUSE
		elseif npc.profile == NPC_PROFILE_AGGRESSIVE then
			sentence = DIALOGUE_AGRESSIF_REFUSE
		elseif npc.profile == NPC_PROFILE_SHY then
			sentence = DIALOGUE_TIMIDE_REFUSE
		else
			sentence = DIALOGUE_NPC_I_WONT_GIVE_MY_NAME
		end
		print("times_ask_for_name")
		print(times_ask_for_name)
		status_board.dialogue.addDialogue(Dialogue_manager.current_state.speaker, sentence)
		-- -10 if it's the first ask for name
		Gus.sociability=keepBetweenMinMax(round(Gus.sociability,3) - GUS_SOCIABILITY_STEP, GUS_SOCIABILITY_MIN, GUS_SOCIABILITY_MAX)
		if times_ask_for_name<=3 then
			next_state = DIALOGUE_STATES_ASK_FOR_NAME["negociate_start"]
		else
			next_state = DIALOGUE_STATES_ASK_FOR_NAME["Gus_bye"]
			-- change ask times to 0
			times_ask_for_name = 0
		end

		return DIALOGUE_NEXT, next_state
 	end
end

function Gus_niceToMeetU()
	local npc = Dialogue_manager.current_dialogue.interlocutor
	local gus_name = Gus.label
	local _, NPC_name = Gus.memory.retrieveInfo(Gus.memory.npcs[npc.label], "name")
	local sentence = DIALOGUE_GUS_NICE_TO_MEET_YOU:format(NPC_name, gus_name)
	status_board.dialogue.addDialogue(Dialogue_manager.current_state.speaker, sentence)

	-- Return only one element :
	-- that's the end of the dialogue (DIALOGUE_STOP)
	return DIALOGUE_STOP
end

function Gus_sayBye()
	local gus_name = Gus.label
	local sentence = DIALOGUE_GUS_BYE
	status_board.dialogue.addDialogue(Dialogue_manager.current_state.speaker, sentence)
	return DIALOGUE_STOP
end


-- negotiate to get the name!
function negotiate()
  local sentence
  if (Gus.sociability>= 75 and Gus.sociability<=100)  then
    sentence = DIALOGUE_GUS_COMPLIMENT
  elseif Gus.sociability >= 50 then
    sentence = DIALOGUE_GUS_AMADOUE
  elseif Gus.sociability >= 25 then
    sentence = DIALOGUE_GUS_SUPPLIE
  else
    sentence = DIALOGUE_GUS_AGRESSIF
  end

	--ask times + 1
	times_ask_for_name = times_ask_for_name + 1
  status_board.dialogue.addDialogue(Dialogue_manager.current_state.speaker, sentence)
	next_state = DIALOGUE_STATES_ASK_FOR_NAME["answer"]
	print("times_ask_for_name")
	print(times_ask_for_name)
  return DIALOGUE_NEXT, next_state
end



function noNegociate()
	local npc = Dialogue_manager.current_dialogue.interlocutor
  local sentence = DIALOGUE_NPC_NEGOCIATE_NO
  status_board.dialogue.addDialogue(Dialogue_manager.current_state.speaker, sentence)
	if times_ask_for_name <=3 then
		next_state = DIALOGUE_STATES_ASK_FOR_NAME["negociate_start"]
	else
  	next_state = DIALOGUE_STATES_ASK_FOR_NAME["hateBye"]
	end
  return DIALOGUE_NEXT, next_state
end

function hateBye()
  local sentence = DIALOGUE_GUS_HATEBYE
  status_board.dialogue.addDialogue(Dialogue_manager.current_state.speaker, sentence)
  return DIALOGUE_STOP
end





-- We list all the states
DIALOGUE_STATES_ASK_FOR_NAME = {}
-- I use numerical indexes here, but you can also use string values, up to you!
-- The table contains: the function that'll be called when we run this state and the speaker
DIALOGUE_STATES_ASK_FOR_NAME["AskName"] = {Gus_askName, Gus.label}
DIALOGUE_STATES_ASK_FOR_NAME["NPC_Answer"] = {NPC_Answer, NPC_LABEL}
DIALOGUE_STATES_ASK_FOR_NAME["Gus_niceToMeetU"] = {Gus_niceToMeetU, Gus.label}

DIALOGUE_STATES_ASK_FOR_NAME["Gus_bye"] = {Gus_sayBye, Gus.label}


DIALOGUE_STATES_ASK_FOR_NAME["negociate_start"] = {negotiate, Gus.label}
DIALOGUE_STATES_ASK_FOR_NAME["answer"] = {noNegociate, NPC_LABEL}
DIALOGUE_STATES_ASK_FOR_NAME["hateBye"] = {hateBye, Gus.label}


-- We tell what's the dialogue's initial state (i.e. in which state does the dialogue have to start)
dialogue_ask_for_name:setInitState(DIALOGUE_STATES_ASK_FOR_NAME["AskName"])
