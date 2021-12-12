parse_input(file) = collect.(split(read(file, String), '\n', keepempty=false))

function score_corrupt_line(line)
	scores = Dict(')'=>3, ']'=>57, '}'=>1197, '>'=>25137,)
	lefts = ('(', '[', '{', '<')
	rights = Dict('('=>')', '['=>']', '{'=>'}', '<'=>'>')

	open_brackets = Vector{Char}()
	sizehint!(open_brackets, 110)

	for c in line
		if c in lefts
			push!(open_brackets, c)
		else
			b = pop!(open_brackets)
			c != rights[b] && return scores[c]
		end
	end

	return 0
end

function day10_1()
	lines = parse_input("input.txt")
	sum(score_corrupt_line, lines)
end

function score_incomplete_line(line)
	lefts = ('(', '[', '{', '<')
	rights = Dict('('=>')', '['=>']', '{'=>'}', '<'=>'>')

	open_brackets = Vector{Char}()
	sizehint!(open_brackets, 110)

	for c in line
		if c in lefts
			push!(open_brackets, c)
		else
			b = pop!(open_brackets)
			c != rights[b] && return 0 # return 0 if corrupt
		end
	end

	scores = Dict('('=>1, '['=>2, '{'=>3, '<'=>4,)
	score = 0
	for b in Iterators.reverse(open_brackets)
		score *= 5
		score += scores[b]
	end
	return score
end

function day10_2()
	lines = parse_input("input.txt")
	scores = score_incomplete_line.(lines)
	scores = filter(>(0), scores)
	sort!(scores)
	return scores[ceil(Int,length(scores)/2)]
end
