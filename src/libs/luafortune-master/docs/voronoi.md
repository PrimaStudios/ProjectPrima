# Voronoi ######################################################################

## Introduction ################################################################

A simple and fast Lua port of Fortune's Algorithm.

Useful for map generation, tracing cholora outbreaks to their origin, [and a
lot more](https://en.wikipedia.org/wiki/Voronoi_diagram#Applications). For
most people looking here, I'll take the wager and say it'll be map
generation.

![Animated voronoi graph, based on random particles.](images/voronoi_ani.gif)

## How To Use ##################################################################

### Dependencies & Installation ################################################

Plug-and-play, no internal or external dependencies.

### Quick Start ################################################################

Using the module primarily involves passing a lot of Points to
`fortunes_algorithm` and receiving some Edges, then passing both the Points
and the Edges to `find_faces_from_edges`, which will find the faces for you.

Example:

```lua
local voronoi = require "voronoi"
local points = {}
for i=1, 10 do
    points[i] = voronoi.new_point(math.random(),math.random())
    --Or: points[i] = {x=math.random(),y=math.random()}
end
local edges = voronoi.fortunes_algorithm(points,0,0,1,1)
print("Edges: ")
for i, edge in ipairs(edges) do
    print("-",edge.p1.x,edge.p1.y,edge.p2.x,edge.p2.y)
end
local faces = voronoi.find_faces_from_edges(edges, points)
print("Polygons/Faces: ")
for i, face in ipairs(faces) do
    print("- Face nr. "..i)
    for j, point in ipairs(face) do
        print("\t *",point.x,point.y)
    end
end
```

### "Full Documentation" #######################################################

The version of the library is accessible from the `voronoi.version` variable.

#### Types / Objects ###########################################################

Lets first look at the different types of object directly exposed by the
library.

-   **sequence<TYPE>**: A sequence is a table exhibiting only the array part.
    Only keys `1` to `#sequence` is expected to be defined, with only values
    of the type `TYPE`. (Example: sequence<Point> refers to a list of points.)
-   **Point**: A point with only an `x` and `y` coordinate. Defined as
    `{x=x, y=y}`.
-   **Edge**: A line between two Points. Defined as `{p1=p1, p2=p2}`
-   **Face**: A list of Points representing a face of a planar polygon.
    Defined as `sequence<Point>`.

#### Functions #################################################################

Now that we know the definitions of the data-structures, lets look at how to
process them.

##### voronoi.new_point ########################################################

Creates a Point.

**Parameters**
-   `x number`: The x coordinate of the Point.
-   `y number`: The y coordinate of the Point.

**Returns**
-   `Point`: The new Point object.

##### voronoi.fortunes_algorithm ###############################################

Generate the edges of a voronoi graph, based on the received Points.

**Parameters**
-   `points sequence<Point>`: Points to generate the graph from.
-   `p1_x number`: The minimum x of the box.
-   `p1_y number`: The minimum y of the box.
-   `p2_x number`: The maximum x of the box.
-   `p2_y number`: The maximum y of the box.

**Returns**
-   `sequence<Edge>`: The edges of the voronoi graph.

##### voronoi.find_faces_from_edges ############################################

Will find the faces/polygons caused by the edges, created in
`voronoi.fortunes_algorithm`.

It does this by finding the nearest edge to every point, used in generating the
graph.

**Parameters**
-   `edges sequence<Edge>`: The Edges of the graph.
-   `points sequence<Point>`: The Points used to generate the graph.

**Returns**
-   `sequence<Face>`: The Faces of the voronoi graph.

## License & Credits ###########################################################

The license can be found in `LICENSE.txt`, or along with the credits in [in the
top level documentation](../README.md).
