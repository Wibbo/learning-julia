include("corona.jl")
using ConfParser

conf = ConfParse("config.ini")
parse_conf!(conf)

healthy_people = parse(Int, retrieve(conf, "PEOPLE", "healthy"))
infected_people = parse(Int, retrieve(conf, "PEOPLE", "infected"))
immune_people = parse(Int, retrieve(conf, "PEOPLE", "immune"))
total_people = healthy_people + infected_people + immune_people

people = Array{corona.Person}(undef, total_people)

function create_person(name::String; area::Int=10, status::corona.Status=corona.Healthy)
    pos = corona.Position(rand(1:100), rand(1:100))
    return corona.Person(name, pos, area, status)
end

for i in 1:healthy_people
    p = create_person("Person $i")

    pos1 = p.position.x
    pos2 = p.position.y
    people[i] = p
end

for i in healthy_people + 1:infected_people
    p = create_person("Person $i", area=30, status=corona.Infected)

    pos1 = p.position.x
    pos2 = p.position.y
    people[i] = p
end

for i in healthy_people + 1:infected_people
    ip = people[i]

    for j in 1:healthy_people
        hp = people[j]
        if corona.infection_risk(ip, hp)
            infected = "$(ip.name) [$(ip.position.x),$(ip.position.y)]"
            healthy = "$(hp.name) [$(hp.position.x),$(hp.position.y)]"
            println(infected * " danger to " * healthy)
        end
    end

end
