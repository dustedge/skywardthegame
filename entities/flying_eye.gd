extends CharacterBody2D
class_name FlyingEnemy


@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var collider = $CollisionShape2D

@export var attack_damage := 1
@export var health := 2
@export var attack_range = 800.0
@export var attack_cooldown = 2.0
var is_dead = false
var target : Node2D = null
var current_attack_cd = 0.0

enum State {
	ATTACKING,
	IDLE,
	STAGGERED
}

var cur_state : State = State.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dead:
		return
	
	match cur_state:
		State.ATTACKING:
			if animated_sprite.animation != "attack":
				animated_sprite.play("attack")
			elif !animated_sprite.is_playing():
				cur_state = State.IDLE
			pass
		State.IDLE:
			if animated_sprite.animation != "idle" and not animated_sprite.is_playing():
				animated_sprite.play("idle")
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
	
	move_and_slide()

func receive_damage(damage : int):
	animated_sprite.play("receive_damage")
	health -= damage
	if health <= 0:
		die()

func die():
	if is_dead: return
	$CPUParticles2D.set_deferred("emitting", true)
	$CollisionShape2D.set_deferred("disabled", true)
	self.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	is_dead = true
	animated_sprite.play("death")
	await get_tree().create_timer(3.0).timeout
	self.queue_free()

func attack(target : Node2D):
	$AIProjectileEmitter.shoot(target.global_position)
	self.cur_state = State.ATTACKING


func _on_detect_area_body_entered(body: Node2D) -> void:
	if body is Player:
		self.target = body
