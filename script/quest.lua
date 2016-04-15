----------------------------------
-- Quests
----------------------------------

----------------------------------
-- Quest class
----------------------------------

Quest = {
	prompt = "";	-- the dialogue line that says what is expected of Gus
	resolved = false;
	conditions = {};	-- a list of lambda functions that represent the conditions of the quest
}

function Quest:new (o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

-- Displays the prompt dialogue line associated to this quest
function Quest:startQuest(npc)
	status_board.dialogue.addDialogue(npc.label, self.prompt)
end

-- Checks whether Gus has completed the quest or not
-- Out: true if completed, false otherwise
function Quest:checkCompletion(npc)
	-- If the quest has already been tagged as resolved, then return true
	if self.resolved then return true end

	-- 'ok' will change to False if one of the conditions isn't met
	local ok = true
	-- For each condition of this quest
	for _, func in ipairs(self.conditions) do
		-- we run the function associated to this condition
		if not func() then
			-- if one of the conditions is false, that's over
			ok = false
			break
		end
	end
	-- If ok is still True, it means all the conditions are met
	if ok then
		self.resolved = true
		-- Update Gus memory with the info of the quest completion
		Gus.memory.addInfo("NPCs", {npc.label, "quest_complete", true})
		--add vigor after a quest
		Gus.vigor = keepBetweenMinMax(round(Gus.vigor,3) +30, GUS_VIGOR_MIN, GUS_VIGOR_MAX)
		Gus.sociability = keepBetweenMinMax(round(Gus.sociability,3) +50, GUS_SOCIABILITY_MIN, GUS_SOCIABILITY_MAX)
		-- Check the progress of all the quests
		CheckOverallQuestCompletion()
		return true
	else
		return false
	end
end

-- Called when a NPC is created (in main.lua)
-- to assign this NPC this quest
-- In : a npc object
function Quest:assignQuest(npc)
	npc.quest = self
end

-- /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
-- Beware when you create new conditions:
-- Condition functions should only
-- return binary results (True/False or not-nil/nil)
-- /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\

-- <<Quest description here>>
quest_meet_everyone = Quest:new{
	prompt = "Personne ne vous connaît ici. Allez vous présenter à tout le monde et nous pourrons peut-être nous entendre.",
	conditions = {	function ()	-- you can use anonymous functions in the conditions
						for _, npc in ipairs(NPC_group) do
							if not Gus.memory.npcs[npc.label] then
								return false
							end
						end
						return true
					end,
				}
}

-- <<Quest description here>>
quest_get_tired = Quest:new{
	prompt = "Tu es trop vif pour moi, reviens quand tu seras calmé.",
	conditions = {	function ()
						if Gus.vigor < 70 then
							return true
						else
							return false
						end
					end,
				}
}

----------------------------------
-- Overall quest progress
----------------------------------

-- list all the quests that have to be resolved to meet the objective of the simulation
-- (if the objective consists in completing all the quests)
QUEST_GROUP = {quest_meet_everyone, quest_get_tired}

-- this function is called every time Gus completes a quest
function CheckOverallQuestCompletion()
	for _, quest in ipairs(QUEST_GROUP) do
		if not quest.resolved then
			return false
		end
	end
	-- Gus' reward
	Gus.imgfile = "assets/img/Gus_Crown.png"
	Gus.img = love.graphics.newImage(Gus.imgfile)

	return true
end
