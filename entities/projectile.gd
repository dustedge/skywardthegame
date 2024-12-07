extends RigidBody2D
class_name Projectile

@export var start_vel = 200.0
@export var time_to_live = 8.0
@export var damage := 1

func _process(delta: float) -> void:
	if time_to_live > 0.0:
		time_to_live -= delta
	else:
		die()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func go(added_vel : Vector2 = Vector2(0,0)):
	var look_dir = Vector2(cos(rotation), sin(rotation)) 
	self.linear_velocity = (look_dir * (start_vel)) + added_vel
	self.angular_velocity = 0

func _on_body_entered(body: Node) -> void:
	if !is_instance_valid(body): return
	if body.has_method("receive_damage"):
		body.receive_damage(damage)
		SoundManager.playSFXAtPosition(\
		"res://sounds/weapons/damage{0}.wav".format([randi_range(1,4)]), self.global_position)
		die()

func die():
	self.queue_free()
