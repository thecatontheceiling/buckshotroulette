class_name Heaven extends Node

@export var controller : ControllerManager
@export var cursor : CursorManager
@export var viewblocker : Control
@export var speaker_music : AudioStreamPlayer2D
@export var animator : AnimationPlayer
@export var intbranch_heavendoor : InteractionBranch
@export var interactionManager : InteractionManager
@export var buttonArray : Array[ButtonClass]
@export var speaker_button : AudioStreamPlayer2D
@export var ui : Array[Control]
@export var ach : Achievement

func _ready():
	Signals()
	BeginLoop()
	CheckControllerState()
	await get_tree().create_timer(1, false).timeout
	ach.UnlockAchievement("ach2")

func Signals():
	buttonArray[0].is_pressed.connect(Button_Retry)
	buttonArray[1].is_pressed.connect(Button_Exit)
	pass

func CheckControllerState():
	if (GlobalVariables.controllerEnabled):
		controller.SetMainControllerState(true)

func Button_Retry():
	Button_Main("retry")

func Button_Exit():
	Button_Main("exit")

func Button_Main(tag : String):
	speaker_music.stop()
	speaker_button.play()
	cursor.SetCursor(false, false)
	animator.play("fade out")
	for u in ui: u.visible = false
	for cl in buttonArray:
		cl.isActive = false
	await get_tree().create_timer(3.12, false).timeout
	match tag:
		"retry":
			get_tree().change_scene_to_file("res://scenes/death.tscn")
		"exit":
			get_tree().quit()

@export var bracket_door : Node3D
@export var btn_door : Control
@export var btn_retry : Control
@export var btn_exit : Control
func BeginLoop():
	await get_tree().create_timer(1, false).timeout
	speaker_music.play()
	viewblocker.visible = false
	animator.play("camera pan down")
	animator.queue("camera idle")
	await get_tree().create_timer(11.1, false).timeout
	if (cursor.controller_active): btn_door.grab_focus()
	controller.previousFocus = btn_door
	btn_door.visible = true
	cursor.SetCursor(true, true)
	intbranch_heavendoor.interactionAllowed = true

func Fly():
	btn_door.visible = false
	bracket_door.visible = false
	intbranch_heavendoor.interactionAllowed = false
	cursor.SetCursor(false, false)
	animator.play("move")
	await get_tree().create_timer(15.6, false).timeout
	cursor.SetCursor(true, true)
	if (cursor.controller_active): btn_retry.grab_focus()
	controller.previousFocus = btn_retry
	interactionManager.checking = false
	for cl in buttonArray:
		cl.isActive = true
	pass
