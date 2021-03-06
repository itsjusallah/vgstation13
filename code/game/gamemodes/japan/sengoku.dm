/datum/game_mode/japan/sengoku
	name = "Sengoku Period"
	config_tag = "sengoku"
	required_players = 1 //TESTING ONLY
	required_players_secret = 1
	required_enemies = 0
	recommended_enemies = 0

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/list/raid_objectives = list()     //Raid objectives.
	var/list/players = list()

	var/relationships_mates = list()
	var/relationships_siblings = list()
	var/relationships_uncles_aunts_nephews_nieces = list()
	var/relationships_cousins = list()
	var/relationships_parents_children = list()


/datum/game_mode/japan/sengoku/post_setup()
	var/list/peasants = list()
	var/list/monks = list()
	var/list/samurai = list()
	var/list/commanders = list()
	var/list/daimyo = list()
	var/list/women = list()
	var/list/children = list()

	var/mob/living/carbon/human/emperor = null

	var/list/tier_peasants = list()
	var/list/tier_lesser_nobles = list()
	var/list/tier_upper_nobles = list()
	var/list/tier_highest = list()


	for (var/mob/living/carbon/human/H in player_list)

		players += H

		var/datum/job/japan/job = H.mind.assigned_role

		if (istype(job, /datum/job/japan/peasant))
			peasants += H
		else if (istype(job, /datum/job/japan/monk))
			monks += H
		else if (istype(job, /datum/job/japan/samurai))
			samurai += H
		else if (istype(job, /datum/job/japan/commander))
			commanders += H
		else if (istype(job, /datum/job/japan/daimyo))
			daimyo += H
		else if (istype(job, /datum/job/japan/emperor))
			emperor = H
		else if (istype(job, /datum/job/japan/related/woman))
			women += H
		else if (istype(job, /datum/job/japan/related/child))
			children += H

		//tiers include women and children
		switch (job.tier)
			if (TIER_PEASANT)
				tier_peasants += H
			if (TIER_LESSER_NOBLE)
				tier_lesser_nobles += H
			if (TIER_UPPER_NOBLE)
				tier_upper_nobles += H
			if (TIER_HIGHEST)
				tier_highest += H




	spawn (rand(waittime_l, waittime_h))
		if(!mixed)
			send_intercept() //nothing for now

	//form common relationships
	form_relationships(tier_peasants, tier_peasants, 1)
	form_relationships(tier_lesser_nobles, tier_lesser_nobles, 1)
	form_relationships(tier_upper_nobles, tier_upper_nobles, 1)
	form_relationships(tier_highest, tier_highest, 1)
	//form uncommon relationships
	form_relationships(tier_peasants, tier_lesser_nobles, 0)
	form_relationships(tier_lesser_nobles, tier_upper_nobles, 0)
	form_relationships(tier_upper_nobles, tier_highest, 0)

	greet()


/datum/game_mode/japan/sengoku/proc/form_relationships(var/list/list1, var/list/list2, var/common = 1)
	var/probability = 0
	if (common)
		probability = 100/players.len/2
	else
		probability = 100/players.len/4

	for (var/mob/living/carbon/human/H in players)
		for (var/mob/living/carbon/human/HH in players)
			if (prob(probability))
				create_relationship(H,HH)


/datum/game_mode/japan/sengoku/proc/create_relationship(var/mob/living/carbon/human/mob1, var/mob/living/carbon/human/mob2)
	var/mob1_age = mob1.age
	var/mob2_age = mob2.age
	var/difference = abs(mob1_age - mob2_age)

	if (difference <= 15)
		if (mob1_age >= 16 && mob2_age >= 16)
			if (prob(50))
				return add_relationship(mob1, mob2, "mates")
			else if (prob(30))
				return add_relationship(mob1, mob2, "siblings")
			else
				return add_relationship(mob1, mob2, "cousins")
		else
			if (prob(75))
				return add_relationship(mob1, mob2, "uncle/aunt/nephew/niece")
			else
				return add_relationship(mob1, mob2, "cousins")

	else if (difference >= 16)
		if (prob(75))
			return add_relationship(mob1, mob2, "parent/child")
		else
			return add_relationship(mob1, mob2, "cousins")


/datum/game_mode/japan/sengoku/proc/add_relationship(var/mob/living/carbon/human/mob1, var/mob/living/carbon/human/mob2, var/relationship)

	var/list/ref = list()

	switch (relationship)
		if ("mates")
			ref = relationships_mates
		if ("siblings")
			ref = relationships_siblings
		if ("uncle/aunt/nephew/niece")
			ref = relationships_uncles_aunts_nephews_nieces
		if ("cousins")
			ref = relationships_cousins
		if ("parent/child")
			ref = relationships_parents_children

	if (mob1 in ref || mob2 in ref)
		return

	ref += mob1
	ref += mob2

	var/mob1_gender = mob1.gender
	var/mob2_gender = mob2.gender

	switch (relationship) // just in case we mistyped
		if ("mates")
			if (mob1_gender == mob2_gender)
				return 0
			else
				if (mob1_gender == MALE && mob2_gender == FEMALE)
					mob1.relationships[mob2.real_name] = "Wife"
					mob2.relationships[mob1.real_name] = "Husband"
				else
					mob1.relationships[mob2.real_name] = "Husband"
					mob2.relationships[mob1.real_name] = "Wife"
				return 1
		if ("siblings") //ONII CHAN
			mob1.relationships[mob2.real_name] = mob2_gender == FEMALE ? "Sister" : "Brother"
			mob2.relationships[mob1.real_name] = mob1_gender == FEMALE ? "Sister" : "Brother"
			return 1
		if ("cousins")
			mob1.relationships[mob2.real_name] = "Cousin"
			mob2.relationships[mob1.real_name] = "Cousin"
			return 1
		if ("uncle/aunt/nephew/niece")
			mob1.relationships[mob2.real_name] = mob2_gender == FEMALE ? "Niece" : "Nephew"
			mob2.relationships[mob1.real_name] = mob1_gender == FEMALE ? "Aunt" : "Uncle"
			return 1
		if ("parent/child")
			mob1.relationships[mob2.real_name] = mob2_gender == FEMALE ? "Daughter" : "Son"
			mob2.relationships[mob1.real_name] = mob1_gender == FEMALE ? "Mother" : "Father"
			return 1

/datum/game_mode/japan/sengoku/proc/create_vassalships()



/datum/game_mode/japan/sengoku/proc/greet()
	for (var/mob/living/carbon/human/H in players)
		if (is_patriarch(H.mind.assigned_role))
			for (var/mob/living/carbon/human/HH in H.relationships)
				if (is_subservient(HH)) //important - people with actual roles shouldn't spawn next
				//to OTOSAN
					to_chat(H.mind, {"[HH.real_name] is your [H.relationships[HH.real_name]]."})
					HH.loc = H.loc
					var/i_tried_so_hard_and_got_so_far = 0
					while (locate(/mob/living/carbon/human) in HH.loc)
						HH.loc = locate(HH.x+1, HH.y, HH.z)
						i_tried_so_hard_and_got_so_far++
						if (i_tried_so_hard_and_got_so_far >= 5)
							i_tried_so_hard_and_got_so_far = 0
							break
					while (locate(/mob/living/carbon/human) in HH.loc)
						HH.loc = locate(HH.x-1, HH.y, HH.z)
						i_tried_so_hard_and_got_so_far++
						if (i_tried_so_hard_and_got_so_far >= 5)
							i_tried_so_hard_and_got_so_far = 0
							break