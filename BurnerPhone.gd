class_name BurnerPhone extends Node

@export var sh : ShellSpawner
@export var dia : Dialogue

func SendDialogue():
	var sequence  = sh.sequenceArray
	var len = sequence.size()
	var randindex
	var firstpart = ""
	var secondpart = ""
	var fulldia = ""
	if (len != 1):
		randindex = randi_range(1, len - 1)
		if(randindex == 8): randindex -= 1
		if (sequence[randindex] == "blank"): secondpart = tr("BLANKROUND")
		else: secondpart = tr("LIVEROUND")
		match (randindex):
			1:
				firstpart = tr("SEQUENCE2")
			2:
				firstpart = tr("SEQUENCE3")
			3:
				firstpart = tr("SEQUENCE4")
			4:
				firstpart = tr("SEQUENCE5")
			5:
				firstpart = tr("SEQUENCE6")
			6:
				firstpart = tr("SEQUENCE7")
			7:
				firstpart = tr("SEQUENCE7")
		fulldia = tr(firstpart) + "\n" + "... " + tr(secondpart)
	else: fulldia = tr("UNFORTUNATE")
	dia.ShowText_Forever(fulldia)
	await get_tree().create_timer(3, false).timeout
	dia.HideText()

