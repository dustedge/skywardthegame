extends Node

@onready var SFXPlayers2D : Array[AudioStreamPlayer2D]
@onready var SFXPlayers :  Array[AudioStreamPlayer]
@onready var BGMPlayers :  Array[AudioStreamPlayer]

var players_count_sfx = 50
var players_count_bgm = 10
var sound_pitch_variation = 0.1

var loaded_sounds : Dictionary = {}

func _ready() -> void:
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
