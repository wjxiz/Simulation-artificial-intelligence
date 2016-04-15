dialogue_ask_for_name_again = Dialogue:new{}

function Gus_askNameAgain()
	local sentence = DIALOGUE_GUS_ASK_NAME_AGAIN

	-- Send this sentence to the status_board dialogue section, along with the speaker's name
	status_board.dialogue.addDialogue(Dialogue_manager.current_state.speaker, sentence)

	-- Declare what will be the next state
	next_state = DIALOGUE_STATES_ASK_FOR_NAME_AGAIN["NPC_Answer_2"]

	-- Return two element (that'll be used by the dialogue manager) :
	-- that the dialogue shall continue (DIALOGUE_NEXT)
	-- and that the next state to run will be next_state
	return DIALOGUE_NEXT, next_state
end

function NPC_Answer_2()
	local npc = Dialogue_manager.current_dialogue.interlocutor
 -- npc is willing to give him/her name at the second ask.
	if  true then
	 local sentence
	 if npc.label == "Alain" then
		 sentence = DIALOGUE_NPC_GIVENAME_ARROGANT:format(Gus.label, npc.label)
	 elseif npc.label == "Bimon" then
		 sentence = DIALOGUE_NPC_GIVENAME_CHARMEUR:format(npc.label)
	 elseif npc.label == "Chris" then
		 sentence = DIALOGUE_NPC_GIVENAME_AGRESSIF:format(npc.label)
	 else
		 sentence = DIALOGUE_NPC_GIVENAME_TIMIDE:format(npc.label,Gus.label)
	 end
	 status_board.dialogue.addDialogue(Dialogue_manager.current_state.speaker, sentence)
	 -- NPC gave its name. Add this to Gus' memory
	 print("sentece is ")
	 print(sentence)
	 local profile = Gus.interaction.guessProfile(sentence)
	 --add profile into Gus's memory.
	 Gus.memory.addInfo("NPCs", {npc.label, "profile", profile})
	 print(Gus.memory.npcs[npc.label]["profile"])
	 Gus.memory.addInfo("NPCs", {npc.label, "name", npc.label})
   -- Gus get more vigor
   --Gus.vigor = keepBetweenMinMax(round(Gus.vigor,3) + （GUS_VIGOR_MAX - Gus.vigor）* 0.5, GUS_VIGOR_MIN, GUS_VIGOR_MAX)
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
		status_board.dialogue.addDialogue(Dialogue_manager.current_state.speaker, sentence)
    -- change of the sociability
    -- -15 if it's the second ask for name
    Gus.sociability = keepBetweenMinMax(round(Gus.sociability,3) - (GUS_SOCIABILITY_STEP+5), GUS_SOCIABILITY_MIN, GUS_SOCIABILITY_MAX)
		next_state = DIALOGUE_STATES_ASK_FOR_NAME["Gus_bye"]
		return DIALOGUE_NEXT, next_state
 	end
end

DIALOGUE_STATES_ASK_FOR_NAME_AGAIN = {}

DIALOGUE_STATES_ASK_FOR_NAME_AGAIN["askAgain"] = {Gus_askNameAgain, Gus.label}
DIALOGUE_STATES_ASK_FOR_NAME_AGAIN["NPC_Answer_2"] = {NPC_Answer_2, NPC_LABEL}

dialogue_ask_for_name_again:setInitState(DIALOGUE_STATES_ASK_FOR_NAME_AGAIN["askAgain"])
