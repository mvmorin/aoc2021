function parse_input(file)
	substrs = split(read(file,String), '\n', keepempty=false)

	function extract(s)
		m = match(r"([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)", s)
		return tuple(parse.(Int,m.captures)...)
	end

	return extract.(substrs)
end

isdiagonal(line) = isdiagonal(line...)
isdiagonal(x1,x2,y1,y2) = (x1 != y1) && (x2 != y2)

max_coord_1(line) = max(line[1], line[3])
max_coord_2(line) = max(line[2], line[4])
max_coord(lines) = (maximum(max_coord_1.(lines)),maximum(max_coord_2.(lines)))

function covers(x1::Int,x2::Int, line)
	on2 = (line[1] <= x1 <= line[3]) || (line[3] <= x1 <= line[1])
	on1 = (line[2] <= x2 <= line[4]) || (line[4] <= x2 <= line[2])
	diag = !isdiagonal(line) || abs(line[1] - x1) == abs(line[2] - x2)
	return on1 && on2 && diag
end

count_covered(x1,x2,lines) = sum(l -> covers(x1,x2,l), lines)

function count_intersections(lines)
	field = zeros(Int, max_coord(lines).+1 ...)
	for j = 1:size(field)[2]
		for i = 1:size(field)[1]
			field[i,j] = count_covered(i,j,lines)
		end
	end
	return sum(p->p>=2, field)
end

day5_1() = count_intersections(filter(!isdiagonal, parse_input("input.txt")))
day5_2() = count_intersections(parse_input("input.txt"))
