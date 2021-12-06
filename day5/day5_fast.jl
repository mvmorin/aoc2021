function parse_input(file)
	substrs = split(read(file,String), '\n', keepempty=false)

	function extract(s)
		m = match(r"([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)", s)
		return tuple(parse.(Int,m.captures)...)
	end

	return extract.(substrs)
end

function add_line!(field,x1,x2,y1,y2)
	d1 = sign(y1-x1)
	d2 = sign(y2-x2)
	len = max(abs(y1-x1), abs(y2-x2))

	for t = 0:len
		p1 = x1 + t*d1
		p2 = x2 + t*d2
		field[p1+1,p2+1] += 1
	end
end

isdiagonal(line) = isdiagonal(line...)
isdiagonal(x1,x2,y1,y2) = (x1 != y1) && (x2 != y2)

max_coord_1(line) = max(line[1], line[3])
max_coord_2(line) = max(line[2], line[4])
max_coord(lines) = (maximum(max_coord_1.(lines)),maximum(max_coord_2.(lines)))

function count_intersections(lines)
	field = zeros(Int, max_coord(lines).+1 ...)
	for l in lines
		add_line!(field,l...)
	end
	return sum(p->p>=2, field)
end

day5_1() = count_intersections(filter(!isdiagonal, parse_input("input.txt")))
day5_2() = count_intersections(parse_input("input.txt"))
