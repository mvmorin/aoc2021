struct Line
	x1::Int
	x2::Int
	y1::Int
	y2::Int
	diag::Bool

	Line(x1,x2,y1,y2) = new(x1,x2,y1,y2, x1 != y1 && x2 != y2)
end

function Line(s::AbstractString)
	m = match(r"([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)", s)
	return Line(parse.(Int,m.captures)...)
end

isdiagonal(line) = line.diag

parse_input(file) = Line.(split(read(file,String), '\n', keepempty=false))


function line2points(line)::Vector{Tuple{Int,Int}}
	diff1 = line.y1 - line.x1
	diff2 = line.y2 - line.x2
	unidiff1 = sign(diff1)
	unidiff2 = sign(diff2)

	n_points = 1 + max(abs(diff1),abs(diff2))

	return [(line.x1+i*unidiff1, line.x2+i*unidiff2) for i in 0:(n_points-1)]
end

function point_on_line(x1::Int,x2::Int,line)
	on2 = (line.x1 <= x1 <= line.y1) || (line.y1 <= x1 <= line.x1)
	on1 = (line.x2 <= x2 <= line.y2) || (line.y2 <= x2 <= line.x2)
	diag = !isdiagonal(line) || abs(line.x1 - x1) == abs(line.x2 - x2)
	return on1 && on2 && diag
end

function count_crossings(lines)
	crossings = Dict{Tuple{Int,Int},Bool}()

	for i = 1:length(lines)
		points = line2points(lines[i])
		for p in points
			for j = (i+1):length(lines)
				if point_on_line(p[1], p[2],lines[j])
					crossings[p] = true
				end
			end
		end
	end

	return sum(values(crossings))
end

function day5_1()
	lines = filter(!isdiagonal, parse_input("input.txt"))
	count_crossings(lines)
end

function day5_2()
	lines = parse_input("input.txt")
	count_crossings(lines)
end
