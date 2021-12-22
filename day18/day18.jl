mutable struct Number
	left::Union{Int,Number}
	right::Union{Int,Number}
end

function Number(s::AbstractString)
	bracket_l = -1
	comma = -1
	bracket_r = -1

	bracket_count = 0
	for (i,c) in enumerate(s)
		if c == '['
			bracket_count += 1
			bracket_count == 1 && (bracket_l = i)
		elseif c == ']'
			bracket_count -= 1
			bracket_count == 0 && (bracket_r = i)
		elseif c == ','
			bracket_count == 1 && (comma = i)
		end
	end
	left = s[bracket_l+1:comma-1]
	right = s[comma+1:bracket_r-1]

	left_int = tryparse(Int, left)
	right_int = tryparse(Int, right)

	left_n = isnothing(left_int) ? Number(left) : left_int
	right_n = isnothing(right_int) ? Number(right) : right_int

	return Number(left_n, right_n)
end

number2string(n::Int) = string(n)
function number2string(n::Number)
	s = "["
	s = s*number2string(n.left)
	s = s*","
	s = s*number2string(n.right)
	s = s*"]"
	return s
end

function parse_input(file)
	raw_numbers = split(read(file,String))
	Number.(raw_numbers)
end

add(a,b) = reduce(Number(a,b))

function Base.reduce(n::Number)
	while explode!(n) || split!(n) end
	return n
end

function explode!(n)
	exploded, _, _ = explode!(n,4)
	return exploded
end

function explode!(n, depth)
	if depth == 1
		if n.left isa Number
			toaddleft = n.left.left
			toaddright = n.left.right

			n.left = 0
			n.right = add2leftmostint!(n.right, toaddright)

			return true, toaddleft, 0

		elseif n.right isa Number
			toaddleft = n.right.left
			toaddright = n.right.right

			n.right = 0
			n.left = add2rightmostint!(n.left, toaddleft)
			return true, 0, toaddright
		end

		return false, 0,0
	end


	exploded = false
	toaddleft = 0
	toaddright = 0

	if n.left isa Number && !exploded
		exploded, toaddleft, toaddright = explode!(n.left,depth-1)
		n.right = add2leftmostint!(n.right, toaddright)
		toaddright = 0
	end

	if n.right isa Number && !exploded
		exploded, toaddleft, toaddright = explode!(n.right,depth-1)
		n.left = add2rightmostint!(n.left, toaddleft)
		toaddleft = 0
	end

	return exploded, toaddleft, toaddright
end

function add2leftmostint!(n,x)
	if n isa Int
		return n + x
	else
		n.left = add2leftmostint!(n.left, x)
		return n
	end
end

function add2rightmostint!(n,x)
	if n isa Int
		return n + x
	else
		n.right = add2rightmostint!(n.right, x)
		return n
	end
end

split!(n::Int) = false

function split!(n::Number)
	function int2number(x)
		if iseven(x)
			x = Int(x/2)
		else
			x = x/2
		end
		return Number(floor(Int,x),ceil(Int,x))
	end

	split_occured = false
	if n.left isa Int && n.left >= 10
		n.left = int2number(n.left)
		split_occured = true

	elseif split!(n.left)
		split_occured = true

	elseif n.right isa Int && n.right >= 10
		n.right = int2number(n.right)
		split_occured = true

	elseif split!(n.right)
		split_occured = true
	end
	return split_occured
end

magnitude(n::Int) = n
magnitude(n::Number) = 3*magnitude(n.left) + 2*magnitude(n.right)

function day18_1()
	numbers = parse_input("input.txt")

	res = numbers[1]
	for n = numbers[2:end]
		res = add(res,n)
	end
	display(number2string(res))
	magnitude(res)
end

function day18_2()
	raw_numbers = split(read("input.txt",String))

	max_mag = 0
	for n1 = raw_numbers, n2 = raw_numbers
		n1 == n2 && continue

		a = Number(n1)
		b = Number(n2)
		s = add(a,b)
		max_mag = max(max_mag, magnitude(s))
	end
	return max_mag
end
