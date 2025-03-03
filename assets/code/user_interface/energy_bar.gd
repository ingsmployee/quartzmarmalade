extends Label

var value: int = 0
var progress_character: String = "/"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# absolutely a better way to do this
	var progress: String = ""
	for i in range(0, value):
		progress += progress_character
	text = "[ %s ]" % progress
