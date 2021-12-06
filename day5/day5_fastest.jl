struct Line
	# represents a line as x + t*v where 0 <= t <= len
	x1::Int
	x2::Int

	d1::Int
	d2::Int
	len::Int

	function Line(x1,x2,y1,y2)
		# dir1 == dir2  or one of them is zero
		d1 = sign(y1-x1)
		d2 = sign(y2-x2)
		len = max(abs(y1-x1), abs(y2-x2))

		new(x1,x2,d1,d2,len)
	end
end

function Line(s::AbstractString)
	m = match(r"([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)", s)
	return Line(parse.(Int,m.captures)...)
end

parse_input(file) = Line.(split(read(file,String), '\n', keepempty=false))

function add_line!(field,line)
	for t = 0:line.len
		p1 = line.x1 + t*line.d1
		p2 = line.x2 + t*line.d2
		field[p1+1,p2+1] += 1
	end
end

isdiagonal(line) = abs(line.d1) == abs(line.d2) == 1

function count_intersections(lines)
	field = zeros(Int, 1000, 1000)
	for l in lines
		add_line!(field,l)
	end
	return sum(p->p>=2, field)
end

day5_1() = count_intersections(filter(!isdiagonal, parse_input("input.txt")))
day5_2() = count_intersections(parse_input("input.txt"))
