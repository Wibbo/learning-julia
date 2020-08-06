include("corona.jl")

# A place to store people.
people = Array{Person, 1}

for i in 1:10

    pos = corona.Position(rand(1:1000), rand(1:1000))
    radius = corona.Infection_Radius(rand(5:20), rand(5:20))
    p1 = corona.Person("Person $i",
                       pos,
                       radius,
                       corona.Healthy)

    println("Name $(p1.name) at ($(p1.position.x),$(p1.position.y))
        with radius ($(p1.radius.width),$(p1.radius.height))
        is $(p1.status)")


end
