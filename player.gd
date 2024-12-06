extends CharacterBody2D
class_name Player

const MAX_SPEED = 300.0
const SPEED = 300.0
const JUMP_VELOCITY = -800.0
const AIRBRAKE = 300.0
var is_dead : bool = false
var spin_speed_degrees : float = 225.0
var sprite_vel_threshold : float = 55.0
var next_jump_boost := 400
var play_zone_width = 360
var play_zone_margin = 15

@onready var anim_player = $AnimationPlayerSprite
@onready var sprite = $Sprite2D

signal player_died

func _ready() -> void:
	flashlight_off()

func _process(delta: float) -> void:
	if !is_dead:
		update_sprite()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Auto jump.
	if is_on_floor():
		var coll = get_last_slide_collision().get_collider()
		if coll.has_method("player_jump"):
			coll.player_jump()
		velocity.y = JUMP_VELOCITY
		SoundManager.playSFXAtPosition("res://sounds/jump.wav", global_position)
		
		if randi() % 100 > 90:
			if sprite.flip_h:
				$AnimationPlayer.play("backflip")
			else: $AnimationPlayer.play("frontflip")
		else: $AnimationPlayer.play("jump")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if is_dead:
		direction = 0
	
	if direction:
		velocity.x += direction * (SPEED * delta)
		if direction > 0:
			sprite.flip_h = false
			$PointLightParticles.position.x = -2
		else: 
			sprite.flip_h = true
			$PointLightParticles.position.x = 2
	else:
		velocity.x = move_toward(velocity.x, 0, (SPEED * delta))
		
	if velocity.x > MAX_SPEED: velocity.x = MAX_SPEED
	elif velocity.x < -MAX_SPEED: velocity.x = -MAX_SPEED
	
	if is_dead:
		die(delta)
	
	check_bounds()
	
	move_and_slide()

func kill():
	if is_dead: return
	SoundManager.playSFXAtPosition("res://sounds/death.wav", global_position)
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	self.add_child(timer)
	timer.start()
	timer.connect("timeout", player_dead)
	self.is_dead = true
	$CollisionShape2D.set_deferred("disabled", true)
	velocity.y = JUMP_VELOCITY

func die(delta):
	rotation_degrees += spin_speed_degrees * delta

func update_sprite():
	if velocity.y > sprite_vel_threshold:
		if not anim_player.current_animation == "fly_down":
			anim_player.play("fly_down")
	elif velocity.y < -sprite_vel_threshold:
		if not anim_player.current_animation == "fly_up":
			anim_player.play("fly_up")
	else:
		if not anim_player.current_animation == "mid_air":
			anim_player.play("mid_air")	

func check_bounds():
	if position.x > play_zone_width + play_zone_margin:
		position.x = -play_zone_margin
	elif position.x < -play_zone_margin:
		position.x = play_zone_width + play_zone_margin

func player_dead():
	SoundManager.playSFXAtPosition("res://sounds/fall.wav", global_position)
	emit_signal("player_died")

func spring_boost(strength):
	velocity.y = -strength
	if sprite.flip_h:
		$AnimationPlayer.play("backflip")
	else: $AnimationPlayer.play("frontflip")

func flashlight_on():
	$PointLight.set_deferred("enabled", true) 
	$PointLightParticles.set_deferred("emitting", true)

func flashlight_off():
	$PointLight.set_deferred("enabled", false) 
	$PointLightParticles.set_deferred("emitting", false)
