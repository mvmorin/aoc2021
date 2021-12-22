using Combinatorics
using LinearAlgebra

function parse_input(file)
	scanners_raw = split(read(file, String), "\n\n", keepempty=false)

	function beaconcoords(str)
		str = split(str,'\n',keepempty=false)
		beacon = b -> Tuple(parse.(Int,split(b,',')))
		beacon.(str[2:end])
	end

	beaconcoords.(scanners_raw)
end

function orientations()
	perms = [
			   [ 1, 2, 3],
			   [ 1, 3,-2],
			   [ 1,-2,-3],
			   [ 1,-3, 2],

			   [-1, 2,-3],
			   [-1,-3,-2],
			   [-1,-2, 3],
			   [-1, 3, 2],

			   [ 2, 3, 1],
			   [ 2, 1,-3],
			   [ 2,-3,-1],
			   [ 2,-1, 3],

			   [-2, 3,-1],
			   [-2,-1,-3],
			   [-2,-3, 1],
			   [-2, 1, 3],

			   [ 3, 1, 2],
			   [ 3, 2,-1],
			   [ 3,-1,-2],
			   [ 3,-2,1 ],

			   [-3,-1, 2],
			   [-3, 2, 1],
			   [-3, 1,-2],
			   [-3,-2,-1],
			   ]

	function genmatrix(sx,sy,sz)
		m = zeros(3,3)
		m[abs(sx),1] = sign(sx)
		m[abs(sy),2] = sign(sy)
		m[abs(sz),3] = sign(sz)
		return m
	end

	orients = Matrix{Int}[]
	for (sx,sy,sz) = perms
		m = genmatrix(sx, sy, sz)
		push!(orients, m)
	end

	return orients
end

Base.:*(m::Matrix{Int},t::Tuple{Int,Int,Int}) = Tuple(m[:,1]*t[1] + m[:,2]*t[2] + m[:,3]*t[3])

function find_overlap(scans_a, scans_b)
	for orient in orientations()
		transformed = Ref(orient) .* scans_a
		a_to_b = find_matching(transformed, scans_b)

		matching = Dict{Int,Int}()
		for (i_a,i_b) in enumerate(a_to_b)
			i_b < 0 && continue
			matching[i_a] = i_b
		end

		length(keys(matching)) >= 12 && return orient, matching
	end

	return nothing, nothing
end


function find_matching(scans_a, scans_b)
	a_recentered = deepcopy(scans_a)
	a_to_b = -ones(length(scans_a))

	for b_center in scans_b, a_center in scans_a

		# align a_center to b_center
		for i = 1:length(a_recentered)
			a_recentered[i] = scans_a[i] .- a_center .+ b_center
		end

		# go through the recenterd coordinates and find matches
		for i = 1:length(a_recentered)
			i_b = findfirst(==(a_recentered[i]), scans_b)
			a_to_b[i] = isnothing(i_b) ? -1 : i_b
		end

		# count matches and return if enough was found
		if count(>(0), a_to_b) >= 12
			return a_to_b
		end
	end

	return a_to_b
end


function find_rel_positions(scans, scans_ref)
	orientation, matches = find_overlap(scans, scans_ref)
	isnothing(matches) && return nothing, nothing

	i, i_r = first(matches)
	scanner_pos = scans_ref[i_r] .- orientation*scans[i]
	beacon_pos = [orientation*s .+ scanner_pos for s in scans]

	return scanner_pos, beacon_pos
end


function find_all_positions(scans)
	known_beacons = [ scans[1] ]
	known_scanners = [ (0,0,0) ]

	to_compare = scans[2:end]
	to_compare_next = similar(to_compare,0)

	i = 1
	while checkbounds(Bool,known_beacons,i)
		known = known_beacons[i]
		i += 1

		while !isempty(to_compare)
			comp = pop!(to_compare)

			scanner_pos, beacon_pos = find_rel_positions(comp, known)

			if !isnothing(beacon_pos)
				push!(known_beacons, beacon_pos)
				push!(known_scanners, scanner_pos)
			else
				push!(to_compare_next,comp)
			end
		end

		tmp = to_compare
		to_compare = to_compare_next
		to_compare_next = tmp
	end

	return unique(reduce(vcat, known_beacons)), known_scanners
end


function day19_1()
	scans = parse_input("input.txt")
	# scans = parse_input("test.txt")
	beacons, _ = find_all_positions(scans)
	return length(beacons)
end

function day19_2()
	scans = parse_input("input.txt")
	# scans = parse_input("test.txt")
	_, scanners = find_all_positions(scans)

	max_dist = 0
	for s1 = scanners, s2 = scanners
		max_dist = max(max_dist, norm(s1.-s2,1))
	end

	return max_dist
end

