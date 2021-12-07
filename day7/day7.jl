parse_input(file) = parse.(Int, split(read(file,String),',',keepempty=false))

cost_const(c,p) = abs(c-p)
cost_incr(c,p) = (dist = abs(c-p); Int(dist*(1+dist)/2))
total_fuel(pos, crabs, cost) = sum(c -> cost(c,pos), crabs)
min_total_fuel(crabs,cost) = minimum(p -> total_fuel(p,crabs,cost), minimum(crabs):maximum(crabs))

day7_1() = min_total_fuel(parse_input("input.txt"), cost_const)
day7_2() = min_total_fuel(parse_input("input.txt"), cost_incr)
