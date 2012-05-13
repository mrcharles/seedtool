vector = require("hump.vector")
Tools = {}

--half of these won't work because I just stole them from my codea proj

function Tools:randVec()
   local x = math.random() * 2 -1
   local y = math.random() * 2 -1
   return vector(x,y):normalize()
end

function Tools:init()
   -- you can accept and set parameters here

end

function Tools:screenCenter()
   return vector( WIDTH/2, HEIGHT/2 )
end

function Tools:pointInScreen(pos, size)
   if pos.x < -size or pos.y < -size or
       pos.y > HEIGHT + size or pos.x > WIDTH + size then

       return false
   end

   return true
end

function Tools:makeRectFromBounds(pos, bounds)
    local r = {
      x = pos.x + bounds.left,
      y = pos.y + bounds.top,
      h = bounds.right - bounds.left,
      w = bounds.bottom - bounds.top
    }
    return r
end

function Tools:pointInBounds(point, pos, bounds)
  local r = Tools:makeRectFromBounds(pos, bounds)
  return Tools:pointInRect(point.x, point.y, r)
end

-- function assumes r has x y h w
function Tools:pointInRect(x, y, r)
   if x >= r.x and x <= r.x + r.w and y >= r.y and y <= r.y + r.h then
       return true
   end
end

function Tools:lerp(a,b,alpha)
   return a + (b-a) * alpha
end

-- this func takes a float between 0 and 4 as a representation for an off screen point
-- and a size outside of the screen
--     3
--  ------
--  |    |
-- 4|    | 2
--  ------
--    1
function Tools:getOffScreenPoint(position, size)
   local corners = { vector( -size, -size ),
                     vector( WIDTH + size, -size ),
                     vector( WIDTH + size, HEIGHT + size ),
                     vector( -size, HEIGHT + size ),
                     vector( -size, -size ), --wraps for mathematical convenience
                   }

   position = position + 1
   local floor = math.floor(position)
   local ceil = math.ceil(position)
   --print("pos: "..position.." floor: "..floor.." ceil: "..ceil)
   return self:lerp( corners[floor], corners[ceil], position - floor )
end

function Tools:lerpColor(a, b, alpha)
   return color( Tools:lerp(a.r,b.r,alpha),
                 Tools:lerp(a.g,b.g,alpha),
                 Tools:lerp(a.b,b.b,alpha),
                 Tools:lerp(a.a,b.a,alpha))
end

function Tools:deepCopyTable(dst, src)
   for k,v in pairs(src) do
       if type(v) == "userdata" then
           print("USERDATA CANNOT BE COPIED")
       elseif type(v) == "function" and string.find(k, "color") then
           dst[k] = v()
       elseif type(v) == "table" then
           dst[k] = {}
           Tools:deepCopyTable(dst[k], v)
       else
           dst[k] = v
       end
   end
end

function Tools:intersectLineLine(p1,p2,p3,p4)
   local r = p2-p1
   local s = p3-p4

   --print(r)
   --print(s)

   local rxs = r:cross(s)
   --print(rxs)
   if rxs == 0 then
       return
   end

   local t = (p3-p1):cross(s) / rxs

   --print(t)
   local u = (p1-p3):cross(r) / rxs
   --print(u)
   if t >= 0 and t <= 1 and u >= 0 and u <= 1 then
       return p1 + r * t
   end
end

function Tools:intersectRayScreen(start,dir, size)
   local vend = start + dir:normalize() * HEIGHT * 3
   local fudge = size or 30

   local results = {}
   local hit = Tools:intersectLineLine(start, vend, vector(-fudge,-fudge), vector(-fudge, HEIGHT + fudge))
   if hit then table.insert( results, hit ) end
   hit = Tools:intersectLineLine(start, vend, vector(-fudge,HEIGHT+ fudge), vector(WIDTH+ fudge, HEIGHT+ fudge))
   if hit then table.insert( results, hit ) end
   hit = Tools:intersectLineLine(start, vend, vector(WIDTH+ fudge,HEIGHT+ fudge), vector(WIDTH+ fudge, -fudge))
   if hit then table.insert( results, hit ) end
   hit = Tools:intersectLineLine(start, vend, vector(WIDTH+ fudge,-fudge), vector(-fudge, -fudge))
   if hit then table.insert( results, hit ) end

   table.sort( results, function(a, b)
                     local adist = (a - start):lenSqr()
                     local bdist = (b - start):lenSqr()
                     return adist < bdist
                 end )

   return unpack(results)

end

function Tools:intersectLineCircle(p1, p2, center, r)
   local d = p2-p1
   local f = p1-center

   local a = d:dot(d)
   local b = 2*f:dot(d)
   local c = f:dot(f) - r*r

   local discriminant = b*b-4*a*c
   local hit1
   local hit2
   if discriminant < 0 then
       return
   else
       discriminant = math.sqrt(discriminant)
       local t1 = (-b + discriminant)/(2*a)
       local t2 = (-b - discriminant)/(2*a)

       if t1 >= 0 and t1 <= 1 then
           hit1 = p1 + d * t1
       end

       if t2 >= 0 and t2 <= 1 then
           hit2 = p1 + d * t2
       end

       if hit1 ~= nil and hit2 ~= nil then
           if t1 < t2 then
               return hit1, hit2
           else
               return hit2, hit1
           end
       elseif hit1 ~= nil then
           return hit1
       elseif hit2 ~= nil then
           return hit2
       end

   end

end