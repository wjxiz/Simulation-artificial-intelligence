--==============================================
-- You can move these 4 variables to constants.lua
--==============================================
GUS_PATIENCE_MIN = 0
GUS_PATIENCE_MAX = 100
GUS_PATIENCE_TIMER_MIN = 0	-- in seconds
GUS_PATIENCE_TIMER_MAX = 30	-- in seconds
GUS_PATIENCE_LABEL = "patience"

--==============================================
-- You can move the rest of this file to gus.lua
--==============================================

Gus.patience = GUS_PATIENCE_MAX
Gus.patienceTimer = {
	value = 0,		-- amount of time (in seconds) normalized between 0 and 1
	waitingTime = GUS_PATIENCE_TIMER_MAX,	-- the maximum time Gus will wait before becoming completely impatient
	lastTime = love.timer.getTime(),	-- used to compute the delta time between each tick (in seconds)
	elapsed = 0,	-- in seconds
	active = true,	-- sometimes you may want Gus' patience not to decrease
}

-- Call this function each time Gus starts an activity (e.g. when he moves)
-- It'll set his patience level back to the maximal value and reset the timer
function Gus.resetPatience()
	Gus.patience = GUS_PATIENCE_MAX
	Gus.patienceTimer.value = GUS_PATIENCE_TIMER_MIN
	Gus.patienceTimer.elapsed = 0
end

-- Set Gus' level of patience, according to the amount of time he's been waiting.
-- The more he waits without doing anything,
-- the less patient he is.
-- Beware: Gus.patienceTimer.value is not expressed in seconds (normalized between 0 and 1)
function Gus.updatePatience()
	local patience = norm((1-math.tanh((Gus.patienceTimer.value-1)/0.2)-1), 0, 1, GUS_PATIENCE_MIN, GUS_PATIENCE_MAX)
	patience = keepBetweenMinMax(patience, GUS_PATIENCE_MIN, GUS_PATIENCE_MAX)
	Gus.patience = patience
end

-- Computes the time elapsed since the last tick, normalizes
-- it between 0 and 1, and calls the update of Gus' patience.
function Gus.setPatienceTimer()

	if not Gus.patienceTimer.active then return end
	
	-- If there's no lastTime saved (this can happen when you load the game),
	-- get the current time
	if not Gus.patienceTimer.lastTime then Gus.patienceTimer.lastTime = love.timer.getTime() end
	
	-- Capture the current time for each tick of the game, and add
	-- to the elapsed time the delta value between two ticks
	local newTime = love.timer.getTime()
	local etime = newTime - Gus.patienceTimer.lastTime
	-- The variable Gus.patienceTimer.elapsed is thus a value in seconds
	Gus.patienceTimer.elapsed = Gus.patienceTimer.elapsed + etime
	Gus.patienceTimer.lastTime = newTime
	
	-- Normalise the elapsed time between 0 and 1, and store it in Gus.patienceTimer.value
	Gus.patienceTimer.value = norm(Gus.patienceTimer.elapsed, GUS_PATIENCE_TIMER_MIN, Gus.patienceTimer.waitingTime, 0, 1)
	
	-- Update Gus' level of patience
	Gus.updatePatience()
end