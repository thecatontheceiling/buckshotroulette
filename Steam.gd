extends Node

var appid : int = 2835570

const PACKET_READ_LIMIT: int = 32

var DATA
var LOBBY_ID = 0
var LOBBY_MEMBERS = []
var USER_ID_LIST_TO_IGNORE : Array[int]
var LOBBY_INVITE_ARG = false
var STEAM_ID = 0
var STEAM_NAME = ""
var ONLINE = false
var HOST_ID = 0

func _ready():
	process_priority = 1000
	set_process_internal(true)
	InitializeSteam()
	
	ONLINE = Steam.loggedOn()
	STEAM_ID = Steam.getSteamID()
	STEAM_NAME = Steam.getPersonaName()
	if GlobalVariables.mp_debugging: STEAM_ID = 1234
	print("online ... ", ONLINE, " ... steam id ... ", STEAM_ID, " ... steam name ... ", STEAM_NAME)

func _process(_delta: float) -> void:
	#OS.delay_msec(17)
	Steam.run_callbacks()

func InitializeSteam():
	if GlobalVariables.using_steam:
			OS.set_environment("SteamAppId", str(appid))
			OS.set_environment("SteamGameId", str(appid))
			
			var INIT: Dictionary = Steam.steamInit(false)
			print("steam init: ", str(INIT))
	else: print("steam not initialized - not running steam version")
