class_name DealerIntelligence extends Node
#ALTHOUGH THE CLASS NAME SUGGESTS THAT THE DEALER HAS INTELLIGENCE, AND IT'S TRUE THERE ARE MANY INTELLIGENT DEALERS,
#CONTRARY TO THOSE THIS ONE IS NOT. HERE THERE IS NO INTELLIGENCE. ONLY LAYERS, HEAPS AND CLUMPS OF SPAGHETTI JUMBLE CODE.

@export var medicine : Medicine
@export var hands : HandManager
@export var itemManager : ItemManager
@export var shellSpawner : ShellSpawner
@export var shellLoader : ShellLoader
@export var shotgunShooting : ShotgunShooting
@export var roundManager : RoundManager
@export var animator_shotgun : AnimationPlayer
@export var animator_dealerHands : AnimationPlayer
@export var camera : CameraManager
@export var ejectManager : ShellEjectManager
@export var healthCounter : HealthCounter
@export var death : DeathManager
@export var cameraShaker : CameraShaker
@export var smoke : SmokeController
@export var shellEject_dealer : ShellEjectManager
@export var speaker_dealerarrive : AudioStreamPlayer2D
@export var speaker_handCrack : AudioStreamPlayer2D
@export var soundArray_cracks : Array[AudioStream]
@export var speaker_checkHandcuffs : AudioStreamPlayer2D
@export var speaker_breakHandcuffs : AudioStreamPlayer2D
@export var speaker_giveHandcuffs : AudioStreamPlayer2D
@export var sound_dealerarrive : AudioStream
@export var sound_dealerarriveCuffed : AudioStream
@export var dealermesh_normal : VisualInstance3D
@export var dealermesh_crushed : VisualInstance3D
@export var sequenceArray_knownShell : Array[bool]
@export var amounts : Amounts

var dealerItemStringArray : Array[String]
var dealerAboutToBreakFree = false
var dealerCanGoAgain = false
var dealerHoldingShotgun = false

func DealerCheckHandCuffs():
	var brokeFree = false
	camera.BeginLerp("enemy cuffs close")
	if (!dealerAboutToBreakFree):
		await get_tree().create_timer(.3, false).timeout
		speaker_checkHandcuffs.play()
		animator_dealerHands.play("dealer check handcuffs")
		await get_tree().create_timer(.7, false).timeout
		brokeFree = false
	else:
		await get_tree().create_timer(.3, false).timeout
		animator_dealerHands.play("dealer break cuffs") #replace with broke free anim
		speaker_breakHandcuffs.play()
		#await get_tree().create_timer(.7, false).timeout
		brokeFree = true
		roundManager.dealerCuffed = false
		dealerAboutToBreakFree = false
	dealerAboutToBreakFree = true
	roundManager.ReturnFromCuffCheck(brokeFree)

func Animator_CheckHandcuffs():
	speaker_checkHandcuffs.play()

func Animator_GiveHandcuffs():
	speaker_giveHandcuffs.play()

func BeginDealerTurn():
	mainLoopFinished = false
	usingHandsaw = false
	usingMedicine = false
	DealerChoice()

var dealerTarget = ""
var knownShell = ""
var dealerKnowsShell = false
var mainLoopFinished = false
var usingHandsaw = false
var dealerUsedItem = false
var usingMedicine = false

var adrenalineSetup = false
var stealing = false
var adrenaline_itemSlot = ""
var inv_playerside = []
var inv_dealerside = []

func DealerChoice():
	var dealerWantsToUse = ""
	var dealerFinishedUsingItems = false
	var hasHandsaw = false
	var hasCigs = false
	if (roundManager.requestedWireCut):
		await(roundManager.defibCutter.CutWire(roundManager.wireToCut))
	if (shellSpawner.sequenceArray.size() == 0):
		roundManager.StartRound(true)
		return

	if (roundManager.endless && !dealerKnowsShell):
		dealerKnowsShell = FigureOutShell()
		if (dealerKnowsShell):
			if (roundManager.shellSpawner.sequenceArray[0] == "blank"): 
				knownShell = "blank"
				dealerTarget = "self"
			else: 
				knownShell = "live"
				dealerTarget = "player"

	if (roundManager.shellSpawner.sequenceArray.size() == 1):
		knownShell = shellSpawner.sequenceArray[0]
		if (shellSpawner.sequenceArray[0] == "live"): knownShell = "live" 
		else: knownShell = "blank"
		if (knownShell == "live"): dealerTarget = "player"
		else: dealerTarget = "self"
		dealerKnowsShell = true
	for i in range(itemManager.itemArray_dealer.size()):
		if (itemManager.itemArray_dealer[i] == "cigarettes"):
			hasCigs = true
			break
	
	inv_playerside = []
	inv_dealerside = []
	itemManager.itemArray_dealer = []
	itemManager.itemArray_instances_dealer = []
	var usingAdrenaline = false
	var ch = itemManager.itemSpawnParent.get_children()
	for c in ch.size():
		if(ch[c].get_child(0) is PickupIndicator):
			var temp_interaction : InteractionBranch = ch[c].get_child(1)
			if (temp_interaction.itemName == "adrenaline" && !temp_interaction.isPlayerSide):
				usingAdrenaline = true
				adrenalineSetup	= true
	for c in ch.size():
		if(ch[c].get_child(0) is PickupIndicator):
			var temp_indicator : PickupIndicator = ch[c].get_child(0)
			var temp_interaction : InteractionBranch = ch[c].get_child(1)
			if (ch[c].transform.origin.z > 0): temp_indicator.whichSide = "right"
			else: temp_indicator.whichSide= "left"
			if (!temp_interaction.isPlayerSide):
				inv_dealerside.append(temp_interaction.itemName)
				itemManager.itemArray_dealer.append(temp_interaction.itemName)
				itemManager.itemArray_instances_dealer.append(ch[c])
	for c in ch.size():
		if(ch[c].get_child(0) is PickupIndicator):
			var temp_indicator : PickupIndicator = ch[c].get_child(0)
			var temp_interaction : InteractionBranch = ch[c].get_child(1)
			if (ch[c].transform.origin.z > 0): temp_indicator.whichSide = "right"
			else: temp_indicator.whichSide= "left"
			if (temp_interaction.isPlayerSide && usingAdrenaline): 
				itemManager.itemArray_dealer.append(temp_interaction.itemName)
				itemManager.itemArray_instances_dealer.append(ch[c])
				inv_playerside.append(temp_interaction.itemName)
	
	for i in range(itemManager.itemArray_dealer.size()):
		if (itemManager.itemArray_dealer[i] == "magnifying glass" && !dealerKnowsShell && shellSpawner.sequenceArray.size() != 1):
			dealerWantsToUse = "magnifying glass"
			if (shellSpawner.sequenceArray[0] == "live"): knownShell = "live" 
			else: knownShell = "blank"
			if (knownShell == "live"): dealerTarget = "player"
			else: dealerTarget = "self"
			dealerKnowsShell = true
			break
		if (itemManager.itemArray_dealer[i] == "cigarettes"):
			if (roundManager.health_opponent < roundManager.roundArray[0].startingHealth):
				dealerWantsToUse = "cigarettes"
				hasCigs = false
				break
		if (itemManager.itemArray_dealer[i] == "expired medicine" && roundManager.health_opponent < (roundManager.roundArray[0].startingHealth) && !hasCigs && !usingMedicine):
			if (roundManager.health_opponent != 1): 
				dealerWantsToUse = "expired medicine"
				usingMedicine = true
				break
		if (itemManager.itemArray_dealer[i] == "beer" && knownShell != "live" && shellSpawner.sequenceArray.size() != 1):
			dealerWantsToUse = "beer"
			shellEject_dealer.FadeOutShell()
			if (roundManager.endless):
				dealerKnowsShell = false
				knownShell = ""
			break
		if (itemManager.itemArray_dealer[i] == "handcuffs" && roundManager.playerCuffed == false && shellSpawner.sequenceArray.size() != 1):
			dealerWantsToUse = "handcuffs"
			roundManager.playerCuffed = true
			break
		if (itemManager.itemArray_dealer[i] == "handsaw" && !roundManager.barrelSawedOff && knownShell == "live"):
			dealerWantsToUse = "handsaw"
			usingHandsaw = true
			roundManager.barrelSawedOff = true
			roundManager.currentShotgunDamage = 2
			break
		if (itemManager.itemArray_dealer[i] == "burner phone" && roundManager.shellSpawner.sequenceArray.size() > 2):
			var sequence  = roundManager.shellSpawner.sequenceArray
			var len = sequence.size()
			var randindex =  randi_range(1, len - 1)
			if(randindex == 8): randindex -= 1
			sequenceArray_knownShell[randindex] = true
			dealerWantsToUse = "burner phone"
			break
		if (itemManager.itemArray_dealer[i] == "inverter" && dealerKnowsShell && knownShell == "blank"):
			dealerWantsToUse = "inverter"
			knownShell = "live"
			dealerKnowsShell = true
			roundManager.shellSpawner.sequenceArray[0] = "live"
			dealerTarget = "player"
			break
	
	if (dealerWantsToUse == ""): mainLoopFinished = true
	for i in range(itemManager.itemArray_dealer.size()):
		if (itemManager.itemArray_dealer[i] == "handsaw"): hasHandsaw = true
	if (mainLoopFinished && !usingHandsaw && hasHandsaw && !roundManager.barrelSawedOff && knownShell != "blank"):
		var decision = CoinFlip()
		if (decision == 0): dealerTarget = "self"
		else: 
			dealerUsedItem = true
			dealerTarget = "player"
			dealerWantsToUse = "handsaw"
			usingHandsaw = true
			roundManager.barrelSawedOff = true
			roundManager.currentShotgunDamage = 2
		
	if (dealerWantsToUse != ""): 
		if (dealerHoldingShotgun):
			animator_shotgun.play("enemy put down shotgun")
			shellLoader.DealerHandsDropShotgun()
			dealerHoldingShotgun = false
			await get_tree().create_timer(.45, false).timeout
		dealerUsedItem = true
		if (roundManager.waitingForDealerReturn):
			await get_tree().create_timer(1.8, false).timeout
			roundManager.waitingForDealerReturn = false

		var returning = false
		
		if (dealerWantsToUse == "expired medicine"):
			var medicine_outcome = randf_range(0.0, 1.0)
			var dying
			if (medicine_outcome < .4): dying = false
			else: dying = true
			medicine.dealerDying = dying
			returning = true
		var amountArray : Array[AmountResource] = amounts.array_amounts
		for res in amountArray:
			if (dealerWantsToUse == res.itemName):
				res.amount_dealer -= 1
				break
		
		var stealingFromPlayer = true
		for i in range(inv_dealerside.size()):
			if (inv_dealerside[i] == dealerWantsToUse): stealingFromPlayer = false
		var subtracting = true
		var temp_stealing = false
		for i in range(itemManager.itemArray_instances_dealer.size()):
			if (itemManager.itemArray_instances_dealer[i].get_child(1).itemName == dealerWantsToUse && itemManager.itemArray_instances_dealer[i].get_child(1).isPlayerSide && dealerWantsToUse != "adrenaline" && adrenalineSetup && stealingFromPlayer):
				temp_stealing = true
				await(hands.PickupItemFromTable("adrenaline"))
				itemManager.numberOfItemsGrabbed_enemy -= 1
				subtracting = false
				adrenalineSetup = false
				break
		
		if (temp_stealing): hands.stealing = true
		await(hands.PickupItemFromTable(dealerWantsToUse))
		#if (dealerWantsToUse == "handcuffs"): await get_tree().create_timer(.8, false).timeout #additional delay for initial player handcuff check (continues outside animation)
		if (dealerWantsToUse == "cigarettes"): await get_tree().create_timer(1.1, false).timeout #additional delay for health update routine (called in aninator. continues outside animation)
		itemManager.itemArray_dealer.erase(dealerWantsToUse)
		if (subtracting): itemManager.numberOfItemsGrabbed_enemy -= 1
		
		if (returning): return
		
		DealerChoice()
		return
	if (dealerWantsToUse == ""): dealerFinishedUsingItems = true
	if (roundManager.waitingForDealerReturn):
		await get_tree().create_timer(1.8, false).timeout
	if (!dealerHoldingShotgun && dealerFinishedUsingItems):
		GrabShotgun()
		await get_tree().create_timer(1.4 + .5 - 1, false).timeout
	await get_tree().create_timer(1, false).timeout
	if (dealerTarget == ""): ChooseWhoToShootRandomly()
	else: Shoot(dealerTarget)
	dealerTarget = ""
	knownShell = ""
	dealerKnowsShell = false
	pass

func FigureOutShell():
	if (sequenceArray_knownShell[0] == true): return true
	
	var seq = shellSpawner.sequenceArray
	var mem = sequenceArray_knownShell
	
	var c_live = 0
	var c_blank = 0
	for shell in seq:
		if (shell == "blank"): c_blank += 1
		if (shell == "live"): c_live += 1
	if (c_live == 0): return true
	if (c_blank == 0): return true
	
	for c in mem.size():
		if (mem[c] == true): 
			if(seq[c] == "live"): c_live -= 1
			else:  c_blank -= 1
	if (c_live == 0): return true
	if (c_blank == 0): return true
	
	return false

func EndDealerTurn(canDealerGoAgain : bool):
	dealerCanGoAgain = canDealerGoAgain
	#USINGITEMS: ASSIGN DEALER CAN GO AGAIN FROM ITEMS HERE
	#CHECK IF OUT OF HEALTH
	var outOfHealth_player = roundManager.health_player == 0
	var outOfHealth_enemy = roundManager.health_opponent == 0
	var outOfHealth = outOfHealth_player or outOfHealth_enemy
	if (outOfHealth):
		#if (outOfHealth_player): roundManager.OutOfHealth("player")
		if (outOfHealth_enemy):	roundManager.OutOfHealth("dealer")
		return

	if (!dealerCanGoAgain):
		EndTurnMain()
	else:
		if (shellSpawner.sequenceArray.size()):
			BeginDealerTurn()
		else:
			EndTurnMain()
	pass

func ChooseWhoToShootRandomly():
	var decision = CoinFlip()
	if (decision == 0): Shoot("self")
	else: Shoot("player")

func GrabShotgun():
	#await get_tree().create_timer(1, false).timeout
	#camera.BeginLerp("enemy")
	#await get_tree().create_timer(.8, false).timeout
	await(shellLoader.DealerHandsGrabShotgun())
	await get_tree().create_timer(.2, false).timeout
	animator_shotgun.play("grab shotgun_pointing enemy")
	dealerHoldingShotgun = true
	pass

func EndTurnMain():
	await get_tree().create_timer(.5, false).timeout
	camera.BeginLerp("home")
	if (dealerHoldingShotgun): 
		animator_shotgun.play("enemy put down shotgun")
		shellLoader.DealerHandsDropShotgun()
	dealerHoldingShotgun = false
	roundManager.EndTurn(true)

func Shoot(who : String):
	var currentRoundInChamber = shellSpawner.sequenceArray[0]
	dealerCanGoAgain = false
	var playerDied = false
	var dealerDied = false
	ejectManager.FadeOutShell()
	#ANIMATION DEPENDING ON WHO IS SHOT
	match(who):
		"self":
			await get_tree().create_timer(.2, false).timeout
			animator_shotgun.play("enemy shoot self")
			await get_tree().create_timer(2, false).timeout
			shotgunShooting.whoshot = "dealer"
			shotgunShooting.PlayShootingSound()
			pass
		"player":
			animator_shotgun.play("enemy shoot player")
			await get_tree().create_timer(2, false).timeout
			shotgunShooting.whoshot = "player"
			shotgunShooting.PlayShootingSound()
			pass
	#SUBTRACT HEALTH. ASSIGN DEALER CAN GO AGAIN. RETURN IF DEAD
	if (currentRoundInChamber == "live" && who == "self"): 
		roundManager.health_opponent -= roundManager.currentShotgunDamage
		if (roundManager.health_opponent < 0): roundManager.health_opponent = 0
		smoke.SpawnSmoke("barrel")
		cameraShaker.Shake()
		dealerCanGoAgain = false
		death.Kill("dealer", false, true)
		return
	if (currentRoundInChamber == "live" && who == "player"): 
		roundManager.health_player -= roundManager.currentShotgunDamage
		if (roundManager.health_player < 0): roundManager.health_player = 0
		cameraShaker.Shake()
		smoke.SpawnSmoke("barrel")
		await(death.Kill("player", false, false))
		playerDied = true
	if (currentRoundInChamber == "blank" && who == "self"): dealerCanGoAgain = true
	#EJECTING SHELLS
	await get_tree().create_timer(.4, false).timeout
	if (who == "player"): animator_shotgun.play("enemy eject shell_from player")
	if (who == "self"): animator_shotgun.play("enemy eject shell_from self")
	await get_tree().create_timer(1.7, false).timeout
	#shellSpawner.sequenceArray.remove_at(0)
	EndDealerTurn(dealerCanGoAgain)

func Speaker_DealerArrive():
	var p = randf_range(.9, 1.0)
	speaker_dealerarrive.pitch_scale = p
	speaker_dealerarrive.stream = sound_dealerarrive
	speaker_dealerarrive.play()
	
func Speaker_DealerArrive_Cuffed():
	var p = randf_range(.9, 1.0)
	speaker_dealerarrive.pitch_scale = p
	speaker_dealerarrive.stream = sound_dealerarriveCuffed
	speaker_dealerarrive.play()

func Speaker_HandCrack():
	var randindex = randi_range(0, soundArray_cracks.size() - 1)
	speaker_handCrack.stream = soundArray_cracks[randindex]
	speaker_handCrack.play()

var swapped = false
func SwapDealerMesh():
	if (!swapped):
		dealermesh_normal.set_layer_mask_value(1, false)
		dealermesh_crushed.set_layer_mask_value(1, true)
		swapped = true
	pass

func CoinFlip():
	var result
	if (!roundManager.endless):
		result = randi_range(0, 1)
	else:
		var c_live = shellSpawner.sequenceArray.count("live")
		var c_blank = shellSpawner.sequenceArray.count("blank")
		if (c_live == c_blank): result = randi_range(0, 1)
		if (c_live > c_blank): result = 1
		if (c_live < c_blank): result = 0
	return result
