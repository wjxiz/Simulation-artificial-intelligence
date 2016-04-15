Gauge = {
	height = GAUGE_HEIGHT_MAX;
	container_x = 0;
	container_y = 0;
	caption_x = 0;
	caption_y = 0;
	container_img = nil;
	container_imgfile = "";
	caption_img = nil;
	caption_imgfile = "";
	text_x = 0;
	text_y = 0;
	font = nil;		-- Will contain a font object. Not actually part of the class, but stored here for readability.
	label = "";		-- the label will be used to refer to gauges objects with strings
}

function Gauge:new (o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function Gauge:draw()
-- Draws the drawable objects on screen:
-- The container, the caption image, the inside of the container, and a text with the value

	love.graphics.setColor(255,255,255)

	-- The container:
  love.graphics.draw(self.container_img, self.container_x, self.container_y)

	-- The caption:
	love.graphics.draw(self.caption_img, self.caption_x, self.caption_y)

	-- The inner rectangle:
	-- Set the colour to a shade of purple, and create a rectangle.
	love.graphics.setColor(179,162,199)
	-- The gauge height is relative to the value of Gus' dimension.
	-- Retrieve the corresponding values for this gauge:
	if self.label == GUS_VIGOR_LABEL then
		dimension_value = Gus.vigor
		dimension_value_min = GUS_VIGOR_MIN
		dimension_value_max = GUS_VIGOR_MAX
	elseif self.label == GUS_SOCIABILITY_LABEL then
		dimension_value = Gus.sociability
		dimension_value_min = GUS_SOCIABILITY_MIN
		dimension_value_max = GUS_SOCIABILITY_MAX
	else
		dimension_value = 0
		dimension_value_min = 0
		dimension_value_max = 1
		dprint ("ERR: Please provide a label for the gauge.")
	end
	norm_height = norm(dimension_value, dimension_value_min, dimension_value_max, GAUGE_HEIGHT_MIN, GAUGE_HEIGHT_MAX-GAUGE_BORDER_SIZE)
	love.graphics.rectangle("fill", self.container_x+GAUGE_BORDER_SIZE,self.container_y+GAUGE_CONTAINER_HEIGHT-GAUGE_BORDER_SIZE,GAUGE_WIDTH,-norm_height)

	-- A text with the value of the dimension:
	love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print(round(dimension_value), self.container_x+5, self.container_y+GAUGE_CONTAINER_HEIGHT-20)
end
