class_name CRT extends Node

@export var exit : ExitManager
var viewing = false

@export var intro : IntroManager
@export var bathroom_normal : VisualInstance3D
@export var bathroom_broken : VisualInstance3D
@export var mask : Node3D

@export var objarray_normal : Array[Node3D]
@export var objarray_broken : Array[Node3D]
@export var anim_intro : AnimationPlayer
@export var array_bootup : Array[Node3D]
@export var array_bootuplogo : Array[Node3D]
@export var array_partbranch : Array[PartitionBranch]
@export var array_stats : Array[Node3D]
@export var screenparent_leaderboard : Node3D
@export var screenparent_stats : Node3D

var window_index = 3
@export var iconbranches : Array[CrtIcon]
@export var anim_iconfade : AnimationPlayer
@export var board : Board

@export var speaker_playerwalk : AudioStreamPlayer2D
@export var speaker_bootuploop : AudioStreamPlayer2D
@export var speaker_shutdown : AudioStreamPlayer2D
@export var speaker_consolebeep : AudioStreamPlayer2D
@export var speaker_buttonpress : AudioStreamPlayer2D
@export var speaker_navbeep : AudioStreamPlayer2D
@export var speaker_melody : AudioStreamPlayer2D
@export var speaker_melodyhide : AudioStreamPlayer2D

var selection_range1 = 1
var selection_range2 = 12

func _ready():
	screenparent_stats.visible = true
	screenparent_leaderboard.visible = false

func _unhandled_input(event):
	if (event.is_action_pressed("ui_accept") && viewing):
		Interaction("window")
	if (event.is_action_pressed("ui_cancel") && viewing):
		Interaction("exit")
	if (event.is_action_pressed("exit game") && viewing):
		Interaction("exit")
	if (event.is_action_pressed("ui_left") && viewing):
		Interaction("left")
	if (event.is_action_pressed("ui_right") && viewing):
		Interaction("right")

func SetCRT(state : bool):
	if (state):
		bathroom_normal.set_layer_mask_value(1, false)
		bathroom_broken.visible = true
		for obj in objarray_normal: obj.visible = false
		for obj in objarray_broken: obj.visible = true
		mask.visible = true
	else:
		bathroom_normal.set_layer_mask_value(1, true)
		bathroom_broken.visible = false
		for obj in objarray_normal: obj.visible = true
		for obj in objarray_broken: obj.visible = false
		mask.visible = false

@export var branch_right : InteractionBranch
@export var branch_left : InteractionBranch
@export var branch_window : InteractionBranch
@export var branch_exit : InteractionBranch

var has_exited = false
func Interaction(alias : String):
	speaker_buttonpress.pitch_scale = randf_range(.8, 1)
	speaker_buttonpress.play()
	match alias:
		"right":
			branch_right.get_parent().get_child(1).Press()
			if (selection_range2 <= board.active_entry_count && window_index == 0):
				selection_range1 += 12
				selection_range2 += 12
		"left":
			branch_left.get_parent().get_child(1).Press()
			if (selection_range1 != 1 && window_index == 0):
				selection_range1 -= 12
				selection_range2 -= 12
		"window":
			branch_window.get_parent().get_child(1).Press()
			CycleWindow()
		"exit":
			has_exited = true
			branch_exit.get_parent().get_child(1).Press()
			viewing = false
			board.TurnOffDisplay()
			intro.DisableInteractionCrt()
			await get_tree().create_timer(.3, false).timeout
			intro.RevertCRT()
			exit.exitAllowed = true

func CycleWindow():
	board.lock.material_override.albedo_color = Color(1, 1, 1, 0)
	selection_range1 = 1
	selection_range2 = 12
	board.ClearDisplay()
	window_index += 1
	if window_index == 4: window_index = 0
	for icon in iconbranches: icon.CheckState(window_index)
	if (window_index == 3): 
		board.nocon.visible = false
		screenparent_leaderboard.visible = false
		screenparent_stats.visible = true
	else: 
		screenparent_leaderboard.visible = true
		screenparent_stats.visible = false
		board.nocon.visible = true
	if (window_index == 0): board.PassLeaderboard(selection_range1, selection_range2, "top")
	if (window_index == 1): 
		board.lock.visible = true
		board.PassLeaderboard(selection_range1, selection_range2, "overview")
	if (window_index == 2): board.PassLeaderboard(1, 49, "friends") #range ignored

func Bootup():
	has_exited = false
	board.lock.material_override.albedo_color = Color(1, 1, 1, 0)
	screenparent_stats.visible = true
	board.UpdateStats()
	window_index = 3
	for icon in iconbranches: icon.CheckState(window_index)
	for line in array_bootup:
		line.visible = true
		await get_tree().create_timer(.07, false).timeout
		speaker_navbeep.pitch_scale = randf_range(1, 1)
		speaker_navbeep.play()
	await get_tree().create_timer(.1, false).timeout
	for part in array_partbranch: 
		part.Loop(true)
		await get_tree().create_timer(.04, false).timeout
		speaker_navbeep.pitch_scale = randf_range(.1, .1)
		speaker_navbeep.play()
	await get_tree().create_timer(1, false).timeout
	for part in array_partbranch: part.Loop(false)
	await get_tree().create_timer(1, false).timeout
	for line in array_bootup: line.visible = false
	await get_tree().create_timer(.2, false).timeout
	speaker_melody.pitch_scale = 2
	speaker_melody.play()
	for line in array_bootuplogo: 
		line.visible = true
		await get_tree().create_timer(.07, false).timeout
	await get_tree().create_timer(2, false).timeout
	for line in array_bootuplogo: line.visible = false
	speaker_melody.stop()
	speaker_melodyhide.play()
	await get_tree().create_timer(.5, false).timeout
	anim_iconfade.play("fade in")
	await get_tree().create_timer(.5, false).timeout
	for i in array_stats: 
		i.visible = true
		await get_tree().create_timer(.07, false).timeout
		speaker_navbeep.pitch_scale = randf_range(.5, .5)
		speaker_navbeep.play()
	await get_tree().create_timer(.3, false).timeout
	intro.EnabledInteractionCRT()
	exit.exitAllowed = false
	viewing = true
