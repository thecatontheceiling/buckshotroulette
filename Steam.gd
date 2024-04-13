extends Node

var appid : int = 2835570

func _ready():
	if GlobalVariables.using_steam:
		process_priority = 1000
		set_process_internal(true)
		InitializeSteam()

func _process(_delta: float) -> void:
	if GlobalVariables.using_steam: Steam.run_callbacks()

func InitializeSteam():
	if GlobalVariables.using_steam:
			OS.set_environment("SteamAppId", str(appid))
			OS.set_environment("SteamGameId", str(appid))
			
			var INIT: Dictionary = Steam.steamInit(false)
			print("steam init: ", str(INIT))
	else: print("steam not initialized - not running steam version")
