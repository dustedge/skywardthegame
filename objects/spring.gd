extends RigidBody2D

@export var boost_strength : int = 1200

var is_used = false

func _on_body_entered(body: Node) -> void:
	if body is Player and !is_used:
		body.spring_boost(boost_strength)
		is_used = true
		self.set_used()

func set_used():
	$Sprite2D.frame = 1
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("freeze", false)
	
	SoundManager.playSFXAtPosition("res://sounds/spring.wav", global_position)
	
	self.linear_velocity = Vector2(randf_range(-100.0,100.0), randf_range(-40.0, -200.0))
	self.angular_velocity = randf_range(-2.0, 2.0)
	
	var timer = Timer.new()
	self.add_child(timer)
	timer.wait_time = 3.0
	timer.start()
	timer.connect("timeout", self.queue_free)
	
func kill():
	queue_free()
