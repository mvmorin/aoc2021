function parse_bits(file)
	raw = strip(read(file,String))
	mapreduce(reverse,vcat, digits(Bool, hex2bytes(raw[i:i+1])[1], base=2, pad=8) for i = 1:2:length(raw))
end

function bits2uint(bits, first, len)
	last = first+len-1
	res = 0
	for i = first:last
		res += bits[i]*2^(last - i)
	end
	return res, last+1
end



struct Packet
	version::Int
	typeID::Int
	literal::Int
	subpackets::Vector{Packet}
end

parse_packet(bits) = parse_packet(bits,1)[1]

function parse_packet(bits, idx)
	version, idx = bits2uint(bits, idx, 3)
	typeID, idx = bits2uint(bits, idx, 3)

	if typeID == 4
		literal, idx = parse_literal(bits, idx)
		subpackets = Packet[]
	else
		subpackets, idx = parse_subpackets(bits, idx)
		literal = 0
	end

	return Packet(version, typeID, literal, subpackets), idx
end

function parse_literal(bits, idx)
	literal_bits = similar(bits,0)

	last_chunk = false
	while !last_chunk
		last_chunk = (bits[idx] == 0)
		append!(literal_bits, bits[idx+1:idx+4])
		idx += 5
	end

	literal, _ = bits2uint(literal_bits,1,length(literal_bits))
	return literal, idx
end

function parse_subpackets(bits, idx)
	mode = bits[idx]
	idx += 1

	if mode == 0
		payload_length, idx = bits2uint(bits, idx, 15)
		subpacket_end = idx + payload_length
		nbr_subpackets = -1
	else
		nbr_subpackets, idx = bits2uint(bits, idx, 11)
		subpacket_end = -1
	end

	packets = Packet[]
	while idx < subpacket_end || length(packets) < nbr_subpackets
		p, idx = parse_packet(bits, idx)
		push!(packets, p)
	end

	return packets, idx
end



function sum_version_numbers(p::Packet)::Int
	version_sum = p.version
	for sp in p.subpackets; version_sum += sum_version_numbers(sp); end
	return version_sum
end

function evaluate_packet(p::Packet)
	p.typeID == 4 && return p.literal
	ops = [+, *, min, max, missing, >, <, ==]
	return ops[p.typeID+1](evaluate_packet.(p.subpackets)...)
end



day16_1() = sum_version_numbers(parse_packet(parse_bits("input.txt")))
day16_2() = evaluate_packet(parse_packet(parse_bits("input.txt")))
