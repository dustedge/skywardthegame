extends RigidBody2D
class_name ThrowingKnife

@export var start_vel = 1200.0
@export var time_to_live = 4.0
@export var damage := 1
@onready var trail : Line2D = $Trail
@onready var hit_particles : GPUParticles2D = $GPUParticles2D
var trail_length : int = 20
var is_active := false
var is_dying := false

func _process(delta: float) -> void:
	if time_to_live > 0.0:
		time_to_live -= delta
	else:
		die()
		
	if trail and is_active:
		if trail.points.size() < trail_length:
			trail.add_point(self.global_position)
		else: 
			trail.remove_point(0)
			trail.add_point(self.global_position)
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func go(added_vel : Vector2 = Vector2(0,0)):
	is_active = true
	var look_dir = Vector2(cos(rotation), sin(rotation)) 
	self.linear_velocity = (look_dir * (start_vel)) + added_vel
	self.angular_velocity = -35.0


func _on_body_entered(body: Node) -> void:
	if !is_instance_valid(body): return
	if body.has_method("receive_damage"):
		body.receive_damage(damage, "player")
		SoundManager.playSFXAtPosition(\
		"res://sounds/weapons/damage{0}.wav".format([randi_range(1,4)]), self.global_position)
		die()

func die():
	if is_dying: return
	
	is_dying = true
	hit_particles.set_deferred("emitting", true)
	$CollisionShape2D.set_deferred("disabled", true)
	self.set_deferred("freeze", true)
	$Sprite2D.hide()
	await get_tree().create_timer(hit_particles.lifetime).timeout
	self.queue_free()
