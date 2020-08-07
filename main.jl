include("corona.jl")
using ConfParser

conf = ConfParse("config.ini")
parse_conf!(conf)

# Get values from the ini file.
healthy_people = parse(Int, retrieve(conf, "PEOPLE", "healthy"))
infected_people = parse(Int, retrieve(conf, "PEOPLE", "infected"))
immune_people = parse(Int, retrieve(conf, "PEOPLE", "immune"))
total_people = healthy_people + infected_people + immune_people
healthy_radius = parse(Int, retrieve(conf, "PEOPLE", "healthy_radius"))
infected_radius = parse(Int, retrieve(conf, "PEOPLE", "infected_radius"))
world_width = parse(Int, retrieve(conf, "WORLD", "width"))
world_height = parse(Int, retrieve(conf, "WORLD", "height"))
probability = parse(Int, retrieve(conf, "PEOPLE", "probability"))
min_step = parse(Int, retrieve(conf, "PEOPLE", "min_step"))
max_step = parse(Int, retrieve(conf, "PEOPLE", "max_step"))
iterations = parse(Int, retrieve(conf, "WORLD", "iterations"))

grid = corona.Grid_Area(0, 0, world_width, world_height)

#Create a people array.
people = Array{corona.Person}(undef, total_people)

function get_direction(d::corona.Direction)
    if d == corona.North
        "North"
    elseif d == corona.East
        "East"
    elseif d == corona.South
        "South"
    elseif d == corona.West
        "West"
    else
        throw(InvalidStateException("Invalid direction for movement."))
    end
end



"""
Creates a person.
name: The person's name.
area: A square area around a person that defines when it is possible for them to become infected.
status: The person's status which can be Healthy, Infected or Immune.
"""
function create_person(name::String; area::Int=10, status::corona.Status=corona.Healthy, prob=20)
    pos = corona.Position(rand(0:world_width), rand(0:world_height))
    dir = rand(0:3)
    dir2::corona.Direction = corona.Direction(dir)
    return corona.Person(name, pos, area, status, prob, dir2)
end

# Create the required number of healthy people.
for i in 1:healthy_people
    p = create_person("Person $i", area=healthy_radius)
    people[i] = p
end

# Create the required number of infected people.
for i in healthy_people + 1:infected_people + healthy_people
    p = create_person("Person $i", area=infected_radius, status=corona.Infected)
    people[i] = p
end

people_counts = [0::Int, 0::Int, 0::Int]

"""
Updates the number of healthy, infected and immune people.
"""
function update_people_counts!(c::corona.Creature)
    if c.status == corona.Healthy
        people_counts[1] += 1
    end

    if c.status == corona.Infected
        people_counts[2] += 1
    end

    if c.status == corona.Immune
        people_counts[3] += 1
    end
end

"""
Resets the people count vector.
"""
function reset_array(a::AbstractVector{Int})
    a[1] = 0
    a[2] = 0
    a[3] = 0
end

function infect_person!(c::corona.Creature)
    for hp in people
        if corona.infection_risk(c, hp)
            infected = "$(c.name) [$(c.position.x),$(c.position.y)]"
            healthy = "$(hp.name) [$(hp.position.x),$(hp.position.y)]"
            println(infected * " danger to " * healthy)

            infect = rand(1:100)
            if infect < c.probability
                hp.status = corona.Infected
            end
        end
    end
end

"""
Creates a string containing status information.
"""
function report_status!()
    world_status = "Total: $(total_people) Prob: $(probability) "
    world_status *= "Radius: $(infected_radius) "
    world_status *= "World: [$world_width, $world_height]"

    println()
    println(world_status)
    println("Total healthy is $(people_counts[1])")
    println("Total infected is $(people_counts[2])")
    println("Total immune is $(people_counts[3])")
end

# This is the main application loop. The outer loop is the number of
# iterations that are executed. Or, in other words, how many moves
# each person makes in their digital world.
for _ in 1:iterations
    reset_array(people_counts)

    # Analyse the grid to see which healthy people are too close to infected ones.
    for ip in people
        update_people_counts!(ip)

        if ip.status == corona.Infected
            infect_person!(ip)
        end

        corona.move_person(ip, min_step, max_step, grid)

        #corona.move_north!(ip, min_step, max_step, grid)
        println("$(ip.name) at [$(ip.position.x), $(ip.position.y)] [D:$(ip.direction)]")
    end
end

report_status!()
