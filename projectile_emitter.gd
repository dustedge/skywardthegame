extends Node2D
class_name PlayerProjectileEmitter

var projectile_scene := preload("res://objects/throwing_knife.tscn")

@export var base_reload_time := 2.0
var reload_time := base_reload_time

@export var base_ammo_capacity := 2
var max_ammo := base_ammo_capacity

@onready var parent = get_parent()
var current_reload_time := 0.0
var current_ammo := 1

signal ammo_update

func _process(delta: float) -> void:
	
	var ammo_change = false
	if current_reload_time > 0.0 and current_ammo < max_ammo:
		current_reload_time -= delta
	else:
		if current_ammo < max_ammo:
			ammo_change = true
			current_ammo += 1
			current_reload_time = reload_time
	
	if ammo_change:
		emit_signal("ammo_update")

func shoot(target_position : Vector2) -> bool:
	if current_ammo <= 0: 
		SoundManager.playSFXAtPosition("res://sounds/weapons/noammo.wav",self.global_position)
		return false
	if get_parent() is Player:
		SoundManager.playSFXAtPosition("res://sounds/weapons/dagger_throw.wav",self.global_position)
	var newproj : ThrowingKnife = projectile_scene.instantiate()
	self.add_child(newproj)
	newproj.top_level = true
	newproj.position = self.global_position
	newproj.look_at(target_position)
	newproj.go()
	current_ammo -= 1
	emit_signal("ammo_update")
	return true
