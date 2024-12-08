extends CharacterBody2D
class_name Player

const MAX_SPEED = 300.0
const SPEED = 300.0
const JUMP_VELOCITY = -800.0
const AIRBRAKE = 300.0
var is_dead : bool = false
var spin_speed_degrees : float = 225.0
var sprite_vel_threshold : float = 55.0
var next_jump_boost := 0
var play_zone_width = 360
var play_zone_margin = 15

var current_gravity
var current_effects : Array = []

@export var max_health := 8
var health := max_health

@onready var light_particles = $Sprite2D/PointLightParticles

@onready var anim_player = $AnimationPlayerSprite
@onready var sprite = $Sprite2D
@onready var detector = $EnemyDetector

signal player_died
signal player_received_damage

func _ready() -> void:
	_on_ammo_update()
	
	$ProjectileEmitter.connect("ammo_update", _on_ammo_update)
	flashlight_off()
	
func _on_ammo_update():
	get_parent().get_node("UI/KnivesContainer").set_knives_amount($ProjectileEmitter.current_ammo)

func _process(delta: float) -> void:
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("RESET")
	if !is_dead:
		update_sprite()

func _physics_process(delta: float) -> void:
	current_gravity = get_gravity()
	update_effects(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += current_gravity * delta
	# Auto jump.
	if is_on_floor():
		var coll = get_last_slide_collision().get_collider()
		if coll.has_method("player_jump"):
			coll.player_jump()
		velocity.y = JUMP_VELOCITY + (- next_jump_boost)
		SoundManager.playSFXAtPosition("res://sounds/jump.wav", global_position)
		
		if randi() % 100 > 90:
			if sprite.flip_h:
				$AnimationPlayer.play("backflip")
			else: $AnimationPlayer.play("frontflip")
		else: $AnimationPlayer.play("jump")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if Input.is_action_just_pressed("key_attack") and not is_dead:
		
		if is_instance_valid(detector) and is_instance_valid(detector.closest_target):
			$ProjectileEmitter.shoot(detector.closest_target.global_position)
		else:
			$ProjectileEmitter.shoot(self.global_position + (Vector2.UP * 200))
		_on_ammo_update()
	
	if is_dead:
		direction = 0
	
	if direction:
		velocity.x += direction * (SPEED * delta)
		if direction > 0:
			sprite.flip_h = false
			light_particles.position.x = -2
		else: 
			sprite.flip_h = true
			light_particles.position.x = 2
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
	if health > 0:
		health = 0
		emit_signal("player_received_damage", health)
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
	light_particles.set_deferred("emitting", true)

func flashlight_off():
	$PointLight.set_deferred("enabled", false) 
	light_particles.set_deferred("emitting", false)

func receive_damage(damage):
	health -= damage
	emit_signal("player_received_damage", damage)
	$AnimationPlayer.play("receive_damage")
	if health <= 0:
		anim_player.play("fly_down")
		kill()

func apply_effect(type : Globals.EffectType, time : float):
	self.current_effects.append([type, time])

func update_effects(delta):
	
	# clean up
	current_gravity = get_gravity()
	
	# apply effect effects
	for effect in current_effects:
		match effect[0]:
			Globals.EffectType.LOW_GRAVITY:
				current_gravity = get_gravity() / 2
				if not $Effects/GravityParticles.emitting:
					$Effects/GravityParticles.set_deferred("emitting", true)
				pass
			Globals.EffectType.HEAVY:
				current_gravity = get_gravity() * 1.5
				if not $Effects/BloodParticles.emitting:
					$Effects/BloodParticles.set_deferred("emitting", true)
				pass
			Globals.EffectType.JUMP_BOOST:
				next_jump_boost = 250.0
				pass
				
	# separate effect removal
	for effect in current_effects:
		if effect[1] > 0.0: # tick effect time
			effect[1] = move_toward(effect[1], 0.0, delta)
		else:
			# remove effect
			if effect[0] == Globals.EffectType.LOW_GRAVITY:
				if $Effects/GravityParticles.emitting:
						$Effects/GravityParticles.set_deferred("emitting", false)
			
			if effect[0] == Globals.EffectType.HEAVY:
				if $Effects/BloodParticles.emitting:
						$Effects/BloodParticles.set_deferred("emitting", false)
			current_effects.erase(effect)
			continue

func add_health(amount : int):
	self.health = min(max_health, health + amount)
	emit_signal("player_received_damage", -amount)
