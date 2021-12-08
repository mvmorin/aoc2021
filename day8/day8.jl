function parse_input(file)
	raw = split(read(file,String), "\n", keepempty=false)
	events = [collect.(split(s, (' ', '|'), keepempty=false)) for s in raw]
	outputs = [e[end-3:end] for e in events]
	return events, outputs
end

function day8_1()
	_, outputs = parse_input("input.txt")
	is1478(str) = (l = length(str); l==2 || l==4 || l==3 || l==7)
	return sum(e->sum(is1478, e), outputs)
end

function day8_2()
	events, outputs = parse_input("input.txt")
	digit_maps = decode_digit_map.(events)
	outputs = decode_output.(outputs, digit_maps)
	sum(outputs)
end

function decode_output(output, digit_map)
	sum = 0
	for (i,digit) in enumerate(output)
		sum += decode_digit(digit, digit_map)*10^(4-i)
	end
	return sum
end

function decode_digit(digit, digit_map)
	for pair in digit_map
		issetequal(digit, pair.second) && return pair.first
	end
	error("Unknown digit")
end

function decode_digit_map(event)
	# An event needs to contain 1,4 for this algorithm to work. Luckily all
	# events satisfy this

	digit_map = Dict()
	possible069 = filter(e -> length(e) == 6, event)
	possible235 = filter(e -> length(e) == 5, event)
	possible1478 = setdiff(event, possible069, possible235)

	for entry in possible1478
		len = length(entry)

		digit =
			len == 2 ? 1 :
			len == 4 ? 4 :
			len == 3 ? 7 : 8
		digit_map[digit] = entry
	end

	for entry in possible069
		digit =
			issubset(digit_map[4], entry) ? 9 :
			issubset(digit_map[1], entry) ? 0 : 6
		digit_map[digit] = entry
	end

	for entry in possible235
		digit =
			issubset(digit_map[1], entry) ? 3 :
			issubset(setdiff(digit_map[4],digit_map[1]), entry) ? 5 : 2
		digit_map[digit] = entry
	end

	return digit_map
end
