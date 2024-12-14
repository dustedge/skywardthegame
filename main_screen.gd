extends CenterContainer

@onready var body = $RigidBody2D
@onready var body2 = $RigidBody2D2
var speed = 200.0
var direction = Vector2(0,0)

func _ready() -> void:
	SoundManager.play_menu_music()
	DiscordManager.set_state(DiscordManager.State.IN_MENU)
	direction = Vector2(randf_range(-1,1),randf_range(-1,1))
	body.linear_velocity = direction * speed
	body.angular_velocity = randf_range(-2,2)
	direction = Vector2(randf_range(-1,1),randf_range(-1,1))
	body2.linear_velocity = direction * speed
	body2.angular_velocity = randf_range(-2,2)

func _on_play_button_pressed() -> void:
	SoundManager.playSFX("res://sounds/button_click.wav", false)
	get_tree().change_scene_to_file("res://world.tscn")

func _on_options_button_pressed() -> void:
	SoundManager.playSFX("res://sounds/button_click.wav", false)
	get_parent().get_node("OptionScreen").show()

func _on_exit_button_pressed() -> void:
	SoundManager.playSFX("res://sounds/button_click.wav", false)
	get_tree().quit()

func _on_shop_button_pressed() -> void:
	SoundManager.playSFX("res://sounds/button_click.wav", false)
	get_tree().change_scene_to_file("res://upgrade_shop.tscn")
	
