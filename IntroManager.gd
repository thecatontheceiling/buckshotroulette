class_name IntroManager extends Node

@export var cameraParent : Node3D
@export var intbranch_bathroomdoor : InteractionBranch
@export var intbranch_backroomdoor: InteractionBranch
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

func _ready():
	await get_tree().create_timer(.5, false).timeout
	if (roundManager.playerData.playerEnteringFromDeath && !roundManager.playerData.enteringFromTrueDeath):
		RevivalBathroomStart()
	else:
		MainBathroomStart()
	pass

func MainBathroomStart():
	RestRoomIdle()
	await get_tree().create_timer(.5, false).timeout
	viewblocker.visible = false
	MainTrackLoad()
	await get_tree().create_timer(3, false).timeout
	Hint()
	cursor.SetCursor(true, true)
	intbranch_bathroomdoor.interactionAllowed = true

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
	dia.ShowText_Forever("YOU'RE LUCKY IT LEFT YOU\nWITH A CHARGE!")
	var n = roundManager.playerData.playername
	var firstpart = "GET UP, " + n + "."
	var secondpart = "\nTHE NIGHT IS YOUNG."
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
	intbranch_bathroomdoor.interactionAllowed = true
	pass

func MainTrackLoad():
	var increment = musicmanager.trackArray[roundManager.playerData.currentBatchIndex].bpmIncrement
	bpmlight.delay = increment
	musicmanager.LoadTrack()
	bpmlight.BeginMainLoop()
	speaker_amb_restroom.play()

func Interaction_BackroomDoor():
	roundManager.playerData.stat_doorsKicked += 1
	animator_camera.play("camera enter backroom")
	intbranch_backroomdoor.interactionAllowed = false
	cursor.SetCursor(false, false)

func Interaction_BathroomDoor():
	intbranch_bathroomdoor.interactionAllowed = false
	cursor.SetCursor(false, false)
	animator_camera.play("camera exit bathroom")
	await get_tree().create_timer(5, false).timeout
	cursor.SetCursor(true, true)
	intbranch_backroomdoor.interactionAllowed = true
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
