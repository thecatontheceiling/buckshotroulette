class_name MenuManager extends Node

@export var savefile : SaveFileManager
@export var cursor : CursorManager
@export var animator_intro : AnimationPlayer
@export var speaker_music : AudioStreamPlayer2D
@export var speaker_start : AudioStreamPlayer2D
@export var buttons : Array[ButtonClass]
@export var buttons_options : Array[ButtonClass]
@export var screens : Array[Control]
@export var parent_main : Control
@export var parent_creds : Control
@export var parent_suboptions : Control
@export var parent_audiovideo : Control
@export var parent_language : Control
@export var parent_controller : Control
@export var parent_rebinding : Control
@export var title : Node3D
@export var waterfalls : Array[AnimationPlayer]
@export var optionmanager : OptionsManager
@export var controller : ControllerManager
@export var mouseblocker : Control
@export var anim_creds : AnimationPlayer
@export var version : Label

var viewing_intro : bool

func _ready():
	Show("main")
	buttons[0].connect("is_pressed", Start)
	buttons[1].connect("is_pressed", SubOptions)
	buttons[2].connect("is_pressed", Credits)
	buttons[3].connect("is_pressed", Exit)
	buttons[4].connect("is_pressed", ReturnToLastScreen)
	buttons[5].connect("is_pressed", ReturnToLastScreen)
	buttons[6].connect("is_pressed", ReturnToLastScreen)
	buttons[7].connect("is_pressed", Options_AudioVideo)
	buttons[8].connect("is_pressed", Options_Language)
	buttons[9].connect("is_pressed", Options_Controller)
	buttons[10].connect("is_pressed", ReturnToLastScreen)
	buttons[11].connect("is_pressed", ReturnToLastScreen)
	buttons[16].connect("is_pressed", RebindControls)
	buttons[17].connect("is_pressed", ReturnToLastScreen)
	buttons[18].connect("is_pressed", ResetControls)
	buttons[19].connect("is_pressed", DiscordLink)
	buttons[22].connect("is_pressed", StartMultiplayer)
	
	buttons_options[0].connect("is_pressed", IncreaseVol)
	buttons_options[1].connect("is_pressed", DecreaseVol)
	buttons_options[2].connect("is_pressed", SetFull)
	buttons_options[3].connect("is_pressed", SetWindowed)
	buttons_options[4].connect("is_pressed", ControllerEnable)
	buttons_options[5].connect("is_pressed", ControllerDisable)
	buttons_options[6].connect("is_pressed", ToggleColorblind)
	buttons_options[7].connect("is_pressed", ToggleMusic)
	
	version.text = GlobalVariables.currentVersion
	
	Intro()

func _process(delta):
	T()

func CheckCommandLine():
	var arguments = OS.get_cmdline_args()
	for argument in arguments:
		if (arguments.size() > 0):
			#if (GlobalSteam.LOBBY_INVITE_ARG):
			#	join_lobby(int(argument))
			pass
	
		if argument == "+connect_lobby":
			GlobalSteam.LOBBY_INVITE_ARG = true

var failsafed = true
var fs2 = false
func _input(event):
	if (event.is_action_pressed("ui_cancel") && failsafed):
		if (currentScreen != "main"): ReturnToLastScreen()
	if (event.is_action_pressed("exit game") && failsafed):
		if (currentScreen != "main"): ReturnToLastScreen()
	if (event.is_action_pressed("exit game") && !fs2 && viewing_intro):
		SkipIntro()
		fs2 = true

func Intro():
	cursor.SetCursor(false, false)
	if GlobalVariables.lobby_id_found_in_command_line != 0 && !GlobalVariables.command_line_checked:
		print("lobby id found in command line. dont run the menu intro")
		return
	viewing_intro = true
	speaker_music.play()
	animator_intro.play("splash screen")
	c = true

func SkipIntro():
	c = false
	animator_intro.stop()
	animator_intro.play("skip intro")
	FinishIntro()

func FinishIntro():
	viewing_intro = false
	mouseblocker.visible = false
	cursor.SetCursor(true, false)
	controller.settingFilter = true
	controller.SetMainControllerState(controller.controller_currently_enabled)
	if (cursor.controller_active): firstFocus_main.grab_focus()
	controller.previousFocus = firstFocus_main
	assigningFocus = true

var t = 0
var c = false
var fs = false
func T():
	if c: t+= get_process_delta_time()
	if t > 9 && !fs:
		FinishIntro()
		fs = true

func Buttons(state : bool):
	if (!state):
		for i in buttons:
			i.isActive = false
			i.SetFilter("ignore")
	else: 
		for i in buttons:
			i.isActive = true
			i.SetFilter("stop")

@export var firstFocus_main : Control
@export var firstFocus_subOptions : Control
@export var firstFocus_credits : Control
@export var firstFocus_audioVideo : Control
@export var firstFocus_language : Control
@export var firstFocus_controller : Control
@export var firstFocus_rebinding : Control

var assigningFocus = false
var lastScreen = "main"
var currentScreen = "main"
func Show(what : String):
	lastScreen = currentScreen
	currentScreen = what
	var focus
	title.visible = false
	for screen in screens: screen.visible = false
	if (what == "main" or what == "sub options"): title.visible = true
	match(what):
		"main":
			parent_main.visible = true
			focus = firstFocus_main
		"sub options":
			parent_suboptions.visible = true
			focus = firstFocus_subOptions
		"credits":
			parent_creds.visible = true
			focus = firstFocus_credits
			anim_creds.play("RESET")
			anim_creds.play("show credits")
		"audio video":
			parent_audiovideo.visible = true
			focus = firstFocus_audioVideo
		"language":
			parent_language.visible = true
			focus = firstFocus_language
		"controller":
			parent_controller.visible = true
			focus = firstFocus_controller
		"rebind controls":
			parent_rebinding.visible = true
			focus = firstFocus_rebinding
	if (assigningFocus):
		if (cursor.controller_active): focus.grab_focus()
		controller.previousFocus = focus

func ReturnToLastScreen():
	print("return to last screen")
	if currentScreen == "credits": anim_creds.play("RESET")
	if (currentScreen) == "sub options": lastScreen = "main"
	if (currentScreen) == "rebind controls": lastScreen = "sub options"
	if (currentScreen == "audio video" or currentScreen == "language" or currentScreen == "controller" or currentScreen == "rebind controls"): optionmanager.SaveSettings()
	Show(lastScreen)
	ResetButtons()

func ResetButtons():
	#for b in buttons:
	#	b.ui.modulate.a = 1
	cursor.SetCursorImage("point")

func Start():
	Buttons(false)
	ResetButtons()
	for screen in screens: screen.visible = false
	title.visible = false
	controller.previousFocus = null
	speaker_music.stop()
	animator_intro.play("snap")
	for w in waterfalls: w.pause()
	speaker_start.play()
	cursor.SetCursor(false, false)
	savefile.ClearSave()
	await get_tree().create_timer(4, false).timeout
	print("changing scene to: main")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func StartMultiplayer():
	if !GlobalSteam.ONLINE:
		GlobalVariables.message_to_forward = tr("MP_UI LOBBY NO CONNECTION")
		GlobalVariables.returning_to_main_menu_on_popup_close = true
		GlobalVariables.running_short_intro_in_lobby_scene = true
	
	Buttons(false)
	ResetButtons()
	for screen in screens: screen.visible = false
	title.visible = false
	controller.previousFocus = null
	speaker_music.stop()
	animator_intro.play("snap")
	for w in waterfalls: w.pause()
	speaker_start.play()
	cursor.SetCursor(false, false)
	savefile.ClearSave()
	await get_tree().create_timer(4, false).timeout
	print("changing scene to: lobby")
	get_tree().change_scene_to_file("res://multiplayer/scenes/mp_lobby.tscn")

func Credits():
	Show("credits")
	ResetButtons()

func Exit():
	Buttons(false)
	ResetButtons()
	speaker_music.stop()
	animator_intro.play("snap2")
	cursor.SetCursor(false, false)
	await get_tree().create_timer(.5, false).timeout
	get_tree().quit()

func DisableMenu():
	Buttons(false)
	ResetButtons()
	speaker_music.stop()
	animator_intro.play("snap2")
	cursor.SetCursor(false, false)

func ResetControls():
	optionmanager.ResetControls()
	ResetButtons()

func ToggleMusic():
	optionmanager.AdjustSettings_music()
func ToggleColorblind():
	optionmanager.ToggleColorblind()
func DiscordLink():
	OS.shell_open(GlobalVariables.discord_link)
func RebindControls():
	Show("rebind controls")
	ResetButtons()
func SubOptions():
	Show("sub options")
	ResetButtons()
func Options_AudioVideo():
	Show("audio video")
	ResetButtons()
func Options_Language():
	Show("language")
	ResetButtons()
func Options_Controller():
	Show("controller")
	ResetButtons()
	pass
func IncreaseVol():
	optionmanager.Adjust("increase")
func DecreaseVol():
	optionmanager.Adjust("decrease")
func SetWindowed():
	optionmanager.Adjust("windowed")
func SetFull():
	optionmanager.Adjust("fullscreen")
func ControllerEnable():
	optionmanager.Adjust("controller enable")
func ControllerDisable():
	optionmanager.Adjust("controller disable")
