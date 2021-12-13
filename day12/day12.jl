const Cave = String

isbigcave(c::Cave) = isuppercase(c[1]) # should really check all but...

function get_tunnels(file)
	tunnels_to_str = split.(split(read(file, String), '\n', keepempty=false), '-', keepempty=false)

	tunnels_to = Dict{Cave, Vector{Cave} }()
	add_tunnel(tunnels_to,a,b) = a in keys(tunnels_to) ? push!(tunnels_to[a], b) : (tunnels_to[a] = [b])

	for (from,to) in tunnels_to_str
		add_tunnel(tunnels_to,to,from)
		add_tunnel(tunnels_to,from,to)
	end
	return tunnels_to
end



struct Path
	path::Vector{Cave}
	exception_used::Bool
end
Path(cave::Cave) = Path([cave], false)

Base.last(p::Path) = p.path[end]
Base.in(c::Cave,p::Path) = c in p.path

function add_cave(path::Path, cave::Cave)
	exception_used = path.exception_used || ( !isbigcave(cave) && cave in path )
	return Path([path.path; cave], exception_used)
end



function find_all_paths(tunnels_to, allowed_to_visit, start_cave, end_cave)
	to_explore = [ Path(start_cave) ]
	finished_paths = Path[]

	while length(to_explore) >= 1
		path = pop!(to_explore)

		if last(path) == end_cave
			push!(finished_paths, path)
		else
			for cave in tunnels_to[last(path)]
				allowed_to_visit(cave, path) && push!(to_explore, add_cave(path, cave))
			end
		end
	end

	return finished_paths
end



function day12_1()
	tunnels_to = get_tunnels("input.txt")

	allowed_to_visit(cave, path) =
		!(cave in path && !isbigcave(cave)) && !(cave == "start")

	return length(find_all_paths(tunnels_to, allowed_to_visit, "start", "end"))
end

function day12_2()
	tunnels_to = get_tunnels("input.txt")

	allowed_to_visit(cave, path) =
		!(cave in path && !isbigcave(cave) && path.exception_used) && !(cave == "start")

	return length(find_all_paths(tunnels_to, allowed_to_visit, "start", "end"))
end
