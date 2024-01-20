class_name MenuManager extends Node

@export var savefile : SaveFileManager
@export var cursor : CursorManager
@export var animator_intro : AnimationPlayer
@export var speaker_music : AudioStreamPlayer2D
@export var speaker_start : AudioStreamPlayer2D
@export var buttons : Array[ButtonClass]
@export var screen_main : Array[Control]
@export var screen_creds : Array[Control]
@export var title : Node3D
@export var waterfalls : Array[AnimationPlayer]

func _ready():
	Show("main")
	buttons[0].connect("is_pressed", Start)
	buttons[1].connect("is_pressed", Credits)
	buttons[2].connect("is_pressed", Exit)
	buttons[3].connect("is_pressed", Return)
	Intro()

func Intro():
	cursor.SetCursor(false, false)
	await get_tree().create_timer(.5, false).timeout
	speaker_music.play()
	animator_intro.play("splash screen")
	await get_tree().create_timer(9, false).timeout
	cursor.SetCursor(true, false)
	buttons[0].isActive = true
	buttons[1].isActive = true
	buttons[2].isActive = true
	pass

func Buttons(state : bool):
	if (!state):
		for i in buttons: i.isActive = false
	else: for i in buttons: i.isActive = true

func Show(what : String):
	title.visible = false
	for i in screen_main: i.visible = false
	for i in screen_creds: i.visible = false
	if (what == "credits"): for i in screen_creds: i.visible = true
	else: if (what == "main"): 
		for i in screen_main: i.visible = true 
		title.visible = true
	else:
		pass

func ResetButtons():
	for b in buttons:
		b.ui.modulate.a = 1
	cursor.SetCursorImage("point")

func Start():
	Buttons(false)
	ResetButtons()
	Show("e")
	speaker_music.stop()
	animator_intro.play("snap")
	for w in waterfalls: w.pause()
	speaker_start.play()
	cursor.SetCursor(false, false)
	savefile.ClearSave()
	await get_tree().create_timer(4, false).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func Credits():
	ResetButtons()
	Show("credits")
	Buttons(false)
	buttons[3].isActive = true
	ResetButtons()

func Exit():
	Buttons(false)
	ResetButtons()
	speaker_music.stop()
	animator_intro.play("snap2")
	cursor.SetCursor(false, false)
	await get_tree().create_timer(.5, false).timeout
	get_tree().quit()

func Return():
	Show("main")
	Buttons(true)
	buttons[3].isActive = false
	ResetButtons()
