require "Base"
require "hump.vector"

PaletteEffect = Base:new()
PaletteEffect.index = 0

local path = ...
if type(path) ~= "string" then
	path = "."
end

function PaletteEffect:load(strData)
	local src = [[
		extern number index;
		extern Image sampler;

		vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
		{
			vec4 sample = Texel(tex, tc);
			if(Texel(sampler, vec2(0, 0)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 0));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else if(Texel(sampler, vec2(0, 1.0f/16.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/16.0f));
			}
			else
			{
				color = sample;
			}
			return color;
		}
	]]

	PaletteEffect.image = love.graphics.newImage(strData)--.."/palette.png")
	PaletteEffect.image:setFilter("nearest", "nearest")

	PaletteEffect.effect = love.graphics.newPixelEffect(src)
	PaletteEffect.effect:send('sampler', PaletteEffect.image)
	PaletteEffect.effect:send('index', PaletteEffect.index)

end

function PaletteEffect:setEffect()
	love.graphics.setPixelEffect(PaletteEffect.effect)
end

function PaletteEffect:clearEffect()
	love.graphics.setPixelEffect()
end

t = 0
function PaletteEffect:update(dt)
	t = t + dt
	PaletteEffect.effect:send('index', PaletteEffect.index)
end

function PaletteEffect:setPaletteIndex(index)
	PaletteEffect.index = index
end
