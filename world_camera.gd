extends Camera2D
class_name WorldCamera

var recovery_speed := 6.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if offset != Vector2.ZERO:
		offset.x = lerpf(offset.x, 0, recovery_speed * delta)
		offset.y = lerpf(offset.y, 0, recovery_speed * delta)
	pass

func shake(strength : float):
	offset += Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
	pass
