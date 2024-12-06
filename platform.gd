extends StaticBody2D
class_name Platform

func player_jump():
	$AnimationPlayer.play("player_jump")
	$CPUParticles2D.emitting = true

func kill():
	queue_free()
