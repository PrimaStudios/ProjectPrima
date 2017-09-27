
package.path = "../../?.lua;../?.lua;" .. package.path

local voronoi = require "voronoi"
local ProFi = require "ProFi"

--------------------------

local NR_TESTS = 40
local NR_POINTS_BASE = 0
local NR_POINTS_INCREASE = 10

--------------------------

local NR_TESTS_DIV10 = NR_TESTS/10

print("RUNNING TESTS: ")

ProFi:start()

for test_nr=1, NR_TESTS do
    local points = {}
    local edges = {}
    for i=NR_POINTS_BASE+NR_POINTS_INCREASE*test_nr, 1, -1 do
        points[i] = voronoi.new_point(math.random(),math.random())
    end
    edges = voronoi.fortunes_algorithm(points,0,0,1,1)
    if (test_nr-1)%NR_TESTS_DIV10>NR_TESTS_DIV10/2
        and test_nr%NR_TESTS_DIV10<NR_TESTS_DIV10/2 then
        print(test_nr)
    end
end

print("TESTS DONE!")

ProFi:stop()
ProFi:writeReport('./profileReport.log')
