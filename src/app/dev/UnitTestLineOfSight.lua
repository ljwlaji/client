local M_PI 			= 3.14159265358979323846
local D_PI 			= M_PI * 2
local AnglePerPi 	= 180 / M_PI

local function angleToPoint(pt1, radio, angle)
	return cc.p(
		pt1.x + radio * math.cos(angle * AnglePerPi),
		pt1.y + radio * math.sin(angle * AnglePerPi)
	)
end

local function wrap(t, lo, hi) 
    if t >= lo and t < hi then
        return t
    end

    local interval = hi - lo

    return t - interval * (t - lo) / interval
end

local function getAngle(p1, p2)
    local dx = p2.x - p1.x;
    local dy = p2.y - p1.y;

    local ang = math.atan2(dy, dx);
    ang = (ang >= 0) and ang or D_PI + ang;
    return ang;
end

local function genTriangle(centerP, radio)
    return {
        cc.p(math.random(centerP.x - radio, centerP.x), math.random(centerP.y - radio, centerP.y + radio*2)),
        cc.p(math.random(centerP.x - radio, centerP.x), math.random(centerP.y - radio, centerP.y + radio*2)),
        cc.p(math.random(centerP.x - radio, centerP.x), math.random(centerP.y - radio, centerP.y + radio*2)),
    }
end

local function getVaildPoints(origin, points)
	for _, v in ipairs(points) do
		v.angle = getAngle(origin, v)
		v.dist = cc.pDistanceSQ(origin, v)
		v.c = v.angle * AnglePerPi
	end

    table.sort(points, function(a, b) return a.angle > b.angle end)
    points[2].color = cc.c4f(0, 0, 1, 1)
    return points
end

local function genAndCalcAllShapes()
    local ts = {}
    for i = 1, 2 do
        table.insert(ts, getVaildPoints(cc.p(display.cx, display.cy), genTriangle(cc.p( math.random(100, display.cx - 100), math.random(100, 500) ), 100)))
    end
    return ts
end

local function canDraw(ts, angle)
	for _, v in ipairs(ts) do
		-- print(v[1].angle, "       "..v[2].angle.."     "..angle)
			-- print(v[1].angle, "       "..v[2].angle.."     "..angle)
		if (v[1].angle > angle and v[3].angle < angle) then
			-- print("无法绘制")
			-- print(v[1].angle, "       "..v[2].angle.."     "..angle)
			return cc.c4f(1, 1, 0, 1)
		end
	end
	return cc.c4f(1, 1, 1, 1)
end

local function testSight(drawNode, ts)
	local step = M_PI / 180.000000000
	local i = 0
	while i < D_PI do
		i = i + step
		local color = canDraw(ts, i) 
		drawNode:drawLine(cc.p(display.cx, display.cy), angleToPoint(display.center, 500, i), color)
	end
end

local function testFunc(parent)
	local ts = genAndCalcAllShapes()
    local verticalLine = CCDrawNode:create()
    for _, v in ipairs(ts) do
        verticalLine:drawPolygon(v, 3, cc.c4f(0,0,0,0), 1, cc.c4f(1,1,1,1))
        for _, p in ipairs(v) do
            verticalLine:drawLine(cc.p(display.cx, display.cy), p, p.color and p.color or cc.c4f(1,0,0,1))
        end
    end
    dump(ts)
    testSight(verticalLine, ts)
    verticalLine:addTo(parent)
end

return testFunc