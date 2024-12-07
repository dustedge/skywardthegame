extends Node

enum State {
	IN_GAME,
	IN_MENU
}

var current_score : int
var current_layer : String
var current_state : State
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_state = State.IN_MENU
	
	DiscordRPC.app_id = 1314715354421006356
	print("Discord connection: " + str(DiscordRPC.get_is_discord_working()))
	 # Set the first custom text row of the activity here
	DiscordRPC.details = "In Menu"
	# Set the second custom text row of the activity here
	#DiscordRPC.state = "Layer"
	# Image key for small image from "Art Assets" from the Discord Developer website
	DiscordRPC.large_image = "icon"
	# Tooltip text for the large image
	DiscordRPC.large_image_text = "Skyward"
	# Image key for large image from "Art Assets" from the Discord Developer website
	#DiscordRPC.small_image = "icon"
	# Tooltip text for the small image
	DiscordRPC.small_image_text = "Climbing the skies"
	# "02:41 elapsed" timestamp for the activity
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	# "59:59 remaining" timestamp for the activity
	#DiscordRPC.end_timestamp = int(Time.get_unix_time_from_system()) + 3600
	# Always refresh after changing the values!
	DiscordRPC.refresh() 
	pass # Replace with function body.


func set_state(state : State):
	self.current_state = state
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	update_rpc()
	
func update_rpc():
	match current_state:
		State.IN_MENU:
			DiscordRPC.details = "In Menu"
			DiscordRPC.state = ""
		State.IN_GAME:
			DiscordRPC.details = "{0}".format([current_layer])
			DiscordRPC.state = "Height: " + str(current_score)
	DiscordRPC.refresh() 
