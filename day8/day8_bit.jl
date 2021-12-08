using Combinatorics

const Signal = UInt8 # bit representation as 0b0<g><f><e><d><c><b><a>

const valid_signals = (
		    #gfedcba
	Signal(0b1110111), #0
	Signal(0b0100100), #1
	Signal(0b1011101), #2
	Signal(0b1101101), #3
	Signal(0b0101110), #4
	Signal(0b1101011), #5
	Signal(0b1111011), #6
	Signal(0b0100101), #7
	Signal(0b1111111), #8
	Signal(0b1101111), #9
	)

function tosignal(c::AbstractChar)
	offset = findfirst(c, "abcdefg") - 1
	return Signal(0b1 << offset)
end

function tosignal(str::AbstractString)
	sig = Signal(0b0)
	for c in str
		sig |= tosignal(c)
	end
	return sig
end

function parse_input(file)
	raw = split(read(file,String), "\n", keepempty=false)
	events = [tosignal.(split(s, (' ', '|'), keepempty=false)) for s in raw]
	observations = [e[1:end-4] for e in events]
	outputs = [e[end-3:end] for e in events]

	return observations, outputs
end



function invpermute(s::Signal, perm)
	s_perm = Signal(0b0)
	for (i,p) in enumerate(perm)
		s_perm |= ( (s & (0b1 << (i-1))) >> (i-1) ) << (p-1)
	end
	return Signal(s_perm)
end

is_valid(s, valids) = mapreduce(==(s), |, valids, init=false)
is_valid_observation(obs, valids) = mapreduce(o->is_valid(o,valids), &, obs, init=true)

function decode_event(obs,out, valid_signals)
	for (i,vs) in enumerate(valid_signals)
		is_valid_observation(obs,vs) && return decode_output(out,vs), i
	end
end

function decode_output(out, valids)
	function find_digit(s, valids)
		for (i,vs) in enumerate(valids)
			s == vs && return i-1
		end
		error("Unknown digit")
	end

	sum = 0
	for (i,s) in enumerate(out)
		sum += find_digit(s,valids)*10^(4-i)
	end
	return sum
end



function day8_2()
	observations, outputs = parse_input("input.txt")

	perms = collect(permutations(1:7))
	invperm_valid_signals = [invpermute.(valid_signals, Ref(p)) for p in perms]

	sum = 0
	for (obs, out) in zip(observations, outputs)
		res, perm_i = decode_event(obs, out, invperm_valid_signals)
		println(res, " ", perms[perm_i])
		sum += res
	end
	return sum
end
