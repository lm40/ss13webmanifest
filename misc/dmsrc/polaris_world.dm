/world/Topic(T, addr, master, key)
    if (copytext(T,1,7) == "status")
		var/input[] = params2list(T)
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config.abandon_allowed
		s["persistance"] = config.persistence_disabled
		s["enter"] = config.enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null

		// This is dumb, but spacestation13.com's banners break if player count isn't the 8th field of the reply, so... this has to go here.
		s["players"] = 0
		s["stationtime"] = stationtime2text()
		s["roundduration"] = roundduration2text()
		s["map"] = strip_improper(using_map.full_name) //Done to remove the non-UTF-8 text macros 

		if(input["status"] == "2") // Shiny new hip status.
			var/active = 0
			var/list/players = list()
			var/list/admins = list()

			for(var/client/C in GLOB.clients)
				if(C.holder)
					if(C.holder.fakekey)
						continue
					admins[C.key] = C.holder.rank
				players += C.key
				if(istype(C.mob, /mob/living))
					active++

			s["players"] = players.len
			s["playerlist"] = list2params(players)
			s["active_players"] = active
			var/list/adm = get_admin_counts()
			var/list/presentmins = adm["present"]
			var/list/afkmins = adm["afk"]
			s["admins"] = presentmins.len + afkmins.len //equivalent to the info gotten from adminwho
			s["adminlist"] = list2params(admins)
		else // Legacy.
			var/n = 0
			var/admins = 0

			for(var/client/C in GLOB.clients)
				if(C.holder)
					if(C.holder.fakekey)
						continue	//so stealthmins aren't revealed by the hub
					admins++
				s["player[n]"] = C.key
				n++

			s["players"] = n
			s["admins"] = admins

		return list2params(s)

	else if(T == "manifest")
		var/list/positions = list()
		var/list/set_names = list(
				"heads" = SSjob.get_job_titles_in_department(DEPARTMENT_COMMAND),
				"sec" = SSjob.get_job_titles_in_department(DEPARTMENT_SECURITY),
				"eng" = SSjob.get_job_titles_in_department(DEPARTMENT_ENGINEERING),
				"med" = SSjob.get_job_titles_in_department(DEPARTMENT_MEDICAL),
				"sci" = SSjob.get_job_titles_in_department(DEPARTMENT_RESEARCH),
				"car" = SSjob.get_job_titles_in_department(DEPARTMENT_CARGO),
				"pla" = SSjob.get_job_titles_in_department(DEPARTMENT_PLANET),
				"civ" = SSjob.get_job_titles_in_department(DEPARTMENT_CIVILIAN),
				"bot" = SSjob.get_job_titles_in_department(DEPARTMENT_SYNTHETIC)
			)

		for(var/datum/data/record/t in data_core.general)
			var/name = t.fields["name"]
			var/rank = t.fields["rank"]
			var/real_rank = make_list_rank(t.fields["real_rank"])

			var/department = 0
			var/active = 0
			for(var/mob/M in player_list)
				if(M.real_name == name && M.client && M.client.inactivity <= 10 MINUTES)
					active = 1
					break
			var/isactive = active ? "Active" : "Inactive"
			for(var/k in set_names)
				if(real_rank in set_names[k])
					if(!positions[k])
						positions[k] = list()
					positions[k][name] = list(rank,isactive)
					department = 1
			if(!department)
				if(!positions["misc"])
					positions["misc"] = list()
				positions["misc"][name] = list(rank,isactive)

		for(var/datum/data/record/t in data_core.hidden_general)
			var/name = t.fields["name"]
			var/rank = t.fields["rank"]
			var/real_rank = make_list_rank(t.fields["real_rank"])

			var/active = 0
			for(var/mob/M in player_list)
				if(M.real_name == name && M.client && M.client.inactivity <= 10 MINUTES)
					active = 1
					break
			var/isactive = active ? "Active" : "Inactive"

			var/datum/job/J = SSjob.get_job(real_rank)
			if(J?.offmap_spawn)
				if(!positions["off"])
					positions["off"] = list()
				positions["off"][name] = list(rank,isactive)

		// Synthetics don't have actual records, so we will pull them from here.
		for(var/mob/living/silicon/ai/ai in mob_list)
			var/isactive = (ai.client && ai.client.inactivity <= 10 MINUTES) ? "Active" : "Inactive"
			if(!positions["bot"])
				positions["bot"] = list()
			positions["bot"][ai.name] = list("Artificial Intelligence",isactive)
		for(var/mob/living/silicon/robot/robot in mob_list)
			// No combat/syndicate cyborgs, no drones, and no AI shells.
			var/isactive = (robot.client && robot.client.inactivity <= 10 MINUTES) ? "Active" : "Inactive"
			if(robot.shell)
				continue
			if(robot.module && robot.module.hide_on_manifest())
				continue
			if(!positions["bot"])
				positions["bot"] = list()
			positions["bot"][robot.name] = list("[robot.modtype] [robot.braintype]",isactive)

		for(var/k in positions)
			positions[k] = list2params(positions[k]) // converts positions["heads"] = list("Bob"="Captain", "Bill"="CMO") into positions["heads"] = "Bob=Captain&Bill=CMO"

		return list2params(positions)