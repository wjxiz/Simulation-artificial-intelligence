----------------------------------
-- AREAS
-- Virtual areas on the screen.
-- Used to deal with
-- collisions (NPC, walls).
----------------------------------

Area = {
	height = 0;
	width = 0;
	x = 0;	-- position of the upper left corner of the area (x axis)
	y = 0;	-- position of the upper left corner of the area (y axis)
}

function Area:new (o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

-- Checks whether the expected new position of an object will be in this area
-- In: the object's height & width, expected x position for the item, expected y position
-- Out: true if the object will be within the area, false otherwise
function Area:IsPositionInside(object_height, object_width, next_x, next_y)
	has_not_reached_upper_side = next_y > self.y
	has_not_reached_bottom_side = (next_y + object_height) < (self.y + self.height)
	has_not_reached_left_side = next_x > self.x
	has_not_reached_right_side = (next_x + object_width) < (self.x + self.width)
	
	if has_not_reached_left_side and has_not_reached_upper_side and has_not_reached_right_side and has_not_reached_bottom_side then
		return true
	end
	return false
end

-- Checks whether an object touched the area
-- Algo found on http://www.jeuxvideo.com/forums/1-31-8465061-1-0-1-0-0.htm
function Area:IsAreaTouched(object_height, object_width, object_x, object_y)
	area_center_x = self.x + self.width/2;
	area_center_y = self.y + self.height/2;
	object_center_x = object_x + object_width/2;
	object_center_y = object_y + object_height/2;
	
	distance_x = math.abs(object_center_x - area_center_x);
	distance_y = math.abs(object_center_y - area_center_y);

	-- I add some more pixels because Gus' & the NPCs' graphics don't entirely fill their areas.
	-- It allows Gus to come visually "closer" to the NPC before triggering it.
	decrease_value = 10
	if (distance_x < ((self.width+object_width)/2)-decrease_value) and (distance_y < ((self.height+object_height)/2)-decrease_value) then
		return true
	end
	return false	
end