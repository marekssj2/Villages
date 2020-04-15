var/list/villages = list()

mob
	var/village/village


	proc/inConflict(var/mob/M)
		if(village && M.village && village.enemies.Find(M.village))	return 1
		else	return 0
	verb
		CreateVillage(n as text)
			if(!src || src.village)	return
			villages.Add(new/village(n, src))

		Kill(var/mob/M in world)

			if(inConflict(M))
				village?.score++

mob/village
	verb
		Who()
			set category = "Village commands"
			src<<"<b>Villagers Online:"
			var/counter=0
			for(var/mob/M in village.members)
				counter+=1
				src<<"[M.name] ([M.key])"
			src<<"<b>[counter] Villagers Online"
		Leave()
			set category = "Village commands"
			village?.RemoveMember(src)
		Say(t as text)
			set category = "Village commands"
			village?.Message("\icon[usr.icon]<PRE><B>[usr]:</B>[t]")



	owner/verb
		SelectEmblem()
			set category = "Menage Village"
			village?.SetEmblem()
		Invite()
			set category = "Menage Village"
			var/mob/M=input("Select Player to Invite","Village Invitation") as null|anything in players - src
			if(alert(M,"Would you like join in to [village] village?","War","Yes","No")=="Yes")
				village?.AddMember(M)

		DeclareWar()
			set category = "Menage Village"
			var/village/V=input("Select Village to Declare war","War Decleration") as null|anything in villages - src.village
			if(V)	village?.DeclareWar(V)


village
	var
		name
		score = 0
		icon/logo
		list/members = list()
		mob/owner
		list/allies = list()
		list/enemies = list()

	New(Name, Owner)
		if(!Name || !Owner)	return
		name = Name
		logo = new('logo.dmi')
		AddMember(Owner)
		SetOwner(Owner)
	Del()
		villages -= src
		for(var/village/V in villages)
			V.RemoveEnemy(src)
		..()

	proc
		AddMember(var/mob/M)
			if(!M || M.village)	return
			M.village = src
			members += M
			members<<"[M] welcome in [name]!"
			M.verbs+=typesof(/mob/village/verb)
		RemoveMember(var/mob/M)
			if(!M || !M.village)	return
			M.village = null
			members -= M
			members<<"[M] leave [name]!"
			M.verbs -= typesof(/mob/village/verb)
			M.verbs -= typesof(/mob/village/owner/verb)
			if(members.len >= 1)
				if(owner == M)
					SetOwner(pick(members))
			else	Del()
		SetOwner(var/mob/M)
			if(!M || !M.village == src)	return
			owner?.verbs-=typesof(/mob/village/owner/verb)
			owner = M
			M.verbs+=typesof(/mob/village/owner/verb)
			members<<"[M] is new owner of [name]!"
		SetEmblem()

			var/icon/i = new(input("Select the file","Select Emblem") as  null|icon)
			if(i.Width()>16||i.Height()>16)
				world<<"file is to big!"
				return
			else	logo = i
		SetName(var/Name)
			name = Name
		Message(var/Msg)
			members<<"[Msg]"
		AddAllies(var/village/V)
			if(enemies.Find(V))	return
			if(!allies.Find(V))
				allies += V
		RemoveAllies(var/village/V)
			if(allies.Find(V))
				allies -= V


		AddEnemy(var/village/V)
			if(allies.Find(V))
				allies -= V
			if(!enemies.Find(V))
				enemies += V
		RemoveEnemy(var/village/V)
			if(enemies.Find(V))
				enemies -= V
		DeclareWar(var/village/V)
			AddEnemy(V)
			Message("We declare war for [V.name]!")
			V.AddEnemy(src)
			V.Message("[src.name] declare war for us!")
		FinishWar(var/village/V)
			var/warIsOver=1
			if(alert(owner,"Would you like to stop war with [V.name]?","War","Yes","No")=="No")	warIsOver=0
			if(alert(V.owner,"Would you like to stop war with [src.name]?","War","Yes","No")=="No")	warIsOver=0
			if(warIsOver)
				world<<"War is over!"
				RemoveEnemy(V)
				V.RemoveEnemy(src)


