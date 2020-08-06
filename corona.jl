# Create a module to avoid namespace collisions.
module corona

# All living entities are a Creature.
abstract type Creature end

# Define the possible statuses for a person.
@enum Status Healthy Infected Immune

# Create a struct to hold a person's position.
mutable struct Position
    x::Int
    y::Int
end

# Create a struct to define each person's radius of infection.
struct Infection_Radius
    width::Int
    height::Int
end

# Define the physical bounds of each person.
struct Creature_Area
    top::Int
    left::Int
    bottom::Int
    right::Int

    Creature_Area(p::Position, r::Infection_Radius) =
        new(p.y+r.height, p.x, p.y, p.x+r.width)
end

"""
Determines if a person is within someone's infection radius.
Returns True if they are and False otherwise.
"""
function distance_violated(P1::Creature_Area, P2::Creature_Area)
    return P1.left < P2.right && P1.right > P2.left &&
        P1.top > P2.bottom && P1.bottom < P2.top
end

function infection_risk(creature1::Creature, creature2::Creature)
    println("Checking collision of thing vs. thing")
    creature1_space = Creature_Area(position(creature1), size(creature1))
    creature2_space = Creature_Area(position(creature2), size(creature2))
    return distance_violated(rectA, rectB)
end

# The following funtions apply to all creatures.
position(c::Creature) = c.position
radius(c::Creature) = c.infection_radius
name(c::Creature) = c.name
status(c::Creature) = c.status

# A Person is a subclass of a Creature.
struct Person<:Creature
    name::String
    position::Position
    radius::Infection_Radius
    status::Status
end



end # corona module
