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

func shoot(target_position : Vector2, multishot : bool = false, add_vel : bool = false) -> bool:
	if current_ammo <= 0: 
		SoundManager.playSFXAtPosition("res://sounds/weapons/noammo.wav",self.global_position)
		return false
	if get_parent() is Player:
		SoundManager.playSFXAtPosition("res://sounds/weapons/dagger_throw.wav",self.global_position)
	
	var newproj : ThrowingKnife = projectile_scene.instantiate()
	var newproj2 : ThrowingKnife
	var newproj3 : ThrowingKnife
	
	if multishot:
		SoundManager.playSFXAtPosition("res://sounds/weapons/multishot.wav",self.global_position)
		newproj2 = projectile_scene.instantiate()
		newproj3 = projectile_scene.instantiate()
		self.add_child(newproj2)
		self.add_child(newproj3)
	
	self.add_child(newproj)
	
	var predicted_pos = target_position
	
	if get_parent().velocity.y < 0 and add_vel:
		predicted_pos += Vector2(0, (get_parent().velocity.y * (get_parent().global_position.distance_to(target_position) + 10.0)) / 1500.0)
	
	newproj.top_level = true
	
	newproj.position = self.global_position
	newproj.look_at(predicted_pos)
	newproj.go()
	
	if multishot:
		newproj2.top_level = true
		newproj3.top_level = true
		
		newproj2.position = self.global_position
		newproj2.look_at(predicted_pos)
		newproj2.rotation_degrees -= 10
		newproj2.go()
		
		newproj3.position = self.global_position
		newproj3.look_at(predicted_pos)
		newproj3.rotation_degrees += 10
		newproj3.go()
	
	current_ammo -= 1
	emit_signal("ammo_update")
	return true
