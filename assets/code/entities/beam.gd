extends Area2D

var started: bool = false

func fire(distance: float):
	print("fired")
	if !started:
		start(distance)

func start(distance: float):
	started = true
	$Control.size.x = distance

func _process(delta: float):
	print($Control.size.x)
