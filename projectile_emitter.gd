extends Node2D

@export var projectile_scene := preload("res://objects/throwing_knife.tscn")
@export var reload_time := 1.0
@export var max_ammo := 4
@onready var parent = get_parent()
var current_reload_time := 0.0
var current_ammo := 3

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
