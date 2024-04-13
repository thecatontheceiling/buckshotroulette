extends Node

var currentVersion_nr = "v1.2.2"
var currentVersion_hotfix = 0
var using_steam = true

var currentVersion = ""
var versuffix_steam = " (STEAM)"
var versuffix_itch = " (ITCH.IO)"

var using_gl = false
var controllerEnabled = false
var music_enabled = true

var colorblind = false
var colorblind_color = Color(1, 1, 0)

var default_color_live = Color(1, 0.28, 0.29)
var default_color_blank = Color(0.29, 0.5, 1)
var colorblind_color_live = Color(1, 1, 1)
var colorblind_color_blank = Color(0.34, 0.34, 0.34)

func _ready():
	if using_steam: currentVersion = currentVersion_nr + versuffix_steam
	else: currentVersion = currentVersion_nr + versuffix_itch
