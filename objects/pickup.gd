extends RigidBody2D
class_name Pickup

enum Type {
	LOW_GRAVITY,
	HEALTH,
	BEAR_TRAP
}

@export var add_health = 0
@export var effect_time = 0.0

var sprite_ready : bool = false
@export var type : Type
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player : AnimationPlayer = $AnimationPlayer

func update():
	pass

func _process(delta: float) -> void:
	if not sprite_ready:
		if is_instance_valid(animated_sprite):
			match self.type:
				Type.LOW_GRAVITY:
					self.effect_time = 6.0
					if not animated_sprite.animation == "feather":
						animated_sprite.play("feather")
				Type.HEALTH:
					self.add_health = 2
					if not animated_sprite.animation == "heart":
						animated_sprite.play("heart")
				Type.BEAR_TRAP:
					self.effect_time = 6.0
					if not animated_sprite.animation == "trap_idle":
						animated_sprite.play("trap_idle")
		sprite_ready = true

func _on_body_entered(body: Node) -> void:
	if body is Player:
		pickup(body)

func pickup(player : Player):
	match self.type:
		Type.LOW_GRAVITY:
			SoundManager.playSFXAtPosition("res://sounds/powerup1.wav", self.global_position)
			SoundManager.playSFXAtPosition("res://sounds/sound_noise.wav", self.global_position)
			player.apply_effect(Globals.EffectType.LOW_GRAVITY, effect_time)
			kill()
			pass
		Type.HEALTH:
			SoundManager.playSFXAtPosition("res://sounds/powerup1.wav", self.global_position)
			player.add_health(add_health)
			kill()
			pass
		Type.BEAR_TRAP:
			animated_sprite.play("trap_triggered")
			SoundManager.playSFXAtPosition("res://sounds/death.wav", global_position)
			player.apply_effect(Globals.EffectType.HEAVY, effect_time)
			player.receive_damage(1)
			kill()
			pass

func kill():
	if not self.type == Type.BEAR_TRAP:
		self.anim_player.play("pickup")
		await get_tree().create_timer(anim_player.current_animation_length).timeout
	else:
		await animated_sprite.animation_finished
	self.queue_free()
