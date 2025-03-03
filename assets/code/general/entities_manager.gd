extends Node2D

var entities: Dictionary = {
	"traffic_cone": preload("res://assets/scenes/entities/traffic_cone.tscn")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_entity(entity_name: StringName, pos: Vector2) -> void:
	var newborn: Node2D = entities[entity_name].instantiate()
	newborn.position = pos
	add_child(newborn)
	newborn.spawn()
