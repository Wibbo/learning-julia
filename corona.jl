module corona

    mutable struct Position
        x::Int
        y::Int
    end

    struct InfectionRadius
        width::Int
        height::Int
    end

    struct Size
        width::Int
        height::Int
    end

abstract type Creature end

position(c::Creature) = c.position
size(c::Creature) = c.size
infection_radius(c::Creature) = c.infection_radius
shape(c::Creature) = :unknown

end # module
