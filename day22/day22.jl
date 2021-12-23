struct Cuboid
	x::UnitRange{Int}
	y::UnitRange{Int}
	z::UnitRange{Int}
end

function parse_input(file)
	raw_commands = split(read(file, String), '\n', keepempty=false)

	function parse_command(str)
		r = r"(on|off) x=(-*[0-9]+)..(-*[0-9]+),y=(-*[0-9]+)..(-*[0-9]+),z=(-*[0-9]+)..(-*[0-9]+)"
		m = match(r, str)
		xyz = parse.(Int, m.captures[2:end])
		c = Cuboid(xyz[1]:xyz[2], xyz[3]:xyz[4], xyz[5]:xyz[6])
		on = m.captures[1] == "on"
		return on, c
	end

	parse_command.(raw_commands)
end

function cuboid_is_small(c)
	xl, xu = first(c.x), last(c.x)
	yl, yu = first(c.y), last(c.y)
	zl, zu = first(c.z), last(c.z)

	return abs(xl) <= 50 && abs(xu) <= 50 &&
		abs(yl) <= 50 && abs(yu) <= 50 &&
		abs(zl) <= 50 && abs(zu) <= 50
end

Base.length(c::Cuboid) = length(c.x)*length(c.y)*length(c.z)

function intersection(c1::Cuboid,c2::Cuboid)
	x = intersect(c1.x, c2.x)
	y = intersect(c1.y, c2.y)
	z = intersect(c1.z, c2.z)
	return Cuboid(x,y,z)
end

function cuboid_diff(a, b)
	b = intersection(a,b)

	xright = intersect(a.x, last(b.x)+1:last(a.x))
	xleft = intersect(a.x, first(a.x):first(b.x)-1)
	cright = Cuboid(xright, a.y, a.z)
	cleft = Cuboid(xleft, a.y, a.z)

	yin = intersect(a.y, last(b.y)+1:last(a.y))
	yout = intersect(a.y, first(a.y):first(b.y)-1)
	cin = Cuboid(b.x, yin, a.z)
	cout = Cuboid(b.x, yout, a.z)

	zup = intersect(a.z, last(b.z)+1:last(a.z))
	zdown = intersect(a.z, first(a.z):first(b.z)-1)
	cup = Cuboid(b.x, b.y, zup)
	cdown = Cuboid(b.x, b.y, zdown )

	splits = [cright, cleft, cin, cout, cup, cdown]
	return [c for c in splits if length(c) > 0]
end

function remove_overlapping(cs, overlapping)
	new = similar(cs, 0)
	for c in cs
		append!(new, cuboid_diff(c, overlapping))
	end
	return new
end

function add_nonoverlapping(cs, new)
	cuboids = remove_overlapping(cs, new)
	push!(cuboids, new)
	return cuboids
end


function day22_1()
	cmds = parse_input("input.txt")
	# cmds = parse_input("test.txt")
	cmds = filter(cmd->cuboid_is_small(last(cmd)), cmds)

	lit = Cuboid[]
	for (cmd_state, cuboid) in cmds
		if cmd_state
			lit = add_nonoverlapping(lit, cuboid)
		else
			lit = remove_overlapping(lit, cuboid)
		end
	end
	return sum(length, lit)
end

function day22_2()
	cmds = parse_input("input.txt")
	# cmds = parse_input("test.txt")

	lit = Cuboid[]
	for (cmd_state, cuboid) in cmds
		if cmd_state
			lit = add_nonoverlapping(lit, cuboid)
		else
			lit = remove_overlapping(lit, cuboid)
		end
	end
	return sum(length, lit)
end
