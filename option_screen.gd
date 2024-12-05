extends CenterContainer

var min_db = -80.0
var max_db = 0.0
var default_db = -24.0
var is_dragging_sfx : bool = false
var is_dragging_bgm : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if Globals.score_data.keys().size() > 0:
		$VBoxContainer/NameLineEdit.text = Globals.score_data.keys().front()
	
	var bus_index = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_volume_db(bus_index, default_db)
	var val = ((default_db - min_db) / (max_db - min_db)) * 100
	
	bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, default_db)
	
	$VBoxContainer/SliderBGMVolume.set_value_no_signal(val)
	$VBoxContainer/SliderSFXVolume.set_value_no_signal(val)
	

func _on_slider_bgm_volume_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("BGM")
	var db = min_db + (max_db - min_db) * (value / 100.0)
	AudioServer.set_bus_volume_db(bus_index, db)

func _on_slider_sfx_volume_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("SFX")
	var db = min_db + (max_db - min_db) * (value / 100.0)
	print(db)
	AudioServer.set_bus_volume_db(bus_index, db)


func _on_slider_sfx_volume_drag_started() -> void:
	is_dragging_sfx = true


func _on_slider_sfx_volume_drag_ended(value_changed: bool) -> void:
	is_dragging_sfx = false

func _on_timer_timeout() -> void:
	if is_dragging_sfx:
		SoundManager.playSFX("res://sounds/coin_pickup.wav")


func _on_back_button_pressed() -> void:
	SoundManager.playSFX("res://sounds/button_click.wav")
	self.hide()


func _on_name_line_edit_text_changed(new_text: String) -> void:
	Globals.player_name = new_text
	if new_text.is_empty():
		Globals.player_name = "Unnamed"
