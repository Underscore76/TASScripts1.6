function V(x, y)
    return Vector2(x, y)
end

local nav_mesh = {
    beach = {
        mountain = {
            V(54, 84), V(50, 71), V(50, 61),
            V(49, 40), V(70, 21), V(70, 18), V(71, 15), V(75, 12), V(77, 11), V(79, 8)
        }
    }
}

return {
    nav_mesh = nav_mesh
}
