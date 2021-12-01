parse_input(file) = parse.(Int,split(read(file,String),'\n',keepempty=false))

count_increase(vals) = sum(diff(vals) .> 0)
window_sum(vals,win) = [ sum(vals[i:i+win-1]) for i in 1:(length(vals)-win+1)  ]

day1_1() = count_increase(parse_input("input.txt"))
day1_2() = count_increase(window_sum(parse_input("input.txt"),3))
