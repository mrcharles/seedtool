vector = require "hump.vector"
require "Tools"


Base = {
	pos = vector(0,0),
}


function Base:new (o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Base:init()
	if self.size ~= nil then
		self:setBounds(self.size, self.offset)
	end
end

function Base:pulse(dir, mag)
	if self.physics then
		local total = dir * mag
		self.physics.body:applyForce(total.x, total.y)
	end
end

function Base:setBounds(size, offset)
	self.bounds = {
		top = -size.y / 2,
		bottom = size.y / 2,
		left = -size.x / 2,
		right = size.x / 2
	}

	if offset ~= nil then
		self.bounds.top = self.bounds.top + offset.y
		self.bounds.bottom = self.bounds.bottom + offset.y
		self.bounds.right = self.bounds.right + offset.x
		self.bounds.left = self.bounds.left + offset.x

	end

end

function Base:inBounds(point)
	if self.bounds then
		return Tools:pointInBounds(point, self.pos, self.bounds)
	end
end



function Base:update(dt)
	if self.physics then
		local x = self.physics.body:getX()
		local y = self.physics.body:getY()

		self.pos = vector(x,y)
	end
end

function Base:draw()

	if DEBUG and self.bounds ~= nil then
		love.graphics.push()
		--love.graphics.translate(self.pos.x, self.pos.y)
		love.graphics.setColor(255,0,0)
		love.graphics.setLine(1)
		love.graphics.rectangle("line", self.pos.x + self.bounds.left, self.pos.y + self.bounds.top, self.bounds.right - self.bounds.left, self.bounds.bottom - self.bounds.top)
		love.graphics.pop()
	end
	
end
