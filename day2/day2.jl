parse_input(file) = split(read(file,String),'\n',keepempty=false)
parse_cmd(str) = (s = split(str, ' '); (s[1], parse(Int, s[2])) )

tot_dir(cmds,dir) = sum(t->t[2], filter(t->t[1]==dir, cmds))

function day2_1()
	cmds = parse_cmd.(parse_input("input.txt"))
	tot_forward = tot_dir(cmds,"forward")
	tot_down = tot_dir(cmds,"down")
	tot_up = tot_dir(cmds,"up")

	return tot_forward*(tot_down-tot_up)
end

function day2_2()
	cmds = parse_cmd.(parse_input("input.txt"))

	aim = 0
	hor = 0
	depth = 0
	for (cmd, val) in cmds
		if cmd == "forward"
			hor += val
			depth += aim*val
		elseif cmd == "up"
			aim -= val
		elseif cmd == "down"
			aim += val
		end
	end
	return hor*depth
end
