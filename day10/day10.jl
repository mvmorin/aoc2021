parse_input(file) = collect.(split(read(file, String), '\n', keepempty=false))

function score_line(line)
	lefts = ('(', '[', '{', '<')
	rights = Dict('('=>')', '['=>']', '{'=>'}', '<'=>'>')

	open_brackets = Vector{Char}()
	sizehint!(open_brackets, 110)

	corrupt_scores = Dict(')'=>3, ']'=>57, '}'=>1197, '>'=>25137,)
	for c in line
		if c in lefts
			push!(open_brackets, c)
		else
			b = pop!(open_brackets)
			c != rights[b] && return (corrupt_scores[c], 0)
		end
	end

	incomplet_scores = Dict('('=>1, '['=>2, '{'=>3, '<'=>4,)
	inc_score = 0
	for b in Iterators.reverse(open_brackets)
		inc_score *= 5
		inc_score += incomplet_scores[b]
	end

	return (0, inc_score)
end

function day10_1()
	lines = parse_input("input.txt")
	scores = score_line.(lines)
	sum(s->getindex(s,1), scores)
end

function day10_2()
	lines = parse_input("input.txt")
	scores = score_line.(lines)
	scores = getindex.(scores, 2)

	scores = sort(filter(>(0), scores))
	scores[ceil(Int,length(scores)/2)]
end
