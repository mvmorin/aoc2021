struct Image
	details::Matrix{Bool}
	padding::Bool
end

function img2strings(img, sx, sy)
	offx, offy = round.(Int, ((sx,sy) .- size(img.details)) ./ 2 )

	strings = []
	for i = 1:sx
		str = ""
		for j = 1:sy
			str *= img[i-offx,j-offy] ? "#" : "."
		end
		push!(strings, str)
	end

	return strings
end

function parse_input(file)
	key_raw, image_raw = split(read(file, String), "\n\n", keepempty=false)

	key = '#' .== collect(key_raw)

	image = ('#' .== hcat(collect.(split(image_raw, '\n',keepempty=false))...))'

	return key, Image(image, false)
end

Base.getindex(img::Image, i, j) = checkbounds(Bool, img.details, i, j) ? img.details[i,j] : img.padding

function Base.getindex(img::Image, ir::AbstractRange, jr::AbstractRange)
	res = falses(length(ir), length(jr))
	for (i_res, i) in enumerate(ir), (j_res, j) in enumerate(jr)
		res[i_res, j_res] = img[i,j]
	end
	return res
end

function segment2index(seg)
	si, sj = size(seg)

	res = 0
	for i = 1:si, j = 1:sj
		res += seg[i,j] * 2^(si*sj - sj*(i-1) - j)
	end
	return res
end

segment2enhanced(seg, key) = key[segment2index(seg)+1]

function enhance(img, key)
	padding = segment2enhanced(fill(img.padding, 3, 3), key)

	details = similar(img.details, (size(img.details).+2)...)

	si, sj = size(img.details)
	for i = 0:si+1
		for j = 0:sj+1
			details[i+1,j+1] = segment2enhanced(img[ i-1:i+1, j-1:j+1], key)
		end
	end

	return Image(details, padding)
end

function day20_1()
	key, img = parse_input("input.txt")
	# key, img = parse_input("test.txt")

	display(img2strings(img, 15,15))
	img = enhance(img,key)
	display(img2strings(img, 15,15))
	img = enhance(img,key)
	display(img2strings(img, 15,15))
	return count(img.details)
end

function day20_2()
	key, img = parse_input("input.txt")
	# key, img = parse_input("test.txt")

	for _ = 1:50
		img = enhance(img,key)
	end
	return count(img.details)
end

