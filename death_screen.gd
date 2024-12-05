extends CenterContainer
class_name DeathScreen

@onready var score_label : Label = $VBoxContainer/FinalScoreLabel
@onready var scores : Label = $VBoxContainer/Scores

func _on_retry_button_pressed() -> void:
	SoundManager.playSFX("res://sounds/button_click.wav", false)
	get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	SoundManager.playSFX("res://sounds/button_click.wav", false)
	get_tree().change_scene_to_file("res://main_menu.tscn")

func set_score(score : int):
	score_label.text = str(score)

func update_saved_scores():
	var i := 1
	scores.text = ""
	for key in Globals.score_data.keys():
		var scrtext = "{0}. {1}: {2}\n".format([i, key, Globals.score_data[key]])
		scores.text += scrtext
		i += 1
		if i >= 6: break
	pass
