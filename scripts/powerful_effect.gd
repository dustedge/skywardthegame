extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.rotation_degrees += 180.0 * delta
	pass

func hide_effect():
	if $AnimationPlayer.is_playing():
		await $AnimationPlayer.animation_finished
		
	if !visible: return
	$AnimationPlayer.play("hide")

func show_effect():
	if $AnimationPlayer.is_playing():
		await $AnimationPlayer.animation_finished
		
	if visible: return
	$AnimationPlayer.play("show")
