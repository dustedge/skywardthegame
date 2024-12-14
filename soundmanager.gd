extends Node

@onready var SFXPlayers2D : Array[AudioStreamPlayer2D]
@onready var SFXPlayers :  Array[AudioStreamPlayer]
@onready var BGMPlayers :  Array[AudioStreamPlayer]

var beat_timer := Timer.new()
var players_count_sfx = 50
var players_count_bgm = 1
var sound_pitch_variation = 0.1
var current_bpm = 0
var main_bgm_player : AudioStreamPlayer = AudioStreamPlayer.new()
var beat_delay = 0.1
var default_db = -24.0

var volume_sfx : float = default_db
var volume_bgm : float = default_db
var volume_checker : Timer

signal music_beat_occured

var music = {
	"stalactites": preload("res://sounds/music/stalactites.ogg"),
	"sunset": preload("res://sounds/music/sunset.ogg"),
	"titan": preload("res://sounds/music/titan.ogg"),
	"layer_2": preload("res://sounds/music/layer2.ogg"),
}

var music_queue_world : Array = [
	music["stalactites"],
	music["titan"],
	music["layer_2"]
]

var current_music_queue : Array = music_queue_world

var loaded_sounds : Dictionary = {}

func _ready() -> void:
	
	volume_checker = Timer.new()
	self.add_child(volume_checker)
	volume_checker.one_shot = false
	volume_checker.wait_time = 0.3
	volume_checker.connect("timeout", check_volume)
	volume_checker.start()

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), volume_bgm)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), volume_sfx)
	
	self.add_child(beat_timer)
	beat_timer.connect("timeout", _on_beat_occured)
	self.add_child(main_bgm_player)
	main_bgm_player.bus = "BGM"
	main_bgm_player.connect("finished", self._on_music_finished)
	
	for i in range(players_count_sfx):
		var newply2D = AudioStreamPlayer2D.new()
		newply2D.bus = "SFX"
		SFXPlayers2D.append(newply2D)
		self.add_child(newply2D)
		newply2D.connect("finished", _on_audio_stream_finished.bind(newply2D))
		
		var newply = AudioStreamPlayer.new()
		newply.bus = "SFX"
		SFXPlayers.append(newply)
		self.add_child(newply)
		newply.connect("finished", _on_audio_stream_finished.bind(newply))
	
	for i in range(players_count_bgm):
		var newply = AudioStreamPlayer.new()
		newply.bus = "BGM"
		BGMPlayers.append(newply)
		self.add_child(newply)
		newply.connect("finished", _on_audio_stream_finished.bind(newply))
	
	

func playSFXAtPosition(path : String, where : Vector2):
	load_sound(path)
	
	var stream : AudioStream = loaded_sounds[path]
	for player : AudioStreamPlayer2D in SFXPlayers2D:
		if !player.playing:
			player.stream = stream
			player.global_position = where
			player.pitch_scale = 1.0 + randf_range(-sound_pitch_variation, sound_pitch_variation)
			player.play()
			return

func playSFX(path : String, random_pitch : bool = true):
	load_sound(path)
	
	var stream : AudioStream = loaded_sounds[path]
	for player : AudioStreamPlayer in SFXPlayers:
		if !player.playing:
			player.stream = stream
			player.pitch_scale = 1.0 + randf_range(-sound_pitch_variation, sound_pitch_variation)
			if !random_pitch: player.pitch_scale = 1.0
			player.play()
			return

func playBGM(path : String):
	load_sound(path)
	
	var stream : AudioStream = loaded_sounds[path]
	for player : AudioStreamPlayer in BGMPlayers:
		if !player.playing:
			player.stream = stream
			player.play()
			return

func load_sound(path : String):
	if not loaded_sounds.has(path):
		loaded_sounds[path] = load(path)
		print("Loaded sound: ", path)


func _on_audio_stream_finished(player):
	# Add player to array of ready players
	pass

func start_world_playlist():
	current_music_queue = music_queue_world
	var track : AudioStream = current_music_queue.pop_front()
	if main_bgm_player.playing:
		main_bgm_player.stop()
	main_bgm_player.stream = track
	main_bgm_player.play()
	await_audio_playback(main_bgm_player)
	#await get_tree().create_timer(beat_delay).timeout
	current_music_queue.append(track)
	current_bpm = track.get_bpm()
	print("bpm: ", str(current_bpm))
	beat_timer.wait_time = 1.0 / (current_bpm / 60.0)
	beat_timer.start()

func _on_beat_occured():
	emit_signal("music_beat_occured")
	
func await_audio_playback(player : AudioStreamPlayer):
	while not player.is_playing:
		await get_tree().process_frame

func _on_music_finished():
	# stop beat timer
	beat_timer.stop()
	
	# play next song from queue
	var track : AudioStream = current_music_queue.pop_front()
	main_bgm_player.stream = track
	main_bgm_player.play()
	await_audio_playback(main_bgm_player)
	
	current_music_queue.append(track)
	current_bpm = track.get_bpm()
	print("bpm: ", str(current_bpm))
	beat_timer.wait_time = 1.0 / (current_bpm / 60.0)
	beat_timer.start()
	
func play_menu_music():
	var track : AudioStream = music["sunset"]
	if main_bgm_player.stream == track and main_bgm_player.playing:
		return
	if main_bgm_player.playing:
		main_bgm_player.stop()
	main_bgm_player.stream = track
	main_bgm_player.play()
	
func set_volume(bus : String, vol_db : float):
	match bus:
		"SFX":
			volume_sfx = vol_db
		"BGM":
			volume_bgm = vol_db
			
	var bus_index = AudioServer.get_bus_index(bus)
	AudioServer.set_bus_volume_db(bus_index, vol_db)

func check_volume():
	return
	var sfxbus = AudioServer.get_bus_index("SFX")
	var bgmbus = AudioServer.get_bus_index("BGM")
	#sfx
	if AudioServer.get_bus_volume_db(sfxbus) != volume_sfx:
		print("set sfx")
		set_volume("SFX", volume_sfx)
	#bgm
	if AudioServer.get_bus_volume_db(bgmbus) != volume_bgm:
		print("set bgm")
		set_volume("BGM", volume_bgm)
