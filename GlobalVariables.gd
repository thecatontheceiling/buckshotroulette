extends Node

var currentVersion_nr = "v2.1.0"
var currentVersion_hotfix = 10
var using_steam = true

var currentVersion = ""
var versuffix_steam = " (STEAM)"
var versuffix_itch = " (ITCH.IO)"

var discord_link = "https://discord.gg/UdjMNaKkQe"

var using_gl = false
var controllerEnabled = false
var music_enabled = true
var current_button_hovered_over : Control

var colorblind = false
var colorblind_color = Color(1, 1, 0)
var greyscale_death = false
var looping_input_main = false
var looping_input_secondary = false
var cursor_state_after_toggle = false

var default_color_live = Color(1, 0.28, 0.29)
var default_color_blank = Color(0.29, 0.5, 1)
var colorblind_color_live = Color(1, 1, 1)
var colorblind_color_blank = Color(0.34, 0.34, 0.34)

var mp_debugging = false #mp debugging with temporary bots
var mp_printing_to_console = true #whether or not disconnect messages, etc are printed to console
var mp_debug_keys_enabled = false #whether or not the debug keys are enabled
var printing_packets = true #whether or not packets get logged
var sending_lobby_change_alerts_to_console = false #whether or not lobby status changes are sent to the console in lobby
var forcing_lobby_enter_from_main_menu = false #whether or not the game immediately goes to lobby scene from main menu
var message_to_forward = "" #message to forward through scenes, for instance a disconnect message
var original_volume_linear_interaction #original volume for bus 3 (interactions)
var original_volume_linear_music #original volume for bus 1 (music)
var debug_round_index_to_end_game_at : int #the game ends when this round index is met
var disband_lobby_after_exiting_main_scene = false #whether or not the lobby is disbanded when exiting to lobby scene from main
var exiting_to_lobby_after_inactivity = false  #when a user is inactive for a set amount of time, all users exit to the lobby
var timeouts_enabled = false #whether or not timeouts are enabled for adrenaline, turn, shotgun target selection, item grabbing, etc
var skipping_intro = false #whether or not to skip the intro
var lobby_id_found_in_command_line = 0 #lobby ID for when a player joins through an invite with the game closed
var running_short_intro_in_lobby_scene : bool = false #if the user is entering the lobby scene from mp main, or has a command line lobby ID, skip the bootup animation
var command_line_checked = false #whether or not the command line has been checked on running the game
var version_to_check : String = "" #full version string that includes major, minor, patch, hotfix
var steam_id_version_checked_array : Array[int] #array of steam IDs that have the version checked. this must match the steam lobby member array IDs
var returning_to_main_menu_on_popup_close : bool #whether or not closing the popup window will return the user to the main menu
var active_match_customization_dictionary : Dictionary #match customization dictionary that will be used in the game. gets cleared on game end etc
var stashed_match_customization_dictionary : Dictionary #match customization dictionary that will be stored in the current game session
var previous_match_customization_differences : Dictionary #previously active match customization differences that were received by the host

var debug_match_customization = {
	"number_of_rounds": 3,
	"skipping_intro": false,
	"round_property_array": [
		{
			"round_index": 0,
			"starting_health": -1,
			"item_properties": [
				{
					"item_id": 1, #handsaw
					"max_per_player": 2,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 2, #magnifying glass
					"max_per_player": 2,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 3, #jammer
					"max_per_player": 1,
					"max_on_table": 1,
					"is_ingame": true}, 
				{
					"item_id": 4, #cigarettes
					"max_per_player": 1,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 5, #beer
					"max_per_player": 8,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 6, #burner phone
					"max_per_player": 8,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 8, #adrenaline
					"max_per_player": 4,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 9, #inverter
					"max_per_player": 4,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 10, #remote
					"max_per_player": 1,
					"max_on_table": 2,
					"is_ingame": true}],
			"shell_load_properties": [
				{
					"sequence_index": 0,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 1,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 2,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 3,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},]},
		{
			"round_index": 1,
			"starting_health": -1,
			"item_properties": [
				{
					"item_id": 1, #handsaw
					"max_per_player": 2,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 2, #magnifying glass
					"max_per_player": 2,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 3, #jammer
					"max_per_player": 1,
					"max_on_table": 1,
					"is_ingame": true}, 
				{
					"item_id": 4, #cigarettes
					"max_per_player": 1,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 5, #beer
					"max_per_player": 8,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 6, #burner phone
					"max_per_player": 8,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 8, #adrenaline
					"max_per_player": 4,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 9, #inverter
					"max_per_player": 4,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 10, #remote
					"max_per_player": 1,
					"max_on_table": 2,
					"is_ingame": true}],
			"shell_load_properties": [
				{
					"sequence_index": 0,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 1,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 2,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 3,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},]
		},
		{
			"round_index": 2,
			"starting_health": -1,
			"item_properties": [
				{
					"item_id": 1, #handsaw
					"max_per_player": 2,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 2, #magnifying glass
					"max_per_player": 2,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 3, #jammer
					"max_per_player": 1,
					"max_on_table": 1,
					"is_ingame": true}, 
				{
					"item_id": 4, #cigarettes
					"max_per_player": 1,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 5, #beer
					"max_per_player": 8,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 6, #burner phone
					"max_per_player": 8,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 8, #adrenaline
					"max_per_player": 4,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 9, #inverter
					"max_per_player": 4,
					"max_on_table": 32,
					"is_ingame": true}, 
				{
					"item_id": 10, #remote
					"max_per_player": 1,
					"max_on_table": 2,
					"is_ingame": true}],
			"shell_load_properties": [
				{
					"sequence_index": 0,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 1,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 2,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},
				{
					"sequence_index": 3,
					"number_of_blanks": -1,
					"number_of_lives": -1,
					"number_of_items": -1,},]
		}
		]
}

func _ready():
	if using_steam: currentVersion = currentVersion_nr + versuffix_steam
	else: currentVersion = currentVersion_nr + versuffix_itch
	debug_round_index_to_end_game_at = 2
	original_volume_linear_interaction = db_to_linear(AudioServer.get_bus_volume_db(3))
	original_volume_linear_music = db_to_linear(AudioServer.get_bus_volume_db(1))
	version_to_check = currentVersion_nr + "." + str(currentVersion_hotfix)
	print("running full version name: ", version_to_check)
	if GlobalVariables.mp_debugging:
		TranslationServer.set_locale("EN")
		active_match_customization_dictionary = debug_match_customization

func _unhandled_input(event):
	if GlobalVariables.mp_debugging:
		if event.is_action_pressed("debug_q"):
			SwapLanguage(false)
		if event.is_action_pressed("debug_e"):
			SwapLanguage(true)
		if event.is_action_pressed("-"):
			Engine.time_scale = .05
		if event.is_action_pressed(","):
			Engine.time_scale = 1
		if event.is_action_pressed("."):
			Engine.time_scale = 10
		if event.is_action_pressed("end"):
			Engine.time_scale = 0

var language_array = ["EN", "EE", "RU", "ES LATAM", "ES", "FR", "IT", "JA", "KO", "PL", "PT", "DE", "TR", "UA", "ZHS", "ZHT"]
var index = 0
func SwapLanguage(dir : bool):
	if dir:
		if index == language_array.size() - 1:
			index = 0
		else:
			index += 1
	else:
		if index == 0:
			index = language_array.size() - 1
		else:
			index -= 1
	TranslationServer.set_locale(language_array[index])
	print("setting locale to: ", language_array[index])




































