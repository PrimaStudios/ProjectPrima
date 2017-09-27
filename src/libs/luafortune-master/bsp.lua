--[[
    Binary Space Partitioning module of the luaFortune library.

    Documentation and License can be found here:
    https://bitbucket.org/Jmaa/luafortune
--]]

local bsp = {
    version = 1.0,
}

--------------------------------------------------------------------------------
-- Util functions for the BSP creation

local point_mt = {
    __tostring = function (t) return "("..t.x..","..t.y..")" end
}

local function new_point (x,y)
    return setmetatable({x=x,y=y},point_mt)
end

bsp.new_point = new_point

local function remove_from_table (t, obj)
    for i, o_obj in ipairs(t) do
        if o_obj == obj then
            table.remove(t,i)
            return i
        end
    end
end

local function area_of_polygon (polygon)
    if #polygon == 0 then
        return 0
    end
    local p1, p2 = polygon[#polygon],polygon[1]
    local area = p1.x*p2.y-p2.x*p1.y
    for i=1, #polygon-1 do
        local p1, p2 = polygon[i],polygon[i%#polygon+1]
        area = area + p1.x*p2.y-p2.x*p1.y
    end
    return area/2
end

--------------------------------------------------------------------------------
-- Basic BSP Algorithm

bsp.generate_bsp = function (polygon, condition, max_iterations)
    -- `polygon` needs to contain a clockwise defined convex polygon.

    local point_relations = {}
    for i=1, #polygon do
        point_relations[polygon[i]] = {polygon[i%#polygon+1],polygon[(i+#polygon-1)%#polygon]}
    end

    local max_iterations = max_iterations or math.huge
    local queue = {polygon}
    while #queue > 0 and max_iterations > 0 do
        max_iterations = max_iterations - 1
        local current_poly = table.remove(queue,1)
        local l1_p1, l1_p2, t1, l2_p1, l2_p2, t2 = condition(current_poly)
        if l1_p1 then
            local l1_p3 = new_point(l1_p1.x+(l1_p2.x-l1_p1.x)*t1, l1_p1.y+(l1_p2.y-l1_p1.y)*t1)
            local l2_p3 = new_point(l2_p1.x+(l2_p2.x-l2_p1.x)*t2, l2_p1.y+(l2_p2.y-l2_p1.y)*t2)

            point_relations[l1_p3] = {l2_p3,l1_p1,l1_p2}
            point_relations[l2_p3] = {l1_p3,l2_p1,l2_p2}

            remove_from_table(point_relations[l1_p1],l1_p2)
            remove_from_table(point_relations[l1_p2],l1_p1)
            table.insert(point_relations[l1_p1],l1_p3)
            table.insert(point_relations[l1_p2],l1_p3)

            remove_from_table(point_relations[l2_p1],l2_p2)
            remove_from_table(point_relations[l2_p2],l2_p1)
            table.insert(point_relations[l2_p1],l2_p3)
            table.insert(point_relations[l2_p2],l2_p3)

            local first_new_poly = {}
            local second_new_poly = {}
            table.insert(queue,first_new_poly)
            table.insert(queue,second_new_poly)

            local current_new_poly = first_new_poly
            for i = 1, #current_poly do
                table.insert(current_new_poly,current_poly[i])
                if current_poly[i] == l1_p1 then
                    current_new_poly = current_new_poly==first_new_poly and second_new_poly or first_new_poly
                    table.insert(first_new_poly,l1_p3)
                    table.insert(second_new_poly,l1_p3)
                elseif current_poly[i] == l2_p1 then
                    current_new_poly = current_new_poly==first_new_poly and second_new_poly or first_new_poly
                    table.insert(second_new_poly,l2_p3)
                    table.insert(first_new_poly,l2_p3)
                end
            end
        end
    end

    return point_relations
end

--------------------------------------------------------------------------------
-- Util functions for supplied conditions

local function get_center_of_polygon (polygon)
    -- It won't return the proper centroid of the polygon. But this will mostly
    -- work alright.
    local total_x, total_y = 0, 0
    for _, point in ipairs(polygon) do
        total_x, total_y = total_x+point.x, total_y+point.y
    end
    return total_x/#polygon, total_y/#polygon
end

local function middle_of_line (l1, l2)
    return new_point((l1.x+l2.x)/2,(l1.y+l2.y)/2)
end

local function nearest_point_on_line (p0, l1, l2)
	local x, y				= 0, 0
	local x1, y1, x2, y2, x3, y3 = l1.x, l1.y, l2.x, l2.y, p0.x, p0.y
	local unclamped_u = ( (x3-x1)*(x2-x1) + (y3-y1)*(y2-y1) ) / ( (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) )
	local u = math.min( 1, math.max( 0, unclamped_u ) )
	local closest_x = x1 + u*(x2-x1)
	local closest_y = y1 + u*(y2-y1)

    return new_point(closest_x, closest_y)
end

local function dist_between_point_2 (p1, p2)
    return math.pow(p1.x-p2.x,2)+math.pow(p1.y-p2.y,2)
end

--------------------------------------------------------------------------------
-- Supplied conditions

bsp.condition = {}

bsp.condition.split_by_middle = function (min_area, random_zone)
    local zone_offset = (1-random_zone)/2
    return function (polygon)
        local polygon_len = #polygon
        if area_of_polygon(polygon) < min_area or polygon_len < 3 then
            return nil
        end
        local center_point = new_point(get_center_of_polygon(polygon))
        local nearest_side, near_line_point_dist = 1, math.huge
        for i=1, polygon_len do
            local line_point = nearest_point_on_line(center_point,polygon[i],polygon[i%polygon_len+1])
            local dist = dist_between_point_2(center_point, line_point)
            if dist < near_line_point_dist then
                nearest_side, near_line_point_dist = i, dist
            end
        end
        local side1 = nearest_side
        local side2 = (side1+math.floor(polygon_len/2)-1)%polygon_len+1
        return polygon[side1], polygon[side1%polygon_len+1], zone_offset+math.random()*random_zone,
               polygon[side2], polygon[side2%polygon_len+1], zone_offset+math.random()*random_zone
    end
end

--------------------------------------------------------------------------------
-- Interface functions.

bsp.get_edges_from_relations = function (point_relations)
    local edges = {}
    for point, points in pairs(point_relations) do
        for _, other_point in ipairs(points) do
            table.insert(edges,{p1=point,p2=other_point})
        end
    end
    return edges
end

--------------------------------------------------------------------------------

return bsp
