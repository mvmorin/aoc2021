parse_input(file) = parse.(Int,hcat(collect.(split(read(file, String), '\n', keepempty=false))...))

function take_step!(octos, flashed)
	imax, jmax = size(octos)
	flashed .= false
	octos .+= 1

	triggered = getproperty.(findall(>=(10), octos), :I)
	check_and_push!(i,j) = !flashed[i,j] && 10 <= (octos[i,j] +=1) && push!(triggered, (i,j))

	while length(triggered) > 0
		i,j = pop!(triggered)

		if !flashed[i,j]
			flashed[i,j] = true
			i < imax && check_and_push!(i+1,j)
			i > 1    && check_and_push!(i-1,j)
			j < jmax && check_and_push!(i,j+1)
			j > 1    && check_and_push!(i,j-1)
			(i < imax && j < jmax) && check_and_push!(i+1,j+1)
			(i > 1    && j < jmax) && check_and_push!(i-1,j+1)
			(i < imax && j > 1   ) && check_and_push!(i+1,j-1)
			(i > 1    && j > 1   ) && check_and_push!(i-1,j-1)
		end
	end

	octos[flashed] .= 0

	return sum(flashed)
end

function day11_1()
	octos = parse_input("input.txt")
	flashed = similar(octos, Bool)

	sum = 0
	for _ = 1:100
		sum += take_step!(octos, flashed)
		# sum += take_step_2!(octos, flashed)
	end
	return sum
end

function day11_2()
	octos = parse_input("input.txt")
	flashed = similar(octos, Bool)

	step = 1
	while take_step!(octos, flashed) != 100
		step += 1
	end
	return step
end
