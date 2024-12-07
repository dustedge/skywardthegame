extends Node2D

@export var projectile_scene := preload("res://entities/projectile.tscn")

func shoot(target_position : Vector2) -> bool:
	var newproj : Projectile = projectile_scene.instantiate()
	self.add_child(newproj)
	newproj.top_level = true
	newproj.position = self.global_position
	newproj.look_at(target_position)
	newproj.go()
	return true
