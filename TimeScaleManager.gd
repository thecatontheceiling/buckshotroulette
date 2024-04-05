class_name TimeScaleManager extends Node

@export var pitchShiftDuration : float
@export var timeScaleLerpDuration : float

var moving = false
var elapsed = 0
var from
var to

func _process(delta):
	LerpTimeScale()

func BeginTimeScaleLerp(start : float, end : float):
	moving = false
	elapsed = 0
	from = start
	to = end
	moving = true
	
func LerpTimeScale():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / timeScaleLerpDuration, 0.0 , 1.0)
		c = ease(c, 0.4)
		var val = lerpf(from, to, c)
		Engine.time_scale = val
