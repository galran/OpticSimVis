

using Blink

using MeshCat
using CoordinateTransformations
using Rotations
using GeometryBasics: HyperRectangle, Vec, Point, Mesh
using Colors: RGBA, RGB


if (false)
    vis = Visualizer()
    open(vis, Blink.Window())
end


# box = HyperRectangle(Vec(0., 0, 0), Vec(1., 1, 1))
# setobject!(vis, box)
# settransform!(vis, Translation(0., 1, 0))


green_box_vis = setobject!(vis["group1"]["greenbox"], box, green_material)
settransform!(green_box_vis, Translation(0, 0, 1))
group1 = vis["group1"]
settransform!(group1, Translation(0, 0, -1))
