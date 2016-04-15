----------------------------------
-- A file named main.lua has to
-- be present, for LÖVE to know
-- the entry point of the script
----------------------------------

-- Change buffer mode
io.stdout:setvbuf("no")
-- Set seed for random
math.randomseed(os.time())

-- Load scripts
love.filesystem.load("constants.lua")()
love.filesystem.load("data//board_messages.lua")()
love.filesystem.load("data//dialogues.lua")()
love.filesystem.load("tools.lua")()
love.filesystem.load("areas.lua")()
love.filesystem.load("npc.lua")()
love.filesystem.load("gus.lua")()
love.filesystem.load("quest.lua")()
love.filesystem.load("gauges.lua")()
love.filesystem.load("dialogue.lua")()
-- Load all the dialogues contained in dialogues//
dir = "dialogues"
files = love.filesystem.getDirectoryItems(dir)
for _, file in ipairs(files) do
	love.filesystem.load(dir.."//"..file)()
end
love.filesystem.load("status_board.lua")()

----------------------------------
-- Love methods
----------------------------------

-- /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
-- The methods belonging to the class love
-- are directly called by the LÖVE engine.
-- Modify their content, but don't modify either their
-- names or the number/order of their arguments.
-- API available here: https://love2d.org/wiki/love
-- /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\

function love.draw()
-- Updates the screen content.
-- This function is called for each tick of the game,
-- then.. don't overload it with calculation!

	-- If you don't set white colour each time before drawing image files, it'll be coloured with any other current set colour.
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(main_font)

	-- Draw the room's walls
	love.graphics.draw(room_walls, 0, 0)

	-- Draw the status board
	love.graphics.draw(status_board.img, status_board.x, status_board.y)

	-- Draw the gauges
	gauge_vigor:draw()
	gauge_sociability:draw()
	love.graphics.setColor(255,255,255)	-- Set back the color to white because the gauges changed it



	-- Draw the NPCs
	for _, v in ipairs(NPC_group) do
		love.graphics.draw(v.img, v.x, v.y)
	end

	-- Draw Gus' image
    love.graphics.draw(Gus.img, Gus.x, Gus.y,0, 1+(Gus.vigor/100),1+(Gus.vigor/100))

	-- Prints the status board content
	status_board.PrintContent()

end

function love.keyreleased(key)
-- Triggers when a key is released.
-- Set a new case if you want something to happen when another key is released.
-- Please make your code more readable/editable: store the key string value in constants.lua (SHORTCUT_something).

	if table.contains(SHORTCUT_QUIT, key) then
		-- Cleanly stop the game
		love.event.quit()
	elseif table.contains(SHORTCUT_TOGGLEMOVINGMODE, key) then
		-- Toggle between random moving and keyboard control
		Gus.moveRandomly = not Gus.moveRandomly
	elseif table.contains(SHORTCUT_STOPINTERACTION, key) then
		-- Stops the interaction mode and allows Gus to move again
		Gus.interaction.state = false
	end

	print(Gus.interaction.state)
	print(status_board.message.content)
end

function love.update(dt)
-- The name is self-explanatory, isn't it?
-- Called on each update of the game.
-- dt = delta time: time since the last update in seconds
-- dt is explained here: https://love2d.org/wiki/dt

	if not Gus.interaction.state then
	-- The character is allowed to move (not interacting).
		if Gus.moveRandomly then
			-- Gus wanders about the screen randomly.
			Gus.movement.random(dt)
		else
			-- Move Gus with the keyboard.
			Gus.movement.keyboard(dt)
		end
	else
		if DIALOGUE_STARTED then
			Dialogue_manager.runDialogue()
		end
	end
end

function love.focus(f)
-- Called when the window loses or gains focus.
-- For example can be used to pause the game if
-- the user minimizes the window.
	if not f then
		-- dprint("LOST FOCUS")
		-- love.event.quit()
	else
		-- dprint("GAINED FOCUS")
	end
end

function love.quit()
-- Called when the game is stopped.
-- Something can be done here: saving the game state, for example.
end

function love.load()
-- Called once, when the game is loaded.
-- You can use it as your "main()"
-- (if you still use a main(), it'll be called before love.load()).


	--------------------
	-- Instances
	--------------------

	-- Create an instance of Gauge for the Vigor dimension.
	gauge_vigor = Gauge:new{
		container_imgfile = "assets/img/Gauge_Container.png";
		caption_imgfile = "assets/img/Gauge_Vigor_Caption.png";
		container_x = love.graphics.getWidth()-GAUGE_CONTAINER_WIDTH-30;
		container_y = love.graphics.getHeight()-GAUGE_CONTAINER_HEIGHT-30;
		caption_x = love.graphics.getWidth()-70;
		caption_y = love.graphics.getHeight()-35;
		label = GUS_VIGOR_LABEL;
	}

	--Create an instance of Gauge for the Sociability dimension.
	gauge_sociability = Gauge:new {
		container_imgfile = "assets/img/Gauge_Container.png";
		caption_imgfile = "assets/img/Gauge_Sociability_Caption.png";
		container_x = love.graphics.getWidth()-GAUGE_CONTAINER_WIDTH-70;
		container_y = love.graphics.getHeight()-GAUGE_CONTAINER_HEIGHT-30;
		caption_x = love.graphics.getWidth()-110;
		caption_y = love.graphics.getHeight()-35;
		label = GUS_SOCIABILITY_LABEL;
	}
	-- NPC instances
	NPC1 = createNPC("Alain")
	NPC2 = createNPC("Bimon")
	NPC3 = createNPC("Chris")
	NPC4 = createNPC("Dogla")

	NPC_group = {NPC1, NPC2, NPC3, NPC4}

	--------------------
	-- Image creation
	--------------------
	-- Objects containing an image file should preferably be created only once

	-- Gus
	Gus.img = love.graphics.newImage(Gus.imgfile)

	-- Gauges
	gauge_vigor.container_img = love.graphics.newImage(gauge_vigor.container_imgfile)	-- Gauge: vigor (container)
  gauge_vigor.caption_img = love.graphics.newImage(gauge_vigor.caption_imgfile)	-- Gauge: vigor (caption)
	gauge_sociability.container_img = love.graphics.newImage(gauge_sociability.container_imgfile) --Gauge: sociability(container)
	gauge_sociability.caption_img = love.graphics.newImage(gauge_sociability.caption_imgfile) --Gauge: sociability(caption)

	-- NPCs
	NPC1:setImage(); NPC2:setImage(); NPC3:setImage(); NPC4:setImage();

	-- Room walls
	room_walls = love.graphics.newImage("assets//img//Room_Walls.png")

	-- Status board
	status_board.img = love.graphics.newImage(status_board.imgfile)

	--------------------
	-- Areas definition
	--------------------

	-- The rectangle within the walls in which Gus can stroll
	inner_room = Area:new{
		height = ROOM_INNER_HEIGHT;
		width = ROOM_INNER_WIDTH;
		x = ROOM_OFFSET;
		y = ROOM_OFFSET;
	}

	-- The area in which each NPC is located. Whenever Gus enters this area, it'll trigger something.
	NPC1:setArea(); NPC2:setArea(); NPC3:setArea(); NPC4:setArea();



	--set quests
		quest_meet_everyone:assignQuest(NPC1)
	  quest_get_tired:assignQuest(NPC4)
	--------------------
	-- Miscellaneous
	--------------------

	-- The font used to display the gauges' values
	main_font = love.graphics.newFont("assets//font//zrnic.ttf", 15)
	status_board.font = love.graphics.newFont(unpack(status_board.fontInfo))
	status_board.dialogue.font = love.graphics.newFont(unpack(status_board.dialogue.fontInfo))

	-- Set the game's background color
	love.graphics.setBackgroundColor(255,255,255)
end
