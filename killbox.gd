extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if is_instance_valid(body):
		if body is Player:
			body.kill()
		elif body is Platform:
			body.queue_free()
	pass # Replace with function body.
