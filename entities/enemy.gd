extends CharacterBody2D
class_name Enemy


@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var collider = $CollisionShape2D

@export var attack_damage := 1
@export var health := 2
@export var attack_range = 800.0
@export var attack_cooldown = 4.0
@export var nav_area_shape : CollisionShape2D
var is_dead = false
var target : Node2D = null
var current_attack_cd = 0.0
var move_target_local : Vector2 = Vector2.INF
var move_time_left := 0.0
var move_time := 6.0
var move_time_rand := 2.0
var reward := 7
@export var move_speed := 150.0
var is_moving := false
@export var is_static := false
@export var is_melee := false

var last_damage_source = null
signal spawn_reward

enum State {
	ATTACKING,
	IDLE,
	MOVING,
	STAGGERED
}

var cur_state : State = State.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reward += randi_range(0, 10)
	if is_static:
		top_level = true
	else: 
		self.cur_state = State.MOVING
		is_moving = true
		move_target_local = get_random_point(nav_area_shape)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dead:
		return
	match cur_state:
		State.ATTACKING:
			if not (animated_sprite.animation == "receive_damage" and animated_sprite.is_playing()):
				if animated_sprite.animation != "attack":
					animated_sprite.play("attack")
			if !animated_sprite.is_playing():
				cur_state = State.IDLE
			pass
			
		State.IDLE:
			if not (animated_sprite.animation == "receive_damage" and animated_sprite.is_playing()):
				if (animated_sprite.animation != "idle" or not animated_sprite.is_playing()):
					animated_sprite.play("idle")
				
			if not is_static:
				move_target_local = get_random_point(nav_area_shape)
				is_moving = true
				cur_state = State.MOVING
				
		State.MOVING:
			if not (animated_sprite.animation == "receive_damage" and animated_sprite.is_playing()):
				if (animated_sprite.animation != "idle" or not animated_sprite.is_playing()):
					animated_sprite.play("idle")
			
			if (self.position.distance_to(move_target_local) < 5.0) or move_target_local == Vector2.INF:
				is_moving = false
				move_target_local = Vector2.INF
				cur_state = State.IDLE
				pass
	pass

func _physics_process(delta: float) -> void:
	
	if target is Player and not is_dead:
		if target.global_position.x > self.global_position.x:
			animated_sprite.flip_h = false
		else: animated_sprite.flip_h = true
		if global_position.distance_to(target.global_position) <= attack_range:
			if current_attack_cd <= 0.0:
				attack(target)
				current_attack_cd = attack_cooldown
	
	if current_attack_cd > 0.0:
		current_attack_cd = move_toward(current_attack_cd, 0.0, delta)
		
	if move_target_local != Vector2.INF and cur_state == State.MOVING and !is_dead:
		self.position = self.position.move_toward(move_target_local, delta * move_speed)
		
	if is_dead:
		if not is_static: velocity += (get_gravity() * delta)
		self.rotation_degrees += (360 * delta)
	
	if is_static and not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()
	
	

func receive_damage(damage : int, source = null):
	animated_sprite.play("receive_damage")
	Globals.shake_camera(10.0)
	health -= damage
	if source == "player":
		last_damage_source = source
	else:
		last_damage_source = ""
		
	if health <= 0:
		die()

func die():
	if is_dead: return
	SoundManager.playSFXAtPosition("res://sounds/monster/sfx_deathscream_alien{0}.wav".format([randi_range(3, 4)]), self.global_position)
	
	if last_damage_source == "player":
		spawn_reward.emit(reward, self.global_position)
		
		
	self.animated_sprite.offset = Vector2(0, -23)
	position = global_position
	set_deferred("top_level", true)
	$CPUParticles2D.set_deferred("emitting", true)
	$CollisionShape2D.set_deferred("disabled", true)
	self.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	is_dead = true
	animated_sprite.play("death")
	self.velocity = Vector2(randf_range(-150,150), -600.0)
	await get_tree().create_timer(3.0).timeout
	self.queue_free()

func attack(target : Node2D):
	if not target.has_method("receive_damage"): return
	if is_melee:
		target.receive_damage(attack_damage)
	else:
		$AIProjectileEmitter.shoot(target.global_position)
	self.cur_state = State.ATTACKING


func _on_detect_area_body_entered(body: Node2D) -> void:
	if body is Player:
		self.target = body

func get_random_point(col_shape : CollisionShape2D) -> Vector2:
	var rect = col_shape.shape.get_rect()
	var randx = randf_range(0, rect.size.x)
	var randy = randf_range(0, rect.size.y)
	return Vector2(randx, randy)
