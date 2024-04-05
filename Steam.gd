extends Node

var appid : int = 2835570

func _ready():
	process_priority = 1000
	set_process_internal(true)
	InitializeSteam()

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func InitializeSteam():
	OS.set_environment("SteamAppId", str(appid))
	OS.set_environment("SteamGameId", str(appid))
	
	var INIT: Dictionary = Steam.steamInit(false)
	print("steam init: ", str(INIT))
