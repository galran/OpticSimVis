
# declaration of basic types 
abstract type AbstractScene end
abstract type AbstractSceneObject end


function tr2affine(tr::Transform)
    return AffineMap(tr[1:3,1:3], Geometry.origin(tr))
end



