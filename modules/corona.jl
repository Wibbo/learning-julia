# Create a module to avoid namespace collisions.
module corona
export Status
export Direction
export move_person

# All living entities are a Creature.
abstract type Creature end

# Define the possible statuses for a person.
@enum Status Healthy=1 Infected=2 Immune=3 Dead=4
@enum Direction North East South West

# Create a struct to hold a person's position.
mutable struct Position
    x::Int
    y::Int
    radius::Int
end

struct Grid_Area
    x1::Int64
    y1::Int64
    x2::Int64
    y2::Int64
end

# Define the physical bounds of each person.
struct Creature_Area
    x::Int
    y::Int
    r::Int
end

"""
Determines if a person is within someone's infection radius.
Returns True if they are and False otherwise.
"""
function distance_violated(P1::Creature_Area, P2::Creature_Area)
    centres::Float32 = sqrt((P2.x - P1.x)^2 + (P2.y - P1.y)^2)
    return  centres <= (P1.r + P2.r)
end

function infection_risk(creature1::Creature, creature2::Creature)
    creature1_space = Creature_Area(creature1.position.x, creature1.position.y, creature1.position.radius)
    creature2_space = Creature_Area(creature2.position.x, creature2.position.y, creature2.position.radius)
    return distance_violated(creature1_space, creature2_space)
end

# The following funtions apply to all creatures.
name(c::Creature) = c.name
position(c::Creature) = c.position
status(c::Creature) = c.status
infection_chance(c::Creature) = c.infection_chance
direction(c::Creature) = c.direction
chance_of_death(c::Creature) = c.chance_of_death
death_step(c::Creature) = c.death_step
infected_step(c::Creature) = c.infected_step

# A Person is a subclass of a Creature.
mutable struct Person<:Creature
    name::String
    position::Position
    status::Status
    infection_chance:: Int
    direction:: Direction
    chance_of_death::Int
    death_step::Int
    infected_step::Int
end

function move_left!(c::Creature, amount::Int, g::Grid_Area)
    c.position.x -= amount

    if c.position.x <= 0
        c.position.x = 0
        c.direction = East
    end
end

function move_right!(c::Creature, amount::Int, g::Grid_Area)
    c.position.x += amount

    if c.position.x >= g.x2
        c.position.x = g.x2
        c.direction = West
    end
end

function move_up!(c::Creature, amount::Int, g::Grid_Area)
    c.position.y += amount

    if c.position.y >= g.y2
        c.position.y = g.y2
        c.direction = South
    end
end

function move_down!(c::Creature, amount::Int, g::Grid_Area)
    c.position.y -= amount

    if c.position.y <= 0
        c.position.y = 0
        c.direction = North
    end
end

function move_north!(c::Creature, min::Int64, max::Int64, g::Grid_Area)
    dir = Bool(rand(0:1))
    min1::Int64 = div(min, 2)
    max1::Int64 = div(max, 2)
    steps = rand(min:max)
    steps1 = rand(min1:max1)
    move_up!(c, steps, g)
    dir ? move_left!(c, steps1, g) : move_right!(c, steps1, g)
end

function move_south!(c::Creature, min::Int64, max::Int64, g::Grid_Area)
    dir = Bool(rand(0:1))
    min1::Int64 = div(min, 2)
    max1::Int64 = div(max, 2)
    steps = rand(min:max)
    steps1 = rand(min1:max1)
    move_down!(c, steps, g)
    dir ? move_left!(c, steps1, g) : move_right!(c, steps1, g)
end

function move_east!(c::Creature, min::Int64, max::Int64, g::Grid_Area)
    dir = Bool(rand(0:1))
    min1::Int64 = div(min, 2)
    max1::Int64 = div(max, 2)
    steps = rand(min:max)
    steps1 = rand(min1:max1)
    move_right!(c, steps, g)
    dir ? move_up!(c, steps1, g) : move_down!(c, steps1, g)
end

function move_west!(c::Creature, min::Int64, max::Int64, g::Grid_Area)
    dir = Bool(rand(0:1))
    min1::Int64 = div(min, 2)
    max1::Int64 = div(max, 2)
    steps = rand(min:max)
    steps1 = rand(min1:max1)
    move_left!(c, steps, g)
    dir ? move_up!(c, steps1, g) : move_down!(c, steps1, g)
end

function move_person(c::Creature, min::Int, max::Int, g::Grid_Area)
    if c.direction == North
        move_north!(c::Creature, min::Int, max::Int, g::Grid_Area)
    elseif c.direction == East
        move_east!(c::Creature, min::Int, max::Int, g::Grid_Area)
    elseif c.direction == South
        move_south!(c::Creature, min::Int, max::Int, g::Grid_Area)
    elseif c.direction == West
        move_west!(c::Creature, min::Int, max::Int, g::Grid_Area)
    else
        throw(InvalidStateException("Invalid direction for movement."))
    end
end


end # corona module
