extends StaticBody2D
class_name Platform

@export var sprite_stage = 0
@onready var sprite : Sprite2D = $Sprite2D
@export var is_breakable : bool = false
@export var is_moving : bool = false
@onready var shadermat : ShaderMaterial = sprite.material

@onready var anchor_point = self.global_position
var move_speed = 70.0
var move_range_x = 100.0
var moving_right = true
var is_breaking = false

func player_jump():
	if is_breakable:
		start_break()
	
	$AnimationPlayer.play("player_jump")
	$CPUParticles2D.emitting = true

func kill():
	queue_free()

func set_stage(stage : int):
	sprite_stage = stage
	call_deferred("update_sprite")

func update_sprite():
	if !is_instance_valid(sprite): return
	match sprite_stage:
		0: sprite.frame = 0
		1: sprite.frame = 1
		2: sprite.frame = 2
		3: sprite.frame = 3
		4: sprite.frame = 4
		5: sprite.frame = 5
		6: sprite.frame = 6
		7: sprite.frame = 7
		_: sprite.frame = 7
	
	if is_breakable:
		sprite.frame += 8

func start_break():
	if is_breaking: return
	is_breaking = true
	$CollisionShape2D.set_deferred("disabled", true)

func _process(delta: float) -> void:
	if is_breaking:
		if shadermat.get_shader_parameter("breakup") < 1.0:
			shadermat.set_shader_parameter("breakup", move_toward(shadermat.get_shader_parameter("breakup"), 1.0, delta))
		else: self.kill()

func _physics_process(delta: float) -> void:
	if is_moving:
		if moving_right:
			self.global_position.x += (move_speed * delta)
			if self.global_position.x > (anchor_point.x + move_range_x) or self.global_position.x > (get_viewport_rect().position.x + get_viewport_rect().size.x):
				moving_right = false
		else:
			self.global_position.x -= (move_speed * delta)
			if self.global_position.x < (anchor_point.x - move_range_x) or self.global_position.x < 0:
				moving_right = true
			
		
