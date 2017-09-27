
package.path = "../../?.lua;../?.lua;" .. package.path

local bsp = require "bsp"

local seed = os.time()
local time_running = 0
local edges = {}
local polygon = {
    bsp.new_point(  0,   0),
    bsp.new_point(700,   0),
    bsp.new_point(700, 500),
    bsp.new_point(  0, 500)
}
local condition = bsp.condition.split_by_middle(1000,0.3)

function love.load (arg)
end

function love.update (dt)
    math.randomseed(seed)
    time_running = time_running + dt
    local point_relations = bsp.generate_bsp(polygon,condition,time_running*100)
    edges = bsp.get_edges_from_relations(point_relations)
end

function love.draw ()
    love.graphics.setColor(255,255,255,50)
    love.graphics.rectangle("line",50,50,700,500)
    love.graphics.setColor(255,255,255,255)
    for _,edge in ipairs(edges) do
        love.graphics.line(edge.p1.x+50,edge.p1.y+50,edge.p2.x+50,edge.p2.y+50)
    end

    love.graphics.print(love.timer.getFPS())
end
