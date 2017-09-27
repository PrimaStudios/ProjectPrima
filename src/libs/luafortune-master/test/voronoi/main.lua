
package.path = "../../?.lua;../?.lua;" .. package.path

local voronoi = require "voronoi"

local points = {}
local edges = {}

function love.load (arg)
    for i=1, 200 do
        points[i] = {
            x = math.random()*700,
            y = math.random()*500,
            dx = math.random()*30-15,   -- Not aknowledged by the library
            dy = math.random()*30-15    -- Not aknowledged by the library
        }
    end
    edges = voronoi.fortunes_algorithm(points,0,0,700,500)
    faces = voronoi.find_faces_from_edges(edges, points)
    --record_gif(100,0.2)
    --print("Found #edges: "..#edges)
end

function love.update (dt)
    for _,point in ipairs(points) do
        point.x = (point.x + point.dx*dt+700)%700
        point.y = (point.y + point.dy*dt+500)%500
    end
    edges = voronoi.fortunes_algorithm(points,0,0,700,500)
    faces = voronoi.find_faces_from_edges(edges, points)
end

function love.draw ()
    love.graphics.setColor(255,255,255,50)
    love.graphics.rectangle("line",50,50,700,500)
    love.graphics.setColor(255,255,255,255)
    for _,point in pairs(points) do
        love.graphics.rectangle("fill",point.x-2+50,point.y-2+50,4,4)
    end
    --[[for _,face in ipairs(faces) do
        for i=#face, 1, -1 do
            love.graphics.line(face[i].x+50,face[i].y+50,face[i%#face+1].x+50,face[i%#face+1].y+50)
        end
    end--]]
    for _,edge in ipairs(edges) do
        love.graphics.line(edge.p1.x+50,edge.p1.y+50,edge.p2.x+50,edge.p2.y+50)
    end--]]
    love.graphics.print(love.timer.getFPS())
end
