-- Generated by Pumpkin

local data = {}

local path = ...
if type(path) ~= "string" then
	path = "."
end
data.image = love.graphics.newImage(path.."blossom_b.png")
data.image:setFilter("nearest", "nearest")
data.animations = {
	blossom_baby={
		[0]={u=82, v=22, w=22, h=18, offsetX=11, offsetY=17, duration=0.0333333},
		scale=1
	},
	blossom_baby_cel={
		[0]={u=86, v=0, w=34, h=22, offsetX=12, offsetY=19, duration=0.0333333},
		scale=1
	},
	blossom_mature={
		[0]={u=0, v=50, w=48, h=46, offsetX=23, offsetY=29, duration=0.0333333},
		scale=1
	},
	blossom_mature_cel={
		[0]={u=0, v=0, w=50, h=50, offsetX=25, offsetY=31, duration=0.0333333},
		scale=1
	},
	blossom_young={
		[0]={u=50, v=0, w=32, h=34, offsetX=16, offsetY=33, duration=0.0333333},
		scale=1
	},
	blossom_young_cel={
		[0]={u=48, v=50, w=38, h=40, offsetX=20, offsetY=37, duration=0.0333333},
		scale=1
	},
}
data.quad = love.graphics.newQuad(0, 0, 1, 1, data.image:getWidth(), data.image:getHeight())

return data
