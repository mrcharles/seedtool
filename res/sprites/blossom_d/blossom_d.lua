-- Generated by Pumpkin

local data = {}

local path = ...
if type(path) ~= "string" then
	path = "."
end
data.image = love.graphics.newImage(path.."blossom_d.png")
data.image:setFilter("nearest", "nearest")
data.animations = {
	blossom_baby={
		[0]={u=112, v=24, w=10, h=20, offsetX=5, offsetY=19, duration=0.0333333},
		scale=1
	},
	blossom_baby_cel={
		[0]={u=112, v=0, w=14, h=24, offsetX=6, offsetY=21, duration=0.0333333},
		scale=1
	},
	blossom_mature={
		[0]={u=58, v=0, w=54, h=34, offsetX=27, offsetY=18, duration=0.0333333},
		scale=1
	},
	blossom_mature_cel={
		[0]={u=0, v=0, w=58, h=36, offsetX=29, offsetY=18, duration=0.0333333},
		scale=1
	},
	blossom_young={
		[0]={u=32, v=44, w=26, h=26, offsetX=11, offsetY=28, duration=0.0333333},
		scale=1
	},
	blossom_young_cel={
		[0]={u=0, v=44, w=32, h=34, offsetX=13, offsetY=29, duration=0.0333333},
		scale=1
	},
}
data.quad = love.graphics.newQuad(0, 0, 1, 1, data.image:getWidth(), data.image:getHeight())

return data
