extends CenterContainer

@onready var save_file_chooser : MenuButton = $VBoxContainer/SaveFileChoiceMenuButton
@onready var reset_button : Button = $VBoxContainer/ResetProgressButton
var save_file_popup : PopupMenu
var min_db = -50.0
var max_db = 0.0
var is_dragging_sfx : bool = false
var is_dragging_bgm : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.load_config()
	save_file_popup = save_file_chooser.get_popup()
	save_file_chooser.text = Globals.current_save
	save_file_popup.connect("index_pressed", _on_save_slot_changed)
	
	$VBoxContainer/NameLineEdit.text = Globals.player_name
	
	
	var val = ((SoundManager.volume_bgm - min_db) / (max_db - min_db)) * 100
	$VBoxContainer/SliderBGMVolume.set_value_no_signal(val)
	val = ((SoundManager.volume_sfx - min_db) / (max_db - min_db)) * 100
	$VBoxContainer/SliderSFXVolume.set_value_no_signal(val)
	

func _on_slider_bgm_volume_value_changed(value: float) -> void:
	var db = min_db + (max_db - min_db) * (value / 100.0)
	
	if db <= min_db:
		db = -80.0
	
	SoundManager.set_volume("BGM", db)

func _on_slider_sfx_volume_value_changed(value: float) -> void:
	var db = min_db + (max_db - min_db) * (value / 100.0)
	
	if db <= min_db:
		db = -80.0
	
	SoundManager.set_volume("SFX", db)


func _on_slider_sfx_volume_drag_started() -> void:
	is_dragging_sfx = true


func _on_slider_sfx_volume_drag_ended(value_changed: bool) -> void:
	is_dragging_sfx = false
	if value_changed:
		Globals.save_config()

func _on_timer_timeout() -> void:
	if is_dragging_sfx:
		SoundManager.playSFX("res://sounds/coin_pickup.wav")

func _on_back_button_pressed() -> void:
	SoundManager.playSFX("res://sounds/button_click.wav")
	reset_button.text = "Reset Progress"
	self.hide()


func _on_name_line_edit_text_changed(new_text: String) -> void:
	Globals.player_name = new_text
	if new_text.is_empty():
		Globals.player_name = "Unnamed"
		
func _on_save_slot_changed(new_save_slot : int):
	Globals.save_game()
	save_file_chooser.text = save_file_popup.get_item_text(new_save_slot)
	Globals.load_save(save_file_popup.get_item_text(new_save_slot))
	$VBoxContainer/NameLineEdit.text = Globals.player_name


func _on_slider_bgm_volume_drag_ended(value_changed: bool) -> void:
	is_dragging_bgm = false
	if value_changed:
		Globals.save_config()

func _on_slider_bgm_volume_drag_started() -> void:
	is_dragging_bgm = true


func _on_reset_progress_button_pressed() -> void:
	# remove all savefiles, reset progress globals
	# toast completed?
	var reset_text = "Press again to confirm."
	
	if reset_button.text != reset_text:
		reset_button.text = reset_text
	else:
		if DirAccess.remove_absolute("user://savedata.sav") == OK:
			print("OPTIONS: Save data removal: OK")
		else:
			print("OPTIONS: Save data removal: FAILED")
		
		print("OPTIONS: Cleaning up.")
		Globals.reset()
		
		print("OPTIONS: Reloading.")
		get_tree().reload_current_scene()
	pass
