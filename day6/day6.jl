parse_input(file) = parse.(Int,split(read(file,String),',',keepempty=false))

struct FishCount
	fish_age_count::Vector{Int}

	function FishCount(fish)
		fish_age_count = zeros(9)
		for i in 1:9
			fish_age_count[i] = sum(f -> f+1 == i, fish)
		end
		new(fish_age_count)
	end
end

function age_and_give_birth!(fish::FishCount)
	new_fish = fish.fish_age_count[1]

	fish.fish_age_count[1:8] .= fish.fish_age_count[2:9]
	fish.fish_age_count[9] = new_fish
	fish.fish_age_count[7] += new_fish
end

function get_nbr_of_fish_after_n_days(fish, n)
	for _ in 1:n
		age_and_give_birth!(fish)
	end
	return sum(fish.fish_age_count)
end

function day6_1()
	fish = FishCount(parse_input("input.txt"))
	get_nbr_of_fish_after_n_days(fish, 80)
end

function day6_2()
	fish = FishCount(parse_input("input.txt"))
	get_nbr_of_fish_after_n_days(fish, 256)
end
