class_name ItemInteraction extends Node

@export var medicine : Medicine
@export var roundManager : RoundManager
@export var dealerIntelligence : DealerIntelligence
@export var cursor : CursorManager
@export var perm : PermissionManager
@export var itemManager : ItemManager
@export var lerpDuration : float
@export var pos_hand : Vector3
@export var rot_hand : Vector3
@export var pos_hand_stealing : Vector3
@export var rot_hand_stealing : Vector3
var pos_hand_main : Vector3
var rot_hand_main : Vector3
@export var animator_dealerHands : AnimationPlayer
@export var animator_playerHands : AnimationPlayer
@export var camera : CameraManager
@export var shellEject_player : ShellEjectManager
@export var speaker_pickup : AudioStreamPlayer2D
@export var speaker_breakcuffs : AudioStreamPlayer2D
@export var speaker_interaction : AudioStreamPlayer2D
@export var sound_use_burnerphone : AudioStream
@export var sound_use_inverter : AudioStream
@export var sound_use_medicine : AudioStream
@export var sound_use_adrenaline : AudioStream
@export var amounts : Amounts
@export var items: ItemManager
@export var hands : HandManager

var temp_itemParent
var pos_current
var pos_next
var rot_current
var rot_next
var temp_interaction
var temp_indicator
var elapsed = 0
var moving = false

func _ready():
	pos_hand_main = pos_hand
	rot_hand_main = rot_hand

func _process(delta):
	LerpMovement()

var stealing = false
var stealing_fs = false
func PickupItemFromTable(itemParent : Node3D, passedItemName : String):
	if (stealing): 	items.Counter(false)
	#SET INTERACTION PERMISSIONS, HIDE CURSOR
	perm.SetIndicators(false)
	perm.SetInteractionPermissions(false)
	perm.RevertDescriptionUI()
	cursor.SetCursor(false, false)
	roundManager.ClearDeskUI(true)
	#GET VARIABLES
	temp_itemParent = itemParent
	temp_indicator = itemParent.get_child(0)
	temp_interaction = itemParent.get_child(1)
	#STEAL
	if (stealing && stealing_fs): 
		hands.RemoveItem_Remote(temp_itemParent)
		items.RevertItemSteal()
	#PLAY PICKUP SOUND
	speaker_pickup.stream = temp_indicator.sound_pickup
	speaker_pickup.pitch_scale = randf_range(.93, 1.0)
	speaker_pickup.play()
	#INTERACTION PERMISSIONS
	#perm.SetIndicators(false)
	#cursor.SetCursor(false, false)
	#perm.SetInteractionPermissions(false)
	temp_indicator.lerpEnabled = false
	temp_indicator.interactionAllowed = false
	temp_indicator.SnapToMax()
	temp_interaction.interactionAllowed = false
	var temp_name = temp_interaction.itemName
	#LERP
	pos_current = temp_itemParent.transform.origin
	rot_current = temp_itemParent.rotation_degrees
	pos_next = pos_hand
	rot_next = rot_hand
	elapsed = 0
	moving = true
	await get_tree().create_timer(lerpDuration -.1, false).timeout
	moving = false
	if (!stealing): RemovePlayerItemFromGrid(temp_itemParent)
	temp_itemParent.queue_free() #check where player grid index is given, and remove item from player item array, unoccupy given grid
	if (stealing):
		camera.BeginLerp("home")
		stealing_fs = false
		await get_tree().create_timer(.4, false).timeout
		pos_hand = pos_hand_main
		rot_hand = rot_hand_main
		var amountArray : Array[AmountResource] = amounts.array_amounts
		for res in amountArray:
			if (res.itemName == temp_name): 
				res.amount_dealer -= 1
				break
	InteractWith(passedItemName)
	stealing = false

func InteractWith(itemName : String):
	#INTERACTION
	var amountArray : Array[AmountResource] = amounts.array_amounts
	for res in amountArray:
		if (res.itemName == itemName): 
			res.amount_player -= 1
			break
	
	var isdup = false
	for it in roundManager.playerCurrentTurnItemArray:
		if (it == itemName): isdup = true; break
	if (!isdup): roundManager.playerCurrentTurnItemArray.append(itemName)
	match (itemName):
		"handcuffs":
			animator_dealerHands.play("dealer get handcuffed")
			await get_tree().create_timer(1, false).timeout
			camera.BeginLerp("enemy")
			await get_tree().create_timer(1.3, false).timeout
			camera.BeginLerp("dealer handcuffs")
			roundManager.dealerCuffed = true
			dealerIntelligence.dealerAboutToBreakFree = false
			await get_tree().create_timer(1.3, false).timeout
			camera.BeginLerp("home")
			await get_tree().create_timer(.6, false).timeout
			EnablePermissions()
		"beer":
			roundManager.playerData.stat_beerDrank += 330
			var isFinalShell = false
			if (roundManager.shellSpawner.sequenceArray.size() == 1): isFinalShell = true
			animator_playerHands.play("player use beer")
			await get_tree().create_timer(1.4, false).timeout
			shellEject_player.FadeOutShell()
			await get_tree().create_timer(4.2, false).timeout
			#check if ejected last shell
			if (!isFinalShell): EnablePermissions()
			else:
				roundManager.StartRound(true)
		"magnifying glass":
			animator_playerHands.play("player use magnifier")
			var length = animator_playerHands.get_animation("player use magnifier").get_length()
			await get_tree().create_timer(length + .2, false).timeout
			EnablePermissions()
		"cigarettes":
			roundManager.playerData.stat_cigSmoked += 1
			animator_playerHands.play("player use cigarettes")
			await get_tree().create_timer(5, false).timeout
			itemManager.numberOfCigs_player -= 1
			EnablePermissions()
		"handsaw":
			animator_playerHands.play("player use handsaw")
			roundManager.barrelSawedOff = true
			roundManager.currentShotgunDamage = 2
			await get_tree().create_timer(4.28 + .2, false).timeout
			EnablePermissions()
		"expired medicine":
			PlaySound(sound_use_medicine)
			animator_playerHands.play("player use expired pills")
			medicine.UseMedicine()
			#await get_tree().create_timer(4.28 +.2 + 4.3, false).timeout
			#EnablePermissions()
		"inverter":
			PlaySound(sound_use_inverter)
			animator_playerHands.play("player use inverter")
			if (roundManager.shellSpawner.sequenceArray[0] == "live"): roundManager.shellSpawner.sequenceArray[0] = "blank"
			else: roundManager.shellSpawner.sequenceArray[0] = "live"
			await get_tree().create_timer(3.2, false).timeout
			EnablePermissions()
		"burner phone":
			PlaySound(sound_use_burnerphone)
			animator_playerHands.play("player use burner phone")
			await get_tree().create_timer(7.9, false).timeout
			EnablePermissions()
		"adrenaline":
			PlaySound(sound_use_adrenaline)
			animator_playerHands.play("player use adrenaline")
			await get_tree().create_timer(5.3 + .2, false).timeout
			items.SetupItemSteal()
			#EnablePermissions()
	CheckAchievement_koni()
	CheckAchievement_full()

@export var ach : Achievement
func CheckAchievement_koni():
	if ("cigarettes" in roundManager.playerCurrentTurnItemArray and "beer" in roundManager.playerCurrentTurnItemArray and "expired medicine" in roundManager.playerCurrentTurnItemArray): ach.UnlockAchievement("ach9")

func CheckAchievement_full():
	var all = ["handsaw", "magnifying glass", "beer", "cigarettes", "handcuffs", "expired medicine", "burner phone", "adrenaline", "inverter"]
	var pl = roundManager.playerCurrentTurnItemArray
	if (all.size() == pl.size()): ach.UnlockAchievement("ach12")

@export var anim_pp : AnimationPlayer
@export var filter : FilterController
func AdrenalineHit():
	anim_pp.play("adrenaline brightness")
	filter.BeginPan(filter.lowPassDefaultValue, filter.lowPassMaxValue)
	await get_tree().create_timer(6, false).timeout
	filter.BeginPan(filter.effect_lowPass.cutoff_hz, filter.lowPassDefaultValue)

func PlaySound(clip : AudioStream):
	speaker_interaction.stream = clip
	speaker_interaction.play()

func EnablePermissions():
	perm.SetStackInvalidIndicators()
	perm.SetIndicators(true)
	perm.SetInteractionPermissions(true)
	perm.RevertDescriptionUI()
	cursor.SetCursor(true, true)
	roundManager.SetupDeskUI()

func DisableShotgun():
	perm.DisableShotgun()

func DisablePermissions():
	perm.SetIndicators(false)
	perm.SetInteractionPermissions(false)
	perm.RevertDescriptionUI()
	cursor.SetCursor(false, false)
	roundManager.ClearDeskUI(true)

func PlaySound_BreakHandcuffs():
	speaker_breakcuffs.play()

func RemovePlayerItemFromGrid(parent : Node3D):
	var indic = parent.get_child(0)
	var inter = parent.get_child(1)
	itemManager.items_dynamicIndicatorArray.erase(indic)
	itemManager.items_dynamicInteractionArray.erase(inter)
	itemManager.gridOccupiedArray[inter.itemGridIndex] = false
	itemManager.numberOfOccupiedGrids -= 1

func LerpMovement():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / lerpDuration, 0.0, 1.0)
		#c = ease(c, 0.1)
		temp_itemParent.transform.origin = lerp(pos_current, pos_next, c)
		temp_itemParent.rotation_degrees = lerp(rot_current, rot_next, c)
