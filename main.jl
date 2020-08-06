include("corona.jl")

people = Array{corona.Person}(undef, 110)

function create_person(name::String, status::corona.Status)
    pos = corona.Position(rand(1:100), rand(1:100))
    radius = rand(5:20)

    return corona.Person(name, pos, radius, status)
end

for i in 1:100
    p = create_person("Person $i", corona.Healthy)
    pos1 = p.position.x
    pos2 = p.position.y
    println("$(p.name) at ($(pos1),$(pos2)) with radius ($(p.radius)) is $(p.status)")
end
