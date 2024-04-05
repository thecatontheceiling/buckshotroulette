class_name IntroManager extends Node

@export var cameraParent : Node3D
@export var intbranch_bathroomdoor : InteractionBranch
@export var intbranch_backroomdoor: InteractionBranch
@export var intbranch_pillbottle : InteractionBranch
@export var parent_pills : Node3D
@export var cursor : CursorManager
@export var roundManager : RoundManager
@export var speaker_amb_restroom : AudioStreamPlayer2D
@export var viewblocker : Control
@export var animator_camera : AnimationPlayer
@export var animator_smokerdude : AnimationPlayer
@export var musicmanager : MusicManager
@export var filter : FilterController
@export var bpmlight : BpmLight
@export var smokerdude_revival : Node3D
@export var speaker_defib : AudioStreamPlayer2D
@export var pos_floor : Vector3
@export var rot_floor : Vector3
@export var animator_pp : AnimationPlayer
@export var cameraShaker : CameraShaker
@export var dia : Dialogue
@export var blockout : Blockout
@export var animator_hint : AnimationPlayer
@export var animator_pillchoice : AnimationPlayer
@export var speaker_pillchoice : AudioStreamPlayer2D
@export var intbranch_pillyes : InteractionBranch
@export var intbranch_pillno : InteractionBranch
@export var intbranch_crt : InteractionBranch
@export var speaker_pillselect : AudioStreamPlayer2D
@export var anim_revert : AnimationPlayer
@export var endlessmode : Endless
@export var btn_bathroomdoor : Control
@export var btn_pills : Control
@export var btn_pillsYes : Control
@export var btn_pillsNo : Control
@export var btn_backroom : Control
@export var btn_screen : Control #append this with controller UI element
@export var controller : ControllerManager
@export var unlocker : Unlocker
@export var crtManager : CRT
@export var col_pillchoice : Array[CollisionShape3D]
@export var anim_pillflicker : AnimationPlayer

var allowingPills = false
func _ready():
	parent_pills.visible = false
	allowingPills = false
	SetControllerState()
	await get_tree().create_timer(.5, false).timeout
	if (roundManager.playerData.playerEnteringFromDeath && !roundManager.playerData.enteringFromTrueDeath):
		RevivalBathroomStart()
	else:
		MainBathroomStart()
	if (roundManager.playerData.playerEnteringFromDeath or roundManager.playerData.enteringFromTrueDeath): 
		parent_pills.visible = false
		allowingPills = false
	if (!roundManager.playerData.playerEnteringFromDeath && !roundManager.playerData.enteringFromTrueDeath):
		if (FileAccess.file_exists(unlocker.savepath)):
			parent_pills.visible = true
			crtManager.SetCRT(true)
			allowingPills = true

var counting = false
var count_current = 0
var count_max = 60
var fs1 = false
func _process(delta):
	if (counting): CountTimer()
	
func CountTimer():
	if (counting): count_current += get_process_delta_time()
	if (count_current > count_max && !fs1):
		ach.UnlockAchievement("ach14")
		fs1 = true

func SetControllerState():
	if (GlobalVariables.controllerEnabled):
		controller.SetMainControllerState(true)

func MainBathroomStart():
	RestRoomIdle()
	await get_tree().create_timer(.5, false).timeout
	viewblocker.visible = false
	MainTrackLoad()
	await get_tree().create_timer(3, false).timeout
	Hint()
	cursor.SetCursor(true, true)
	intbranch_bathroomdoor.interactionAllowed = true
	if (allowingPills): 
		intbranch_pillbottle.interactionAllowed = true
		intbranch_crt.interactionAllowed = true
	if (cursor.controller_active): btn_bathroomdoor.grab_focus()
	controller.previousFocus = btn_bathroomdoor
	if (allowingPills): btn_pills.visible = true; btn_screen.visible = true
	btn_bathroomdoor.visible = true
	anim_pillflicker.play("flicker pill")

func Hint():
	await get_tree().create_timer(1, false).timeout
	if (!roundManager.playerData.seenHint):
		animator_hint.play("show")
		roundManager.playerData.seenHint = true

func RevivalBathroomStart():
	cameraParent.transform.origin = pos_floor
	cameraParent.rotation_degrees = rot_floor
	#animator_smokerdude.stop(true)
	smokerdude_revival.visible = true
	await get_tree().create_timer(1, false).timeout
	speaker_defib.play()
	await get_tree().create_timer(.85, false).timeout
	dia.speaker_click.stream = dia.soundArray_clicks[0]
	animator_smokerdude.play("revive player")
	cameraShaker.Shake()
	animator_pp.play("revival brightness")
	viewblocker.visible = false
	MainTrackLoad()
	await get_tree().create_timer(.5, false).timeout
	animator_smokerdude.play("revive player")
	dia.ShowText_Forever(tr("YOURE LUCKY"))
	var n = roundManager.playerData.playername
	var firstpart = tr("GET UP") % [n]
	#tr("GAME_STATUS_%d" % status_index)
	var secondpart = "\n"+tr("THE NIGHT")
	var full = firstpart + secondpart
	await get_tree().create_timer(4, false).timeout
	dia.ShowText_Forever(full)
	await get_tree().create_timer(4, false).timeout
	dia.HideText()
	animator_pp.play("brightness fade out")
	await get_tree().create_timer(2.05, false).timeout
	smokerdude_revival.visible = false
	RestRoomIdle()
	animator_pp.play("brightness fade in")
	dia.speaker_click.stream = dia.soundArray_clicks[3]
	await get_tree().create_timer(3, false).timeout
	cursor.SetCursor(true, true)
	if (allowingPills): 
		intbranch_pillbottle.interactionAllowed = true
		intbranch_crt.interactionAllowed = true
		btn_pills.visible = true
		btn_screen.visible = true
		anim_pillflicker.play("flicker pill")
	if (cursor.controller_active): btn_bathroomdoor.grab_focus()
	controller.previousFocus = btn_bathroomdoor
	btn_bathroomdoor.visible = true
	intbranch_bathroomdoor.interactionAllowed = true
	pass

func MainTrackLoad():
	var increment = musicmanager.trackArray[roundManager.playerData.currentBatchIndex].bpmIncrement
	bpmlight.delay = increment
	musicmanager.LoadTrack()
	bpmlight.BeginMainLoop()
	speaker_amb_restroom.play()

func Interaction_PillBottle():
	anim_pillflicker.play("RESET")
	cursor.SetCursor(false, false)
	intbranch_bathroomdoor.interactionAllowed = false
	intbranch_pillbottle.interactionAllowed = false
	intbranch_crt.interactionAllowed = false
	btn_pills.visible = false
	btn_screen.visible = false
	btn_bathroomdoor.visible = false
	animator_camera.play("camera check pills")
	await get_tree().create_timer(.6, false).timeout
	speaker_pillchoice.play()
	await get_tree().create_timer(.3, false).timeout
	animator_pillchoice.play("show")
	await get_tree().create_timer(.7, false).timeout
	cursor.SetCursor(true, true)
	
	if (cursor.controller_active): btn_pillsNo.grab_focus()
	controller.previousFocus = btn_pillsNo
	for c in col_pillchoice: c.disabled = false
	btn_pillsNo.visible = true
	btn_pillsYes.visible = true
	intbranch_pillyes.interactionAllowed = true
	intbranch_pillno.interactionAllowed = true

@export var intbs_crtbuttons : Array[InteractionBranch]
func Interaction_CRT():
	StartSound()
	anim_pillflicker.play("RESET")
	cursor.SetCursor(false, false)
	intbranch_bathroomdoor.interactionAllowed = false
	intbranch_pillbottle.interactionAllowed = false
	intbranch_crt.interactionAllowed = false
	btn_pills.visible = false
	btn_bathroomdoor.visible = false
	btn_screen.visible = false
	animator_camera.play("camera check crt")
	await get_tree().create_timer(2.6, false).timeout
	crtManager.Bootup()
	await get_tree().create_timer(0.54, false).timeout

func StartSound():
	crtManager.speaker_playerwalk.play()
	await get_tree().create_timer(2.04, false).timeout
	crtManager.speaker_bootuploop.play()

func EnabledInteractionCRT():
	cursor.SetCursor(true, true)
	for b in intbs_crtbuttons: b.interactionAllowed = true

func DisableInteractionCrt():
	cursor.SetCursor(false, false)
	for b in intbs_crtbuttons: b.interactionAllowed = false

@export var ach : Achievement
@export var pill_unlock : Unlocker
func SelectedPill(selected : bool):
	if (selected): 
		pill_unlock.IncrementAmount()
		anim_pillflicker.play("RESET")
	cursor.SetCursor(false, false)
	for c in col_pillchoice: c.disabled = true
	animator_pp.play("brightness fade out")
	anim_revert.play("revert")
	animator_pillchoice.play("hide")
	speaker_pillchoice.stop()
	speaker_pillselect.play()
	btn_pillsYes.visible = false
	btn_pillsNo.visible = false
	intbranch_pillyes.interactionAllowed = false
	intbranch_pillno.interactionAllowed = false
	await get_tree().create_timer(2.05, false).timeout
	if(selected): 
		parent_pills.visible = false
		endlessmode.SetupEndless()
	RestRoomIdle()
	if selected: crtManager.SetCRT(false)
	animator_pp.play("brightness fade in")
	await get_tree().create_timer(.6, false).timeout
	cursor.SetCursor(true, true)
	if (selected): ach.UnlockAchievement("ach3")
	intbranch_bathroomdoor.interactionAllowed = true
	btn_bathroomdoor.visible = true
	if(!selected): 
		intbranch_pillbottle.interactionAllowed = true
		intbranch_crt.interactionAllowed = true
		btn_pills.visible = true
		btn_screen.visible = true
		anim_pillflicker.play("flicker pill")
	if (cursor.controller_active): btn_bathroomdoor.grab_focus()
	controller.previousFocus = btn_bathroomdoor
	pass

func RevertCRT():
	animator_pp.play("brightness fade out")
	#anim_revert.play("revert")
	btn_pillsYes.visible = false
	btn_pillsNo.visible = false
	intbranch_pillyes.interactionAllowed = false
	intbranch_pillno.interactionAllowed = false
	await get_tree().create_timer(2.05, false).timeout
	RestRoomIdle()
	animator_pp.play("brightness fade in")
	anim_pillflicker.play("flicker pill")
	await get_tree().create_timer(.6, false).timeout
	cursor.SetCursor(true, true)
	intbranch_bathroomdoor.interactionAllowed = true
	btn_bathroomdoor.visible = true
	intbranch_pillbottle.interactionAllowed = true
	intbranch_crt.interactionAllowed = true
	btn_pills.visible = true
	btn_screen.visible = true
	if (cursor.controller_active): btn_bathroomdoor.grab_focus()
	controller.previousFocus = btn_bathroomdoor

func Interaction_BackroomDoor():
	roundManager.playerData.stat_doorsKicked += 1
	animator_camera.play("camera enter backroom")
	intbranch_backroomdoor.interactionAllowed = false
	btn_backroom.visible = false
	cursor.SetCursor(false, false)
	counting = false

func Interaction_BathroomDoor():
	intbranch_bathroomdoor.interactionAllowed = false
	cursor.SetCursor(false, false)
	btn_pills.visible = false
	btn_screen.visible = false
	btn_bathroomdoor.visible = false
	animator_camera.play("camera exit bathroom")
	await get_tree().create_timer(5, false).timeout
	cursor.SetCursor(true, true)
	if (cursor.controller_active): btn_backroom.grab_focus()
	controller.previousFocus = btn_backroom
	btn_backroom.visible = true
	intbranch_backroomdoor.interactionAllowed = true
	intbranch_pillbottle.interactionAllowed = false
	intbranch_crt.interactionAllowed = false
	counting = true
	pass


func BeginGame():
	blockout.HideClub()
	roundManager.BeginMainGame()

func PanFilter():
	filter.BeginPan(filter.lowPassMaxValue, filter.lowPassDefaultValue)
	pass

func KickDoorBackroom():
	pass

func KickDoorLobby():
	roundManager.playerData.stat_doorsKicked += 1
	await get_tree().create_timer(.25, false).timeout
	filter.BeginPan(filter.lowPassDefaultValue, filter.lowPassMaxValue)
	speaker_amb_restroom.stop()

func RestRoomIdle():
	animator_camera.play("camera idle bathroom")
	pass
