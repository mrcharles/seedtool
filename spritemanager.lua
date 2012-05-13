module(..., package.seeall);

local spriteData = {}

function getSpriteData(strData)
	if spriteData[strData] == nil then
		local chunk = love.filesystem.load( "res/sprites/"..strData..".lua" ) -- load the chunk 
		spriteData[strData] = chunk("res/sprites/")
	end
	
	return spriteData[strData]
end

function createSprite(strData, strAnimation)
	local sprite = {}
	
	if strData ~= nil then
		sprite.sprData = getSpriteData(strData)
		sprite.strData = strData

		-- --hack fix for sprite animations
		-- if sprite.strData and sprite.strData.animations then
		-- 	for i,anim in ipairs(sprite.strData.animations) do
		-- 		if anim[1] == nil then
		-- 			anim[1] = anim[0]
		-- 		end
		-- 	end
		-- end
	end
	
	function sprite:setData(strData, strAnimation, keepTime)
		if strData == nil then
			return
		end

		self.sprData = getSpriteData(strData)
		self.strData = strData

		--hack fix for sprite animations
		-- if self.strData and self.strData.animations then
		-- 	for i,anim in ipairs(self.strData.animations) do
		-- 		if anim[1] == nil then
		-- 			anim[1] = anim[0]
		-- 		end
		-- 	end
		-- end
		
		if strAnimation ~= nil then
			self:setAnimation(strAnimation, keepTime)
		end
	end
	
	function sprite:setAnimation(strAnimation, keepTime)
		keepTime = keepTime or false
		
		self.animation = strAnimation
		
		local animation = self.sprData.animations[strAnimation]
		
		assert(animation ~= nil, "Sprite doesn't have animation: "..strAnimation)
		
		if not keepTime or self.currentFrame > #animation then
			self.currentFrame = 1
			self.animCounter = animation[self.currentFrame - 1].duration
		end

		self.flipH = animation.flipH
	end
	
	function sprite:hasAnimation(strAnimation)
		return self.sprData and self.sprData.animations[strAnimation]
	end
	
	function sprite:update(deltaTime)
		self.animCounter = self.animCounter - (deltaTime * self.animationSpeed)

		if self.animCounter < 0 then
			local animation = self.sprData.animations[self.animation]
			
			self.currentFrame = self.currentFrame + 1
			
			if self.currentFrame > #animation then
				self.currentFrame = 1
			end
			
			self.animCounter = animation[self.currentFrame - 1].duration
		end
	end
	
	function sprite:draw()
		local data = self.sprData
		local animation = data.animations[sprite.animation]
		local frame = animation[self.currentFrame - 1]
		local q = data.quad
		local animScale = animation.scale
		
		q:setViewport(frame.u, frame.v, frame.w, frame.h)
		q:flip(self.flipH, self.flipV)
		
		love.graphics.setColorMode("replace")
		love.graphics.drawq(data.image, q, self.x, self.y, self.rotation, 
			animScale * self.scaleX, animScale * self.scaleY, 
			frame.offsetX, frame.offsetY)
	end
	
	
	sprite.x = 0
	sprite.y = 0
	
	sprite.scaleX = 1
	sprite.scaleY = 1
	
	sprite.filter = "nearest"
	
	sprite.animationSpeed = 1
	sprite.animCounter = 0
	sprite.currentFrame = 1
	
	sprite.flipH = false
	sprite.flipV = false
	
	sprite.rotation = 0
	
	if type(strAnimation) == "string" then
		sprite:setAnimation(strAnimation)
	end
	
	return sprite
end
