struct WrappedMatrix{T}
	M::Matrix{T}
end

wrap_index(i,j,si,sj) = (i = 1 + (i - 1) % si, j = 1 + (j - 1) % sj)
Base.getindex(m::WrappedMatrix, i,j) = m.M[wrap_index(i,j,size(m.M)...)...]
Base.setindex!(m::WrappedMatrix, x, i,j) = (m.M[wrap_index(i,j,size(m.M)...)...] = x)
Base.size(m::WrappedMatrix) = size(m.M)
Base.display(m::WrappedMatrix) = display(m.M)

parse_input(file) = WrappedMatrix(permutedims(hcat(collect.(split(read(file, String), '\n', keepempty=false))...)))

function step!(map)
	si, sj = size(map)
	movement = false
	should_move = falses(si,sj)

	for j = 1:sj, i = 1:si
		map[i,j] == '>' && (should_move[i,j] = map[i,j+1] == '.')
	end

	for j = 1:sj, i = 1:si
		should_move[i,j] && (map[i,j+1] = '>'; map[i,j] = '.'; movement = true)
		should_move[i,j] = false
	end

	for j = 1:sj, i = 1:si
		map[i,j] == 'v' && (should_move[i,j] = map[i+1,j] == '.')
	end

	for j = 1:sj, i = 1:si
		should_move[i,j] && (map[i+1,j] = 'v'; map[i,j] = '.'; movement = true)
		should_move[i,j] = false
	end

	return map, movement
end

function day25_1()
	map = parse_input("input.txt")

	count = 1
	while true
		map, movement = step!(map)
		if movement
			count += 1
		else
			break
		end
	end

	return count


end
