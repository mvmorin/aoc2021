function parse_input(file)
	raw = split(read(file,String), "\n\n", keepempty=false)

	sequence = collect(raw[1])

	insertions = Dict{Tuple{Char,Char},Char}()
	for line in split(raw[2], '\n', keepempty=false)
		m = match(r"([A-Z])([A-Z]) -> ([A-Z])", line)
		a = m.captures[1][1]
		b = m.captures[2][1]
		c = m.captures[3][1]
		insertions[(a,b)] = c
	end

	return sequence, insertions
end

increment_count(counts,key,inc) = (counts[key] = key in keys(counts) ? counts[key] + inc : inc)

function count_pairs(sequence)
	counts = Dict{Tuple{Char,Char},Int}()

	for (a,b) in zip(sequence[1:end-1], sequence[2:end])
		increment_count(counts, (a,b), 1)
	end

	return counts
end

function count_chars(sequence)
	counts = Dict{Char,Int}()
	for c in sequence
		increment_count(counts, c, 1)
	end
	return counts
end

function grow_polymer_counts(pair_counts, char_counts, insertions)
	new_pair_counts = typeof(pair_counts)()
	new_char_counts = copy(char_counts)

	for ((a,b), count) in pair_counts
		c = insertions[(a,b)]
		increment_count(new_pair_counts, (a,c), count)
		increment_count(new_pair_counts, (c,b), count)

		increment_count(new_char_counts, c, count)
	end

	return new_pair_counts, new_char_counts
end

function day14_1()
	seq, ins = parse_input("input.txt")
	# seq, ins = parse_input("test.txt")

	pair_counts = count_pairs(seq)
	char_counts = count_chars(seq)
	for _ = 1:10
		pair_counts, char_counts = grow_polymer_counts(pair_counts, char_counts, ins)
	end

	return maximum(values(char_counts)) - minimum(values(char_counts))
end

function day14_2()
	seq, ins = parse_input("input.txt")
	# seq, ins = parse_input("test.txt")

	pair_counts = count_pairs(seq)
	char_counts = count_chars(seq)
	for _ = 1:40
		pair_counts, char_counts = grow_polymer_counts(pair_counts, char_counts, ins)
	end

	return maximum(values(char_counts)) - minimum(values(char_counts))
end
