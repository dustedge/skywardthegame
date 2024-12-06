extends CanvasLayer

var current_stage = 0
var target_1
var target_2
var change_speed = 0.3

func change_parallax_to(stage : int):
	match stage:
		0:
			pass
		1:
			target_1 = $Parallax/layer0
			target_2 = $Parallax/layer1
		2:
			target_1 = $Parallax/layer1
			target_2 = $Parallax/layer2
		3:
			target_1 = $Parallax/layer2
			target_2 = $Parallax/layer3
		4:
			target_1 = $Parallax/layer3
			target_2 = $Parallax/layer4
		5:
			target_1 = $Parallax/layer4
			target_2 = $Parallax/layer5	
		6:
			target_1 = $Parallax/layer5
			target_2 = $Parallax/layer6
		7:
			target_1 = $Parallax/layer6
			target_2 = $Parallax/layer7
		_:
			pass
	
	current_stage = stage

func _process(delta: float) -> void:
	
	if not is_instance_valid(target_1) or not is_instance_valid(target_2):
		return
	
	if target_1.modulate.a > 0.0:
		target_1.modulate.a = lerp(target_1.modulate.a, 0.0, change_speed * delta)
	
	if target_2.modulate.a < 1.0:
		target_2.modulate.a = lerp(target_2.modulate.a, 1.0, change_speed * delta)
		
