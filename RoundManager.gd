class_name RoundManager extends Node

@export var sign : Signature
@export var brief : BriefcaseMachine
@export var defibCutter : DefibCutter
@export var segmentManager : SegmentManager
@export var handcuffs : HandcuffManager
@export var itemManager : ItemManager
@export var death : DeathManager
@export var playerData : PlayerData
@export var cursor : CursorManager
@export var perm : PermissionManager
@export var health_player : int
@export var health_opponent : int
@export var batchArray : Array[Node]
@export var roundArray : Array[RoundClass]
@export var shellSpawner : ShellSpawner
@export var shellLoader : ShellLoader
@export var currentRound : int
var mainBatchIndex : int
@export var healthCounter : HealthCounter
@export var dealerAI : DealerIntelligence
@export var typingManager : TypingManager
@export var camera : CameraManager
@export var roundIndicatorPositions : Array[Vector3]
@export var roundIndicatorParent : Node3D
@export var roundIndicator : Node3D
@export var animator_roundIndicator : AnimationPlayer
@export var speaker_roundHum : AudioStreamPlayer3D
@export var speaker_roundShutDown : AudioStreamPlayer3D
@export var speaker_winner : AudioStreamPlayer3D
@export var ui_winner : Node3D
@export var animator_dealer : AnimationPlayer
@export var ejectManagers : Array[ShellEjectManager]
@export var animator_dealerHands : AnimationPlayer
@export var gameover : GameOverManager
@export var musicManager : MusicManager
@export var deficutter : DefibCutter

var shellLoadingSpedUp = false
var dealerItems : Array[String]
var currentShotgunDamage = 1
var dealerAtTable = false
var dealerHasGreeted = false
var dealerCuffed = false
var playerCuffed = false
var playerAboutToBreakFree = false
var waitingForDealerReturn = false
var barrelSawedOff = false
var defibCutterReady = false
var trueDeathActive = false

func _ready():
	HideDealer()
	#await get_tree().create_timer(.2, false).timeout
	pass

func BeginMainGame():
	MainBatchSetup(true)

func HideDealer():
	animator_dealerHands.play("hide hands")
	animator_dealer.play("hide dealer")

#MAIN BATCH SETUP
var lerping = false
var enteringFromWaiver = false
func MainBatchSetup(dealerEnterAtStart : bool):
	if (!enteringFromWaiver):
		if (lerping): camera.BeginLerp("enemy")
		currentRound = 0
		if (!dealerAtTable && dealerEnterAtStart):
			await get_tree().create_timer(.5, false).timeout
			if (!dealerCuffed): animator_dealerHands.play("dealer hands on table")
			else: animator_dealerHands.play("dealer hands on table cuffed")
			animator_dealer.play("dealer return to table")
			await get_tree().create_timer(2, false).timeout
			var greeting = true
			if (!playerData.hasSignedWaiver):
				shellLoader.dialogue.ShowText_Forever("PLEASE SIGN THE WAIVER.")
				await get_tree().create_timer(2.3, false).timeout
				shellLoader.dialogue.HideText()
				camera.BeginLerp("home")
				sign.AwaitPickup()
				return
			if (!dealerHasGreeted && greeting):
				var tempstring
				if (!playerData.enteringFromTrueDeath): tempstring = "WELCOME BACK."
				else: 
					shellSpawner.dialogue.dealerLowPitched = true
					tempstring = "..."
				if (!playerData.playerEnteringFromDeath):
					shellLoader.dialogue.ShowText_Forever("WELCOME TO\nBUCKSHOT ROULETTE.")
					await get_tree().create_timer(2.3, false).timeout
					shellLoader.dialogue.HideText()
					dealerHasGreeted = true
				else:
					shellLoader.dialogue.ShowText_Forever(tempstring)
					await get_tree().create_timer(2.3, false).timeout
					shellLoader.dialogue.HideText()
					dealerHasGreeted = true
			dealerAtTable = true
	enteringFromWaiver = false
	playerData.enteringFromTrueDeath = false
	mainBatchIndex = playerData.currentBatchIndex
	healthCounter.DisableCounter()
	SetupRoundArray()
	if (playerData.hasReadIntroduction): roundArray[0].hasIntroductoryText = false
	else: roundArray[0].hasIntroductoryText = true
	if (roundArray[0].showingIndicator): await(RoundIndicator())
	healthCounter.SetupHealth()
	lerping = true
	#await get_tree().create_timer(1.5, false).timeout
	StartRound(false)

#APPEND ROUNDS FROM BATCH
func SetupRoundArray():
	roundArray = []
	for i in range(batchArray.size()):
		if (batchArray[i].batchIndex == mainBatchIndex):
			var matched = batchArray[i]
			for z in range(matched.roundArray.size()):
				roundArray.append(matched.roundArray[z])
				pass
	pass

#SHOW ROUND INDICATOR
func RoundIndicator():
	roundIndicator.visible = false
	#await get_tree().create_timer(1.5, false).timeout
	animator_roundIndicator.play("RESET")
	camera.BeginLerp("health counter")
	await get_tree().create_timer(.8, false).timeout
	var activePos = roundIndicatorPositions[roundArray[0].indicatorNumber]
	roundIndicator.transform.origin = activePos
	roundIndicatorParent.visible = true
	speaker_roundHum.play()
	await get_tree().create_timer(.8, false).timeout
	roundIndicator.visible = true
	animator_roundIndicator.play("round blinking")
	await get_tree().create_timer(2, false).timeout
	roundIndicatorParent.visible = false
	speaker_roundHum.stop()
	speaker_roundShutDown.play()
	animator_roundIndicator.play("RESET")
	pass

#MAIN ROUND SETUP
func StartRound(gettingNext : bool):
	if (gettingNext && (currentRound +  1) != roundArray.size()): currentRound += 1
	#USINGITEMS: SETUP ITEM GRIDS IF ROUND CLASS HAS SETUP ITEM GRIDS ENABLED
	#UNCUFF BOTH PARTIES BEFORE ITEM DISTRIBUTION
	await (handcuffs.RemoveAllCuffsRoutine())
	#FINAL SHOWDOWN DIALOGUE
	if (playerData.currentBatchIndex == 2 && !defibCutterReady):
		shellLoader.dialogue.dealerLowPitched = true
		camera.BeginLerp("enemy") 
		await get_tree().create_timer(.6, false).timeout
		#var origdelay = shellLoader.dialogue.incrementDelay
		#shellLoader.dialogue.incrementDelay = .1
		if (!playerData.cutterDialogueRead):
			shellLoader.dialogue.ShowText_Forever("LONG LAST, WE ARRIVE\nAT THE FINAL SHOWDOWN.")
			await get_tree().create_timer(4, false).timeout
			shellLoader.dialogue.ShowText_Forever("NO MORE DEFIBRILLATORS.\nNO MORE BLOOD TRANSFUSIONS.")
			await get_tree().create_timer(4, false).timeout
			shellLoader.dialogue.ShowText_Forever("NOW, ME AND YOU, WE ARE DANCING\nON THE EDGE OF LIFE AND DEATH.")
			await get_tree().create_timer(4.8, false).timeout
			shellLoader.dialogue.HideText()
			playerData.cutterDialogueRead = true
		else:
			shellLoader.dialogue.ShowText_Forever("I BETTER NOT\nSEE YOU AGAIN.")
			await get_tree().create_timer(3, false).timeout
			shellLoader.dialogue.HideText()
		await(deficutter.InitialSetup())
		defibCutterReady = true
		trueDeathActive = true
		#await get_tree().create_timer(100, false).timeout
	#USINGITEMS: SHARE ITEMS TO PLAYERS HERE
	if (roundArray[currentRound].usingItems):
		itemManager.BeginItemGrabbing()
		return
	shellSpawner.MainShellRoutine()
	pass

#MAIN ROUND SETUP AFTER ITEMS HAVE BEEN DISTRIBUTED. RETURN TO HERE FROM ITEM GRABBING INTERACTION
func ReturnFromItemGrabbing():
	shellSpawner.MainShellRoutine()
	pass

func LoadShells():
	shellLoader.LoadShells()
	pass

func CheckIfOutOfHealth():
	#CHECK IF OUT OF HEALTH
	var outOfHealth_player = health_player == 0
	var outOfHealth_enemy = health_opponent == 0
	var outOfHealth = outOfHealth_player or outOfHealth_enemy
	if (outOfHealth):
		if (outOfHealth_player): OutOfHealth("player")
		if (outOfHealth_enemy):  OutOfHealth("dealer")
		return outOfHealth

var waitingForReturn = false
var waitingForHealthCheck = false
var waitingForHealthCheck2 = false
var requestedWireCut = false
var wireToCut = ""
var wireIsCut_dealer = false
var wireIsCut_player = false

var ignoring = false
func EndTurn(playerCanGoAgain : bool):
	#USINGITEMS: ASSIGN PLAYER CAN GO AGAIN FROM ITEMS HERE
	#USINGITEMS: MAKE SHOTGUN GROW NEW BARREL
	#var isOutOfHealth = CheckIfOutOfHealth()
	#if (isOutOfHealth): return
	if (barrelSawedOff):
		await get_tree().create_timer(.6, false).timeout
		if (waitingForHealthCheck2): await get_tree().create_timer(2, false).timeout
		waitingForHealthCheck2 = false
		await(segmentManager.GrowBarrel())
	if (shellSpawner.sequenceArray.size() != 0):
		#PLAYER TURN
		if (playerCanGoAgain):
			BeginPlayerTurn()
		else:
			#DEALER TURN
			if (!dealerCuffed):
				dealerAI.BeginDealerTurn()
			else:
				if (waitingForReturn):
					await get_tree().create_timer(1.4, false).timeout
					waitingForReturn = false
				if (waitingForHealthCheck): 
					await get_tree().create_timer(1.8, false).timeout
					waitingForHealthCheck = false
				dealerAI.DealerCheckHandCuffs()
	else:
		#SHOTGUN IS EMPTY. NEXT ROUND
		if (requestedWireCut):
			await(defibCutter.CutWire(wireToCut)) 
		if (!ignoring): 
			StartRound(true)

func ReturnFromCuffCheck(brokeFree : bool):
	if (brokeFree):
		await get_tree().create_timer(.8, false).timeout
		camera.BeginLerp("enemy")
		dealerAI.BeginDealerTurn()
		pass
	else:
		camera.BeginLerp("home")
		BeginPlayerTurn()
	pass

func BeginPlayerTurn():
	if (playerCuffed):
		var returning = false
		if (playerAboutToBreakFree == false):
			handcuffs.CheckPlayerHandCuffs(false)
			await get_tree().create_timer(1.4, false).timeout
			camera.BeginLerp("enemy")
			dealerAI.BeginDealerTurn()
			returning = true
			playerAboutToBreakFree = true
		else:
			handcuffs.BreakPlayerHandCuffs(false)
			await get_tree().create_timer(1.4, false).timeout
			camera.BeginLerp("home")
			playerCuffed = false
			playerAboutToBreakFree = false
			returning = false
		if (returning): return
	if (requestedWireCut):
		await(defibCutter.CutWire(wireToCut))
	await get_tree().create_timer(.6, false).timeout
	perm.SetStackInvalidIndicators()
	cursor.SetCursor(true, true)
	perm.SetIndicators(true)
	perm.SetInteractionPermissions(true)

func OutOfHealth(who : String):
	if (who == "player"): 
		death.MainDeathRoutine()
	else:
		await get_tree().create_timer(1, false).timeout
		EndMainBatch()

func EndMainBatch():
	#ADD TO BATCH INDEX
	ignoring = true
	playerData.currentBatchIndex += 1
	#PLAY WINNING SHIT
	await get_tree().create_timer(.8, false).timeout
	if (playerData.currentBatchIndex == 3): 
		healthCounter.speaker_truedeath.stop()
		healthCounter.DisableCounter()
		defibCutter.BlipError_Both()
		await get_tree().create_timer(.4, false).timeout
		#gameover.PlayerWon()
		camera.BeginLerp("enemy")
		await get_tree().create_timer(.7, false).timeout
		brief.MainRoutine()
		return
	healthCounter.DisableCounter()
	speaker_roundShutDown.play()
	await get_tree().create_timer(1, false).timeout
	speaker_winner.play()
	ui_winner.visible = true
	itemManager.newBatchHasBegun = true
	await get_tree().create_timer(2.33, false).timeout
	speaker_roundShutDown.play()
	speaker_winner.stop()
	musicManager.EndTrack()
	ui_winner.visible = false
	#REGROW BARREL IF MISSING
	if (barrelSawedOff):
		await get_tree().create_timer(.6, false).timeout
		await(segmentManager.GrowBarrel())
	#MAIN BATCH LOOP
	MainBatchSetup(false)
	if (!dealerAtTable): 
		if (!dealerCuffed): animator_dealerHands.play("dealer hands on table")
		else: animator_dealerHands.play("dealer hands on table cuffed")
		animator_dealer.play("dealer return to table")
	for i in range(ejectManagers.size()):
		ejectManagers[i].FadeOutShell()
	#TRACK MANAGER
	await get_tree().create_timer(2, false).timeout
	musicManager.LoadTrack_FadeIn()
