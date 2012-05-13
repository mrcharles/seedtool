require "Base"
require "hump.vector"
require "spritemanager"
require "PaletteEffect"

LayeredSprite = Base:new()
LayeredSprite.position = vector(50, 50)
LayeredSprite.baseLayer = {}
LayeredSprite.topLayer = {}
LayeredSprite.effect = {}

function LayeredSprite:load(strData, strAnimation)
	LayeredSprite.baseLayer = spritemanager.createSprite()
	LayeredSprite.baseLayer.strData = strData
	LayeredSprite.baseLayer.animation = strAnimation
	LayeredSprite.baseLayer:setData(LayeredSprite.baseLayer.strData, LayeredSprite.baseLayer.animation, true)


	LayeredSprite.topLayer = spritemanager.createSprite()
	LayeredSprite.topLayer.strData = strData.."_cel"
	LayeredSprite.topLayer.animation = strAnimation.."_cel"
	LayeredSprite.topLayer:setData(LayeredSprite.topLayer.strData, LayeredSprite.topLayer.animation, true)
	LayeredSprite.topLayer.sprData.image:setFilter("linear", "linear")

	--LayeredSprite.effect = PaletteEffect:new()
	--LayeredSprite.effect:load("res/sprites/"..strData.."_palette.png")
end

function LayeredSprite:setPosition(pos)
	LayeredSprite.position = pos
end

function LayeredSprite:setAnimation(animation)
	LayeredSprite.baseLayer:setAnimation(animation, true)
	LayeredSprite.topLayer:setAnimation(animation, true)
end

function LayeredSprite:update(dt)
	--LayeredSprite.effect:update(dt)

	LayeredSprite.baseLayer.x = LayeredSprite.position.x
	LayeredSprite.baseLayer.y = LayeredSprite.position.y

	LayeredSprite.topLayer.x = LayeredSprite.position.x
	LayeredSprite.topLayer.y = LayeredSprite.position.y

	LayeredSprite.baseLayer:update(dt)
	LayeredSprite.topLayer:update(dt)
end

function LayeredSprite:draw()
	--LayeredSprite.effect:setEffect()
	LayeredSprite.baseLayer:draw()
	LayeredSprite.effect:clearEffect()
	LayeredSprite.topLayer:draw()
end
