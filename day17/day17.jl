function parse_input(file)
	raw = read(file, String)
	m = match(r"target area: x=(-*[0-9]+)..(-*[0-9]+), y=(-*[0-9]+)..(-*[0-9]+)", raw)
	bounds = parse.(Int, m.captures)
	return bounds[1]:bounds[2], bounds[3]:bounds[4]
end

function day17_1()
	_, y_target = parse_input("input.txt")
	# _, y_target = parse_input("test.txt")
	vy = -first(y_target)-1
	Int((vy+1)*(vy+1-1)/2)
end

function day17_2()
	x_target, y_target = parse_input("input.txt")
	# x_target, y_target = parse_input("test.txt")

	vy_target = first(y_target):(-first(y_target)-1)
	vx_target = ceil(Int,-0.5 + sqrt(0.25 + 2*first(x_target))):last(x_target)

	hits = Set{Tuple{Int,Int}}()
	for vx = vx_target, vy = vy_target
		hits_target(vx,vy, x_target, y_target) && push!(hits, (vx,vy))
	end

	return length(hits)
end

function hits_target(vx, vy, x_target, y_target)
	x = y = 0

	while !(x in x_target) || !(y in y_target)

		(x > last(x_target) || y < first(y_target) ) && return false

		x += vx
		y += vy
		vx -= sign(vx)
		vy -= 1
	end

	return true
end
