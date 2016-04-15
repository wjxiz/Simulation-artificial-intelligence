NPC = {
	imgfile = "";
	img = nil;
	interacting = false;
	x = 0;
	y = 0;
	label = "";
	profile = "";
	area = nil;
}

function NPC:new (o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

-- Create an Image object for the NPC
function NPC:setImage()
	self.img = love.graphics.newImage(self.imgfile)
end

-- Create an area for the NPC
function NPC:setArea()
	self.area = Area:new{
		height = self.img:getHeight();
		width = self.img:getWidth();
		x = self.x;
		y = self.y;
	}
end

-- Is the NPC willing to give personal information, such as its name?
-- Out: bool
function NPC:isWillingToProvidePersonalData()
	-- This rule is a bit "simple"
	if self.profile == NPC_PROFILE_SHY or self.profile == NPC_PROFILE_ARROGANT or self.profile == NPC_PROFILE_AGGRESSIVE then
		return false
	else
		return true
	end
end

-- This function is not part of the class NPC. It's simply used
-- during the load process to create the NPC instances according to their names.
function createNPC(name)
	local index = nil
	for i, v in ipairs(NPC_NAMES) do
		if v == name then index = i; break;	end
	end
	if index then
		v = NPC_LIST[index]
		o = NPC:new{
			imgfile = "assets//img//"..v.imgfile;
			x = v.x;
			y = v.y;
			label = name;
			profile = v.profile;
		}
	else
		print (string.format("Error, PNJ called %s does not exist in the database.", name))
		return
	end
	if not o then print (string.format("Error in the creation of the NPC %s", name)) end
	return o
end