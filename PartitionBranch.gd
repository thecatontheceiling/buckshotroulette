class_name PartitionBranch extends Node

var p : Label3D
var d = .1
var sp : AudioStreamPlayer2D

var nums = [9, 9, 9, 9, 9, 9, 9, 9]
var finished = false

func _ready():
	p = get_parent()
	p.text = "  '   '   '   '   '   '   '  "
	sp = get_parent().get_child(1)

func Loop(s : bool):
	if (s): looping = true; LoopPartitions()
	else: 
		looping = false
		#sp.pitch_scale = .05
		#sp.play()

var looping = false
func LoopPartitions():
	while (looping):
		for i in range(nums.size()):
			if (nums[i] == 0): continue
			nums[i] = randi_range(0, 9)
		
		p.text = str(nums[0]) + " ' " + str(nums[1]) + " ' " + str(nums[2])  + " ' " + str(nums[3]) + " ' " + str(nums[4]) + " ' " + str(nums[5]) + " ' " + str(nums[6]) + " ' " + str(nums[7])
		sp.pitch_scale = randf_range(.9, 1.1)
		sp.play()
		await get_tree().create_timer(d, false).timeout
		for num in nums:
			if num != 0: finished = false; break
			finished = true
		if finished: Loop(false)

func ResetPartition():
	looping = false
	p.text = "  '   '   '   '   '   '   '  "
	nums = [9, 9, 9, 9, 9, 9, 9, 9]
	finished = false
