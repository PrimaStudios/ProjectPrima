
package.path = "../../?.lua;../?.lua;" .. package.path

local voronoi = require "voronoi"

--------------------------

local NR_TESTS = 100
local NR_TESTS_DIV10 = NR_TESTS/10
local RUNNING_ON = (jit and jit.version or _VERSION)
local DATE = os.date()
local FILENAME = "./benchmark_"..(RUNNING_ON.."_"..DATE):gsub("[:. ]", "_")..".log"

local nr_points = function (test_nr)
    return test_nr*10
end

--------------------------

print("RUNNING BENCHMARKS: ")

local results = {}
local points = {}
local edges = {}
for test_nr=1, NR_TESTS do
    for i=nr_points(test_nr), 1, -1 do
        points[i] = voronoi.new_point(math.random(),math.random())
    end
    local start_time = os.clock()
    edges = voronoi.fortunes_algorithm(points,0,0,1,1)
    results[test_nr] = os.clock()-start_time
    if (test_nr-1)%NR_TESTS_DIV10>NR_TESTS_DIV10/2
        and test_nr%NR_TESTS_DIV10<NR_TESTS_DIV10/2 then
        print(test_nr)
    end
end

print("BENCHMARKING DONE!")

local total = 0
for test_nr=1, NR_TESTS do
    total = total + results[test_nr]
end

local file = io.open(FILENAME,"w"); io.output(file)

io.write("Benchmarking results for luaFortune " .. voronoi.version .. " on " ..
          DATE .. "\nRunning on: "..RUNNING_ON.."\nTotal Runtime: "..total.." CPU Time\n\n")


local spacing = {"     ","    ","   ","  "," ",""}
for test_nr=1, NR_TESTS do
    local nr_points = nr_points(test_nr)
    io.write(spacing[math.floor(math.log10(nr_points))] .. nr_points .. " points: " .. results[test_nr] .. " \tCPU Time\n")
end
