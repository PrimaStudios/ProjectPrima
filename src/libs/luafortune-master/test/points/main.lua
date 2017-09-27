
package.path = "./../?.lua;" .. package.path

local random_points = require("points")

local seed = os.time()
local time_running = 0
local points = {}

local modes = {
    [1] = "White Noise",
    [2] = "Blue Noise",
}
local mode = 1
local auto = false

local polygon = {
    {x= 50, y=100},
    {x=650, y=200},
    {x=750, y=450},
    {x=300, y=350},
    {x=100, y=550},
}

function love.load (arg)
    points = random_points.white_noise(50,750,50,550, 1000)
end

function love.update (dt)
    if dt and not auto then
    elseif mode == 1 then
        points = random_points.white_noise_polygon(polygon, 2000)
    elseif mode == 2 then
        points = random_points.blue_noise_polygon(polygon, 7, 10)
    end
end

function love.keypressed (key)
    if key == " " then
        auto = not auto
    elseif tonumber(key) and modes[tonumber(key)] then
        mode = tonumber(key)
        love.update()
    end
end

function love.draw ()
    love.graphics.setColor(255,255,255)

    for i=1, #polygon do
        local p1 = polygon[i]
        local p2 = polygon[i%#polygon+1]
        love.graphics.line(p1.x,p1.y,p2.x,p2.y)
    end

    for _, point in ipairs(points) do
        love.graphics.circle("fill",point.x, point.y, 2)
    end

    love.graphics.setColor(255,0,0,255)
    love.graphics.circle("fill",points[1].x, points[1].y, 2)

    love.graphics.setColor(255,255,255,255)
    love.graphics.print("FPS: "..love.timer.getFPS(), 10, 10)
    love.graphics.print("MODE: "..modes[mode], 10, 30)
    love.graphics.print("POINTS: "..#points, 100, 10)

    love.graphics.print("SPACEBAR: enable/disable autogen\n[NUMBER]: Change mode", 500, 10)
end
