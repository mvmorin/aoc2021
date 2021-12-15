using DataStructures

parse_input(file) = Matrix(parse.(Int,hcat(collect.(split(read(file, String),'\n', keepempty=false))...))')

function astar(start,finish,risks)
	lowest_risk_to_reach = fill(typemax(Int), size(risks))

	exploration_front = PriorityQueue{typeof(start),Int}()
	exploration_front[start...] = 0
	lowest_risk_to_reach[start...] = 0

	h(pos) = sum(abs.(finish .- pos))

	while !isempty(exploration_front)
		cur = dequeue!(exploration_front)

		cur == finish && return lowest_risk_to_reach[cur...]

		function explore!(cur,next)
			!checkbounds(Bool,risks,next...) && return

			risk = lowest_risk_to_reach[cur...] + risks[next...]

			if risk < lowest_risk_to_reach[next...]
				lowest_risk_to_reach[next...] = risk
				exploration_front[next...] = risk + h(next)
			end
		end

		explore!(cur, cur .+ (1,0))
		explore!(cur, cur .- (1,0))
		explore!(cur, cur .+ (0,1))
		explore!(cur, cur .- (0,1))
	end

	return
end

function djikstra(start,finish,risks)
	lowest_risk_to_reach = fill(typemax(Int), size(risks))
	lowest_risk_to_reach[start...] = 0

	exploration_front = PriorityQueue{typeof(start),Int}()
	si, sj = size(risks)
	for i = 1:si, j = 1:sj
		exploration_front[i,j] = lowest_risk_to_reach[i,j]
	end

	while !isempty(exploration_front)
		cur = dequeue!(exploration_front)

		cur == finish && return lowest_risk_to_reach[cur...]

		function explore!(cur,next)
			!checkbounds(Bool,risks,next...) && return
			!(next in keys(exploration_front)) && return

			min_risk = min(
				lowest_risk_to_reach[next...],
				lowest_risk_to_reach[cur...] + risks[next...]
				)
			lowest_risk_to_reach[next...] = min_risk
			exploration_front[next...] = min_risk
		end

		explore!(cur, cur .+ (1,0))
		explore!(cur, cur .- (1,0))
		explore!(cur, cur .+ (0,1))
		explore!(cur, cur .- (0,1))
	end

	return
end

function day15_1()
	risks = parse_input("input.txt")
	# risks = parse_input("test.txt")

	# return astar((1,1), size(risks), risks)
	return djikstra((1,1), size(risks), risks)
end

function day15_2()
	r = parse_input("input.txt")
	# r = parse_input("test.txt")
	si, sj = size(r)
	risks = zeros(si*5, sj*5)
	for i = 0:4, j = 0:4
		risks[1+si*i:si+si*i, 1+sj*j:sj+sj*j] .= r .+ i .+ j
	end
	risks .= 1 .+ (risks .- 1) .% 9

	return astar((1,1), size(risks), risks)
	# return djikstra((1,1), size(risks), risks)
end

