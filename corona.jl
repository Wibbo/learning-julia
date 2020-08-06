# Create a module to avoid namespace collisions.
module corona
export Status

# All living entities are a Creature.
abstract type Creature end

# Define the possible statuses for a person.
@enum Status Healthy Infected Immune

# Create a struct to hold a person's position.
mutable struct Position
    x::Int
    y::Int
end

# Define the physical bounds of each person.
struct Creature_Area
    top::Int
    left::Int
    bottom::Int
    right::Int

    Creature_Area(p::Position, r::Int) = new(p.y+r, p.x, p.y, p.x+r)
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
    creature1_space = Creature_Area(position(creature1), radius(creature1))
    creature2_space = Creature_Area(position(creature2), radius(creature2))
    return distance_violated(creature1_space, creature2_space)
end

# The following funtions apply to all creatures.
name(c::Creature) = c.name
position(c::Creature) = c.position
radius(c::Creature) = c.radius
#status(c::Creature) = c.status

# A Person is a subclass of a Creature.
struct Person<:Creature
    name::String
    position::Position
    radius::Int
    status::Status
end

move_left!(c::Creature, amount::Int)  = c.position.x -= amount
move_right!(c::Creature, amount::Int) = c.position.x += amount
move_up!(c::Creature, amount::Int)    = c.position.y -= amount
move_down!(c::Creature, amount::Int)  = c.position.y += amount

end # corona module
