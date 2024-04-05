class_name Medicine extends Node

@export var rm : RoundManager
@export var interaction : ItemInteraction
@export var cam : CameraManager
@export var death : DeathManager
@export var counter : HealthCounter
@export var anim_dealerhands : AnimationPlayer
@export var dealerai : DealerIntelligence

@export var speaker_medicine : AudioStreamPlayer2D
@export var death_dealer : AudioStream
@export var death_player : AudioStream

var dealerDying = false

func UseMedicine():
	cam.moving = false
	var dying = GetFlip()
	if (dying):Perms(8.78)
	else: Perms(6.78)
	await get_tree().create_timer(3.05, false).timeout
	death.DisableSpeakers()
	await get_tree().create_timer(1.25 + .1, false).timeout
	if (dying):
		counter.skipping_careful = true
		rm.health_player -= 1
		speaker_medicine.stream = death_player
		speaker_medicine.play()
		await(death.MedicineDeath())
		counter.overriding_medicine = true
		counter.overriding_medicine_adding = false
		counter.UpdateDisplayRoutineCigarette_Player()
	else:
		death.FadeInSpeakers()
		counter.overriding_medicine = true
		counter.overriding_medicine_adding = true
		counter.UpdateDisplayRoutineCigarette_Player()

func UseMedicine_Dealer():
	var dying = dealerDying
	if (dying):
		await get_tree().create_timer(5, false).timeout
		speaker_medicine.stream = death_dealer
		speaker_medicine.play()
		anim_dealerhands.play("dealer death medicine")
		await get_tree().create_timer(.41, false).timeout
		death.cameraShaker.Shake()
		await get_tree().create_timer(.6, false).timeout
		#rm.health_opponent -= 1
		counter.overriding_medicine = true
		counter.overriding_medicine_adding = false
		counter.UpdateDisplayRoutineCigarette_Enemy()
		await get_tree().create_timer(.5, false).timeout
		anim_dealerhands.play("RESET")
		await get_tree().create_timer(2, false).timeout
		dealerDying = false
		dealerai.DealerChoice()
	else:
		await get_tree().create_timer(4.07, false).timeout
		counter.overriding_medicine = true
		counter.overriding_medicine_adding = true
		counter.UpdateDisplayRoutineCigarette_Enemy()
		await get_tree().create_timer(2, false).timeout
		dealerDying = false
		dealerai.DealerChoice()

func Perms(d : float):
	await get_tree().create_timer(d, false).timeout
	interaction.EnablePermissions()

func GetFlip():
	var value = randf_range(0.0, 1.0)
	if (value < .4): return false
	else: return true
