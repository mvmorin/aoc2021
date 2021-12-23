mutable struct DeterministicDie
	next_roll::Int
	DeterministicDie() = new(1)
end

function roll3x!(d::DeterministicDie)
	res = 0
	for _ = 1:3
		res += d.next_roll
		d.next_roll = 1 + (d.next_roll % 100)
	end
	return res
end
reset_die!(d::DeterministicDie) = (d.next_roll = 1)


mutable struct DiracDie
	next_roll_nbr::Int
	triplet_sequence::Vector{Int}

	DiracDie(nbr_of_3xrolls) = new(1, 3*ones(nbr_of_3xrolls))
end

reset_die!(d::DiracDie) = (d.next_roll_nbr = 1)
atfirstoutcome(d::DiracDie) =  all(d.triplet_sequence .== 3)

function roll3x!(d::DiracDie)
	res = d.triplet_sequence[d.next_roll_nbr]
	d.next_roll_nbr += 1
	return res
end

function next_outcome!(d::DiracDie, rollx3s_performed)
	# Skip to the last sequence that perfroms the same initial rolls, these are
	# all equivalent
	d.triplet_sequence[rollx3s_performed+1:end] .= 9

	# Increment to next sequence
	i = length(d.triplet_sequence)
	while i > 0
		d.triplet_sequence[i] += 1

		if d.triplet_sequence[i] > 9
			d.triplet_sequence[i] = 3
			i -= 1
		else
			break
		end
	end
end

function nbr_equiv_outcomes(d::DiracDie, rollx3s_performed)
	possiblities = Dict(3 => 1,
						4 => 3,
						5 => 3+3,
						6 => 3+3+1,
						7 => 3+3,
						8 => 3,
						9 => 1)
	res = 1
	for roll in d.triplet_sequence[1:rollx3s_performed]
		res *= possiblities[roll]
	end
	return res
end




struct Player
	id::Int
	position::Int
	score::Int

	Player(id, pos, score) = new(id, 1 + (pos-1) % 10, score)
end

Player(id, pos) = Player(id, pos, 0)

function move(p::Player, dist)
	pos = 1 + (p.position - 1 + dist) % 10
	score = p.score + pos
	return Player(p.id, pos, score)
end

function play_until(players, until, die, max_turns)
	reset_die!(die)

	for turn = 1:max_turns
		dist = roll3x!(die)

		player_idx = 1 + (turn - 1) % length(players)
		players[player_idx] = move(players[player_idx], dist)

		if maximum( getproperty.(players, :score)) >= until
			return turn, players, true
		end
	end

	return max_turns, players, false
end



function parse_input(file)
	raw_players = split(read(file, String), '\n', keepempty=false)

	players = Player[]
	for raw in raw_players
		m = match(r"Player ([0-9]+) starting position: ([0-9]+)", raw)
		id = parse(Int, m.captures[1])
		pos = parse(Int, m.captures[2])
		push!(players, Player(id, pos))
	end

	return players
end

function day21_1()
	players = parse_input("input.txt")
	# players = parse_input("test.txt")

	turns, players, someone_won = play_until(players, 1000, DeterministicDie(), 2001)
	n_rolls = turns*3
	return n_rolls * minimum( getproperty.(players, :score) )
end



function count_wins_on_turns(player, max_turns=21)
	d = DiracDie(max_turns)
	win_counts = zeros(Int, max_turns)

	while true
		# Play and update winner
		turns, _, player_won = play_until([player], 21, d, max_turns)

		!player_won && error("max_turns not large enough to find all winning die outcomes")

		win_counts[turns] += nbr_equiv_outcomes(d, turns)

		# Increment the die outcome, and check for looping around to first outcome again
		next_outcome!(d, turns)
		atfirstoutcome(d) && break
	end

	return win_counts
end

function count_not_win_by_turns(player, max_turns=21)
	not_won_by = zeros(Int, max_turns)

	for max_turns in 1:length(not_won_by)

		d = DiracDie(max_turns)
		while true
			# Play and update winner
			turns, _, player_won = play_until([player], 21, d, max_turns)

			if !player_won
				not_won_by[max_turns] += nbr_equiv_outcomes(d, max_turns)
			end

			# Increment the die outcome, and check for looping around to first outcome again
			next_outcome!(d, turns)
			atfirstoutcome(d) && break
		end
	end

	return not_won_by
end

function day21_2()
	players = parse_input("input.txt")
	# players = parse_input("test.txt")

	p1_won_on_turn = count_wins_on_turns(players[1])
	p1_not_won_by_turn = count_not_win_by_turns(players[1])
	p2_won_on_turn = count_wins_on_turns(players[2])
	p2_not_won_by_turn = count_not_win_by_turns(players[2])

	p1wins = sum(p1_won_on_turn[2:end] .* p2_not_won_by_turn[1:end-1])
	p2wins = sum(p2_won_on_turn .* p1_not_won_by_turn)

	return p1wins, p2wins
end
