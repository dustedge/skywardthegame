extends HTTPRequest

var headers = ["Content-Type: application/json",
	"x-api-key: 67c649db-4295-46c4-b83c-a6008530616e"]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_leaderboards()
	pass # Replace with function body.

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		print("HTTP: Error occured with code {0}".format([response_code]))
		return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	if not json is Array: 
		print("HTTP: Received data is not an array. Ignoring...")
		return
		
	var text = ""
	var cnt = 1
	for element in json:
		text += "{0}. {1}: {2}\n".format([cnt, element["playerDisplayName"], element["score"]])
		cnt += 1
	get_parent().scores.text = text
	pass # Replace with function body.

func send_to_leaderboards(player_name : String, score : int):
	var request_body = """
	{
		"leaderboardId": "c19deb3e-47dd-45f8-8b5b-08dd18d51d89",
		"playerDisplayName": "{0}",
		"score": "{1}"
	}""".format([player_name, score])
	
	#self.request("https://api.simpleboards.dev/api/entries", headers, HTTPClient.METHOD_POST, request_body)
	pass

func update_leaderboards():
	#self.request("https://api.simpleboards.dev/api/leaderboards/c19deb3e-47dd-45f8-8b5b-08dd18d51d89/entries", headers, HTTPClient.METHOD_GET)
	pass
