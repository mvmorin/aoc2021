parse_input(file) = split(read(file,String),'\n',keepempty=false)

function parse_input(file)
	segments = split(read(file,String), "\n\n", keepempty=false)

	function str2board(str)
		row_strs = split(str, "\n", keepempty=false)
		str2row(str) = parse.(Int, split(str, ' ', keepempty=false))
		rows = str2row.(row_strs)
		return vcat((rows')...)
	end

	nbrs = parse.(Int,split(segments[1],','))
	boards = str2board.(segments[2:end])
	return nbrs, boards
end

function board_bingos_on(board, nbrs)
	function complete_on_turn(row)
		turns_hitting = indexin(row, nbrs)
		nothing in turns_hitting ? length(nbrs) + 1 : maximum(turns_hitting)
	end

	row_bingo_turns = [complete_on_turn(board[i,:]) for i in 1:size(board)[1]]
	column_bingo_turns = [complete_on_turn(board[:,i]) for i in 1:size(board)[2]]

	return min(minimum(row_bingo_turns), minimum(column_bingo_turns))
end

function board_sum(board, nbrs)
	board = copy(board)

	hit_indices = indexin(nbrs, board)
	for idx in hit_indices
		!isnothing(idx) && (board[idx] = 0)
	end
	return sum(board)
end

function day4_1()
	nbrs, boards = parse_input("input.txt")

	bingos = [board_bingos_on(board,nbrs) for board in boards]
	turn, board_idx = findmin(bingos)
	return nbrs[turn]*board_sum(boards[board_idx], nbrs[1:turn])
end

function day4_2()
	nbrs, boards = parse_input("input.txt")

	bingos = [board_bingos_on(board,nbrs) for board in boards]
	turn, board_idx = findmax(bingos)
	return nbrs[turn]*board_sum(boards[board_idx], nbrs[1:turn])
end
