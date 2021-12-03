using LinearAlgebra

parse_input(file) = split(read(file,String),'\n',keepempty=false)
parse_digits_by_pos(strs) = [parse.(Int,getindex.(strs,i)) for i in 1:length(strs[1])]
binvec2int(b) = dot(b, 2 .^((length(b)-1):-1:0))

most_common(digits) = sum(digits) >= length(digits)/2
least_common(digits) = length(digits) == 1 ? Bool(digits[1]) : !most_common(digits)

filter_down(digits_by_pos, sel_f) = filter_down(digits_by_pos,1,sel_f)
function filter_down(digits_by_pos,i,sel_f)
	i == length(digits_by_pos) && return [b[1] for b in digits_by_pos]

	selection = sel_f(digits_by_pos[i]) .== digits_by_pos[i]
	filtered = [pos[selection] for pos in digits_by_pos]

	filter_down(filtered, i+1, sel_f)
end

function day3_1()
	digits_by_pos = parse_digits_by_pos(parse_input("input.txt"))

	most_common_digits = most_common.(digits_by_pos)
	gamma = binvec2int(most_common_digits)
	epsilon = binvec2int(.!most_common_digits)

	return gamma*epsilon
end

function day3_2()
	digits_by_pos = parse_digits_by_pos(parse_input("input.txt"))

	oxy = binvec2int(filter_down(digits_by_pos, most_common))
	co2 = binvec2int(filter_down(digits_by_pos, least_common))

	return oxy*co2
end
