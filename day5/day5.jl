struct Line
	# represents a line as x + t*v where 0 <= t <= len
	x1::Int
	x2::Int

	len::Int

	v1::Int
	v2::Int

	function Line(x1,x2,y1,y2)
		# dir1 == dir2  or one of them is zero
		dir1 = y1 - x1
		dir2 = y2 - x2

		len = max(abs(dir1), abs(dir2))

		v1 = len == 0 ? 1 : sign(dir1) # never let the direction be zero
		v2 = sign(dir2)

		new(x1,x2, len, v1,v2)
	end
end

n_points(l::Line) = 1 + l.len

function Line(s::AbstractString)
	m = match(r"([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)", s)
	return Line(parse.(Int,m.captures)...)
end

parse_input(file) = Line.(split(read(file,String), '\n', keepempty=false))
are_parallel(v1,v2,u1,u2) = (v1*u1 + v2*u2)^2 == (v1^2+v2^2)*(u1^2 + u2^2)

# returns the number intersections points and writes the t:s such that the intersections are given by in l1.x + t*l1.v to the params vector
function get_intersection!(params,l1,l2)
	if !are_parallel(l1.v1,l1.v2, l2.v1,l2.v2) # not parallel lines # solve [l1.v, -l2.v][t1; t2] = l2.x - l1.x
		return get_intersection_nonpara!(params,l1,l2)
	else # parallel lines
		return get_intersection_para!(params,l1,l2)
	end
end

function get_intersection_nonpara!(params,l1,l2)
	# Solve the system [l1.v, -l2.v]*[t1;t2] = l2.x - l1.x
	d = (l1.v1)*(-l2.v2) - (-l2.v1)*(l1.v2)
	t1 = 1/d*( (-l2.v2)*(l2.x1 - l1.x1) + (l2.v1)*(l2.x2 - l1.x2) )
	t2 = 1/d*( (-l1.v2)*(l2.x1 - l1.x1) + (l1.v1)*(l2.x2 - l1.x2) )

	!isinteger(t1) && return 0
	t1 = Int(t1)
	t2 = Int(t2)

	if 0 <= t1 <= l1.len && 0 <= t2 <= l2.len
		params[1] = t1
		return 1
	end

	return 0
end

function get_intersection_para!(params,l1,l2)
	xdiff1 = l2.x1 - l1.x1
	xdiff2 = l2.x2 - l1.x2
	!are_parallel(l1.v1,l1.v2, xdiff1, xdiff2) && return 0 # can't intersect if difference between start point not parallel to directions of lines

	# here we find all t1 such that [l1.v, -l2.v]*[t1;t2] = l2.x - l1.x
	if l1.v1 != 0
		m = (l2.x1-l1.x1)*l1.v1 # this should really be devided by l1.v1 but since l1.v1 is either 1 or -1 it is equivalent and always give integers
		k = l2.v1*l1.v1
	else
		m = (l2.x2-l1.x2)*l1.v2 # this should really be devided by l1.v1 but since l1.v1 is either 1 or -1 it is equivalent and always give integers
		k = l2.v2*l1.v2
	end
	t1_min = max(0,min(m, m + k*l2.len))
	t1_max = min(l1.len,max(m, m + k*l2.len))
	n_intersect = t1_max - t1_min + 1
	params[1:n_intersect] .= t1_min:t1_max

	return n_intersect
end



function count_crossings(lines)
	crossings = Dict{Tuple{Int,Int},Bool}()
	params = zeros(maximum(n_points.(lines)))

	for i = 1:length(lines)
		l = lines[i]
		for j = (i+1):length(lines)
			for i in 1:get_intersection!(params, l, lines[j])
				crossings[(l.x1 + params[i]*l.v1, l.x2 + params[i]*l.v2)] = true
			end
		end
	end

	return sum(values(crossings))
end

function day5_1()
	isdiagonal = l -> abs(l.v1) == abs(l.v2)
	lines = filter(!isdiagonal, parse_input("input.txt"))
	count_crossings(lines)
end

function day5_2()
	lines = parse_input("input.txt")
	count_crossings(lines)
end
