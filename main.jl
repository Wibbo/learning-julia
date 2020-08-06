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

#Create a people array.
people = Array{corona.Person}(undef, total_people)

"""
Creates a person.
name: The person's name.
area: A square area around a person that defines when it is possible for them to become infected.
status: The person's status which can be Healthy, Infected or Immune.
"""
function create_person(name::String; area::Int=10, status::corona.Status=corona.Healthy, prob=20)
    pos = corona.Position(rand(1:world_width), rand(1:world_height))
    return corona.Person(name, pos, area, status, prob)
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

for z in 1:100

    th = 0
    ti = 0
    tm = 0

    # Analyse the grid to see which healthy people are too close to infected ones.
    for ip in people

        if ip.status == corona.Healthy
            th += 1
        end

        if ip.status == corona.Infected
            ti += 1
        end

        if ip.status == corona.Immune
            tm += 1
        end

        if ip.status == corona.Infected
            for hp in people
                if corona.infection_risk(ip, hp)
                    infected = "$(ip.name) [$(ip.position.x),$(ip.position.y)]"
                    healthy = "$(hp.name) [$(hp.position.x),$(hp.position.y)]"
                    println(infected * " danger to " * healthy)

                    infect = rand(1:100)
                    if infect < ip.probability
                        hp.status = corona.Infected
                    end
                end
            end
        end
    end
end


println("Total healthy is $(th)")
println("Total infected is $(ti)")
println("Total immune is $(tm)")
