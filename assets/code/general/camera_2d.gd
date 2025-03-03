extends Camera2D

var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $"../Entities/Player"
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var posdiff = get_global_mouse_position() - player.position
	position = player.position + 0.5 * posdiff
	#print(posdiff.length())
	# note that the game resolution is 780x780
	## TODO: implement dynamic zoom
	#max(posdiff.x, posdiff.y)
