extends CharacterBody2D
class_name StaticEnemy

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var collider = $CollisionShape2D

@export var attack_damage := 1
@export var health := 2
@export var attack_range = 100.0
@export var attack_cooldown = 3.0
@export var nav_area_shape : CollisionShape2D
var is_dead = false
var target : Node2D = null
var current_attack_cd = 0.0
var move_target_local : Vector2 = Vector2.INF
var move_time_left := 0.0
var move_time := 6.0
var move_time_rand := 2.0
var move_speed := 0.0
var is_moving := false
var is_static := true

enum State {
	ATTACKING,
	IDLE,
	MOVING,
	STAGGERED
}

var cur_state : State = State.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
