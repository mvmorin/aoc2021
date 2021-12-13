function parse_input(file)
	raw = split(read(file, String), "\n\n")

	function line2fold(s)
		m = match(r"fold along ([y,x])=([0-9]+)", s)

		dir = m.captures[1] == "y" ? 1 : 2
		pos = parse(Int, m.captures[2]) + 1
		return (dir, pos)
	end
	folds = line2fold.(split(raw[2],'\n', keepempty=false))

	size_y = folds[findfirst(f->getindex(f,1)==1, folds)][2]*2 - 1
	size_x = folds[findfirst(f->getindex(f,1)==2, folds)][2]*2 - 1

	line2coords = (s) -> tuple( (parse(Int, ss)+1 for ss in Iterators.reverse(split(s,',')))... )
	dots = line2coords.(split(raw[1],'\n',keepempty=false))
	paper = falses(size_y, size_x)
	for dot in dots
		paper[dot...] = true
	end

	return paper, folds
end

function fold!(paper, dir, pos)
	dir == 1 && (paper = paper')

	for column in 1:pos-1
		paper[:,column] .|= paper[:,end-column+1]
	end
	paper = paper[:,1:pos-1]

	dir == 1 && (paper = paper')
	return paper
end

function day13_1()
	paper, folds = parse_input("input.txt")
	paper = fold!(paper, folds[1]...)
	sum(paper)
end

function day13_2()
	paper, folds = parse_input("input.txt")

	for fold in folds
		paper = fold!(paper, fold...)
	end

	convert = b -> b ? '#' : '.'
	paper = [ String(convert.(paper[i,:])) for i in 1:size(paper)[1] ]
	display(paper)
end
