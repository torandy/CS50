--! file: square.lua

-- Pass Object as first argument.
Square = Object.extend(Object)

-- new is called constructor
function Square:new(name, value, r, g, b, x, y, sound)
	self.xCenter = love.graphics.getWidth() / 2
	self.yCenter = love.graphics.getHeight() / 2
	self.buttonUnlitOpacity = 0.3
	self.buttonLitOpacity = 1
	self.buttonLitSpeed = 0.1
	self.properties = {
		name = name,
		value = value,
		r = r,
		g = g,
		b = b,
		active = false,
		o = self.buttonUnlitOpacity,
		x = self.xCenter - x,
		y = self.yCenter - y,
		w = 150,
		h = 150,
		sound = "",
	}
end

function Square:update(dt) end

function Square:draw()
	love.graphics.setColor(self.properties.r, self.properties.g, self.properties.b, self.properties.o)
	love.graphics.rectangle("fill", self.properties.x, self.properties.y, self.properties.w, self.properties.h)
end
