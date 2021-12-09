parse_input(file) = parse.(Int,hcat(collect.(split(read(file, String),'\n',keepempty=false))...))

function local_min(m,i,j)
	imax, jmax = size(m)
	return (!(i+1 <= imax) || m[i,j] < m[i+1,j]) &&
		   (!(i-1 >=    1) || m[i,j] < m[i-1,j]) &&
		   (!(j+1 <= jmax) || m[i,j] < m[i,j+1]) &&
		   (!(j-1 >=    1) || m[i,j] < m[i,j-1])
end

function find_local_mins(m)
	mins = Dict{Tuple{Int,Int}, Int}()
	imax, jmax = size(m)
	for j in 1:jmax, i in 1:imax
		local_min(m,i,j) && (mins[(i,j)] = 1 + m[i,j])
	end
	return mins
end

function find_basins(map)
	mins = keys(find_local_mins(map))

	# create a working map of the basins
	basins = similar(map)
	basins[map .== 9] .= 0 # 0 is a basin barrier
	basins[map .< 9] .= -1 # negative value indicate unexplored space
	for (idx, (i, j)) in enumerate(mins)
		basins[i,j] = idx # Any positive value is the index of a basin
	end

	function explore(m,i,j)
		# if the point was unexplored, find the biggest explored neighbour and
		# become the same. return whether the point was unexplored or not
		m[i,j] != -1 && return false

		imax, jmax = size(m)
		north = (i == imax) ? -1 : m[i+1,j]
		south = (i == 1) ? -1 : m[i-1,j]
		east = (j == jmax) ? -1 : m[i,j+1]
		west = (j == 1) ? -1 : m[i,j-1]
		neighbour = max(north, south, east, west)
		neighbour > 0 && (m[i,j] = neighbour)
		return true
	end

	function try_explore_all(m)
		# explore all points in the map, returns whether any unexplored points
		# was found
		imax, jmax = size(m)
		was_explored = false
		for j in 1:jmax, i in 1:imax
			was_explored |= explore(m,i,j)
		end
		return was_explored
	end

	while try_explore_all(basins) end # explore until there are no unexplored spaces left

	return basins, length(mins)
end

function find_basins_2(map)
	function find_basin(map,i,j,visited)
		visited .= false
		imax, jmax = size(map)

		neighbours = [(i,j)]
		visited[i,j] = true
		basin = Vector{Tuple{Int,Int}}(undef,0)

		while length(neighbours) > 0
			i,j = pop!(neighbours)
			push!(basin, (i,j))

			i < imax && !visited[i+1,j] && map[i+1,j] < 9 && (push!(neighbours, (i+1,j)); visited[i+1,j] = true)
			i > 1    && !visited[i-1,j] && map[i-1,j] < 9 && (push!(neighbours, (i-1,j)); visited[i-1,j] = true)
			j < jmax && !visited[i,j+1] && map[i,j+1] < 9 && (push!(neighbours, (i,j+1)); visited[i,j+1] = true)
			j > 1    && !visited[i,j-1] && map[i,j-1] < 9 && (push!(neighbours, (i,j-1)); visited[i,j-1] = true)
		end

		return basin
	end

	mins = keys(find_local_mins(map))
	visited = similar(map, Bool)
	basins = [find_basin(map,i,j,visited) for (i,j) in mins]

	return basins, length(mins)
end

day9_1() = sum(values(find_local_mins(parse_input("input.txt"))))

function day9_2()
	map = parse_input("input.txt")
	basins, n_basins = find_basins(map)
	basin_size(basins, index) = sum(p->p==index, basins)

	sizes = basin_size.(Ref(basins), 1:n_basins)
	sort!(sizes)
	return reduce(*,sizes[end-2:end])
end

function day9_2_alt()
	map = parse_input("input.txt")
	basins, n_basins = find_basins_2(map)
	basin_size(basins, index) = length(basins[index])

	sizes = basin_size.(Ref(basins), 1:n_basins)
	sort!(sizes)
	return reduce(*,sizes[end-2:end])
end

