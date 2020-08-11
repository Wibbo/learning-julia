using Pkg
pkg"activate ."

include("modules/corona.jl")
using .corona

include("modules/helper.jl")
using .helper

using ConfParser
using DataFrames
using CSV

# Read settings from the ini file.
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
chance_of_dying = parse(Int, retrieve(conf, "PEOPLE", "chance_of_dying"))
min_death_steps = parse(Int, retrieve(conf, "PEOPLE", "min_death_steps"))
max_death_steps = parse(Int, retrieve(conf, "PEOPLE", "max_death_steps"))

"""
Create a person.
name: The person's name.
"""
function create_person(;name::String, status::corona.Status,
                       infection_chance::Int, chance_of_death::Int,
                       death_step::Int, infected_step::Int)

    radius::Int = 0

    # Set the area of risk around each person.
    status==corona.Infected ? radius=infected_radius : radius = healthy_radius

    pos = corona.Position(rand(0:world_width), rand(0:world_height), radius)
    dir = rand(0:3)
    direction::corona.Direction = corona.Direction(dir)
    return corona.Person(name, pos, status, infection_chance, direction,
                         chance_of_death, death_step, infected_step)
end

"""
Creates a group of people with the specified status and stores them
in the people vector. This call delegates to the create_person function.
"""
function create_people(status::corona.Status, start::Int, stop::Int)

    for i in start:stop
        death_range = rand(min_death_steps:max_death_steps)

        p = create_person(name="Person $i", status=status,
                          infection_chance=probability,
                          chance_of_death=chance_of_dying,
                          death_step=death_range,
                          infected_step=0)
        people[i] = p
    end
end

# Create the world and people arrays.
grid = corona.Grid_Area(0, 0, world_width, world_height)
people = Array{corona.Person}(undef, total_people)

# Create the initial healthy, infected and immune people and store them in
# a people vector for subsequent processing.
create_people(corona.Healthy, 1,healthy_people)
create_people(corona.Infected, healthy_people + 1,infected_people + healthy_people)
create_people(corona.Immune, healthy_people + infected_people+ 1,total_people)




people_counts = [0::Int, 0::Int, 0::Int, 0::Int]

"""
Updates the number of healthy, infected and immune people.
"""
function update_people_counts!(c::corona.Creature)
    if c.status == corona.Healthy
        people_counts[1] += 1
    elseif c.status == corona.Infected
        people_counts[2] += 1
    elseif c.status == corona.Immune
        people_counts[3] += 1
    elseif c.status == corona.Dead
        people_counts[4] += 1
    else
        throw(InvalidStateException("Invalid status for a person."))
    end
end

"""
Resets the people count vector.
"""
function reset_array(a::AbstractVector{Int})
    a[Int(corona.Healthy)] = 0
    a[Int(corona.Infected)] = 0
    a[Int(corona.Immune)] = 0
    a[Int(corona.Dead)] = 0
end

function infect_person!(c::corona.Creature, infected_step::Int)::Bool

    infected_person::Bool = false

    for hp in people
        if corona.infection_risk(c, hp)
            infected = "$(c.name) [$(c.position.x),$(c.position.y)]"
            healthy = "$(hp.name) [$(hp.position.x),$(hp.position.y)]"
            #println(infected * " danger to " * healthy)

            infect = rand(1:100)
            if (infect < c.infection_chance) && (hp.status == corona.Healthy)
                hp.status = corona.Infected
                hp.infected_step = infected_step
                infected_person = true
            end
        end
    end

    return infected_person
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
    println("Total dead is $(people_counts[4])")
end

df = DataFrame(Step = Int[], Healthy = Int[],
    Infected = Int[], Immune = Int[], Dead = Int[])

inf_step = 0

# This is the main application loop. The outer loop
# is the number of iterations that are executed. Or,
# in other words, how many moves each person makes
# in their digital world.
for step in 1:iterations
    reset_array(people_counts)
    # Analyse the grid to see which healthy
    # people are too close to infected ones.
    for ip in people
        update_people_counts!(ip)

        if ip.status == corona.Infected
            # Determine if other people get infected.
            infect_person!(ip, step)

            if step > (ip.infected_step + ip.death_step)
                dead = rand(1:100)
                if dead < ip.chance_of_death
                    ip.status = corona.Dead
                end
            end
        end

        corona.move_person(ip, min_step, max_step, grid)
    end

    list = [step, people_counts[1], people_counts[2],
        people_counts[3], people_counts[4]]
    push!(df, list)
end

CSV.write("./output.csv", df)
report_status!()
