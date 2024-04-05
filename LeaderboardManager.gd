class_name Board extends Node

@export var ach : Achievement
@export var crt : CRT
@export var save : SaveFileManager
@export var display_instances : Array[Label3D]
@export var display_instances_alt : Array[Node3D]
var display_instances_act = []
@export var display_overview : Node3D
@export var text_globalpos : Label3D
@export var nocon : Node3D
@export var lock : Node3D
var leaderboard_handle
var details_max: int = Steam.setLeaderboardDetailsMax(2)
var activeArray = []
var active_result_array
var active_entry_count = 0

func _ready():
	display_instances_act = display_instances
	ClearDisplay()
	Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
	Steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
	Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)
	GetLeaderboard()

func _process(delta):
	CheckTimeout()

func PassLeaderboard(range1 : int, range2 : int, alias : String):
	active_range1 = range1
	active_range2 = range2
	active_alias = alias
	SetupLeaderboard()

var initialsetup = false
var active_alias = ""
var active_range1 = 0
var active_range2 = 0
func SetupLeaderboard():
	if (!initialsetup):
		GetLeaderboard()
		Steam.setLeaderboardDetailsMax(2)
		initialsetup = true
		return
	
	DownloadEntries(active_range1, active_range2, active_alias)
	Timeout(true)

func Timeout(s : bool):
	if s:
		t = 0
		checking = true
	else:
		t = 0
		checking = false

func ClearDisplay():
	display_overview.visible = false
	text_globalpos.text = ""
	for disp in display_instances_act:
		var score : Label3D = disp.get_child(0)
		disp.text = ""
		score.text = ""

func TurnOffDisplay():
	crt.speaker_bootuploop.stop()
	crt.speaker_shutdown.play()
	nocon.visible = false
	display_overview.visible = false
	text_globalpos.text = ""
	for disp in display_instances_act:
		var score : Label3D = disp.get_child(0)
		disp.text = ""
		score.text = ""
	for i in crt.array_bootup: i.visible = false
	for i in crt.array_bootuplogo: i.visible = false
	for i in crt.array_partbranch: i.ResetPartition()
	for i in crt.array_stats: i.visible = false
	crt.anim_iconfade.play("RESET")

func UpdateDisplay():
	if (crt.has_exited): return
	var fs = false
	Timeout(false)
	nocon.material_override.albedo_color = Color(1, 1, 1, 0)
	lock.material_override.albedo_color = Color(1, 1, 1, 0)
	display_instances_act = display_instances
	var temp_rank = 0
	var array = active_result_array
	
	if (checking_friends):
		for result in active_result_array:
			temp_rank += 1
			result.global_rank = temp_rank
	
	if (checking_overview):
		var id = Steam.getSteamID()
		var pos_current
		var pos_max
		pos_max = active_entry_count
		display_overview.visible = true
		for result in active_result_array:
			if (result.steam_id == id): 
				pos_current = result.global_rank
				break
		if (pos_current == null):
			lock.material_override.albedo_color = Color(1, 1, 1, 1)
			display_overview.visible = false
		text_globalpos.text = "(" + str(pos_current) + "/" + str(pos_max) + ")"
		display_instances_act = display_instances_alt
	
	var incrementer = 0
	for i in range(display_instances_act.size()):
		if i >= active_result_array.size() or active_result_array[i] == null: continue
		
		var details = active_result_array[i].details
		
		if (details.size() != 2):
			details = [0, 0] 
		
		var active_score = active_result_array[i].score
		var init = details[0]
		var beaten = details[1]
		var sc = init
		for s in range(beaten - 1): sc *= 2
		var check = 0
		active_score = sc
		
		if (!fs):
			ach.UnlockAchievement("ach16")
			crt.speaker_navbeep.pitch_scale = .5
			crt.speaker_navbeep.play()
			fs = true
		var scoretext : Label3D = display_instances_act[i].get_child(0)
		var active_id = active_result_array[i].steam_id
		var active_rank = active_result_array[i].global_rank
		var playername = Steam.getFriendPersonaName(active_id)
		var mainstring = "#" + str(active_rank) + " " + playername
		var char_limit = 18
		
		if mainstring.length() > char_limit:
			mainstring = mainstring.left(char_limit - 1) + "-"
		display_instances_act[i].text = str(mainstring)
		scoretext.text = str(active_score)

var temp_data
@export var stat_shotsFired : Label3D
@export var stat_shellsEjected : Label3D
@export var stat_doorsKicked : Label3D
@export var stat_cigSmoked : Label3D
@export var stat_roundsBeat : Label3D
@export var stat_mlDrank : Label3D
@export var stat_totalCash : Label3D
func UpdateStats():
	if (FileAccess.file_exists(save.savePath_stats)):
		var file = FileAccess.open(save.savePath_stats, FileAccess.READ)
		temp_data = file.get_var()
		stat_shotsFired.text = str(temp_data.shots_fired)
		stat_shellsEjected.text = str(temp_data.shells_ejected)
		stat_doorsKicked.text = str(temp_data.doors_kicked)
		stat_cigSmoked.text = str(temp_data.cigs_smoked)
		stat_roundsBeat.text = str(temp_data.rounds_beat)
		stat_mlDrank.text = str(temp_data.ml_drank)
		stat_totalCash.text = str(temp_data.total_cash)

func GetLeaderboard():
	Steam.findLeaderboard("double_or_nothing")

func UploadScore(rounds_beat, visible_score, initial_score):
	var ar = PackedInt32Array([initial_score, rounds_beat])
	var score_to_upload = initial_score * rounds_beat 
	Steam.uploadLeaderboardScore(score_to_upload, true, ar, leaderboard_handle)

func _on_leaderboard_score_uploaded(success: int, this_handle: int, this_score: Dictionary) -> void:
	if success == 1: 
		print("successfully uploaded score: ", this_score)
	else: print("failed to upload score")

func _on_leaderboard_find_result(handle: int, found: int) -> void:
	if found == 1:
		leaderboard_handle = handle
		print("Leaderboard handle found: %s" % leaderboard_handle)
		SetupLeaderboard()
	else:
		print("No handle was found")

var checking_friends = false
var checking_overview = false
func DownloadEntries(range1 : int, range2 : int, alias : String):
	match alias:
		"top":
			checking_friends = false
			checking_overview = false
			Steam.downloadLeaderboardEntries(range1, range2, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL)
		"overview":
			checking_friends = false
			checking_overview = true
			Steam.downloadLeaderboardEntries(-4, 4, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL_AROUND_USER)
		"friends":
			checking_friends = true
			checking_overview = false
			Steam.downloadLeaderboardEntries(range1, range2, Steam.LEADERBOARD_DATA_REQUEST_FRIENDS)

var t = 0
var max = 2
var checking = false
func CheckTimeout():
	if (checking):
		t += get_process_delta_time()
		if t > max:
			nocon.material_override.albedo_color = Color(1, 1, 1, 1)

var print_cur = 0
var print_max = 48
func _on_leaderboard_scores_downloaded(message: String, this_leaderboard_handle: int, result: Array) -> void:
	print("scores downloaded message: %s" % message)
	
	var leaderboard_handle: int = this_leaderboard_handle
	
	active_result_array = result
	active_entry_count = Steam.getLeaderboardEntryCount(leaderboard_handle)
	
	for this_result in result: if (print_cur <= print_max): print("leaderboard result (", print_cur, "/", print_max, ")", this_result); print_cur += 1
	UpdateDisplay()



















