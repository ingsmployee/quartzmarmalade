extends Node
class_name UI

const _ENERGY_BAR = preload("res://assets/scenes/user_interface/energy_bar.tscn")

static func create_energy_bar(parent: Node, position: Vector2, font_size: int) -> Label:
	var bar: Label = _ENERGY_BAR.instantiate()
	parent.add_child(bar)
	bar.position = position
	bar.add_theme_font_size_override("font_size", font_size)
	return bar
