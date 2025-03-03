extends Control

@export var player: Node2D
const TICK_MARK = preload("res://assets/scenes/user_interface/tick_mark.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


var tick_hover_radius: int = 100 ## how far away the ticks will settle around
var tick_angular_velocity: int = 15 ## how fast the ticks will move around the circle per beam charge, deg/s
var trig_time: float = 0 ## don't set this
var tick_wobble_inertia: float = 0 ## for later
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = get_global_mouse_position() - size * 0.5
	trig_time = trig_time + delta * 10 # this fucking sucks. i have never written anything worse
	set_ticks(floor(player.beam_charge))
	#tick_wobble_amount = pow(((player.MAX_DASH_CHARGE - player.dash_charge) / player.MAX_DASH_CHARGE), 2) * 10
	var tick_wobble_amount = pow(player.beam_charge, 1.1) * 0.5
	
	for tick in $Ticks.get_children():
		tick.rotation = lerp(tick.rotation, tick.get_meta("rotation_offset"), 0.1)
		tick.position = Vector2.from_angle(tick.rotation) * (tick_hover_radius + (sin(tick.rotation * 3 + (trig_time)) * tick_wobble_amount))
	
	$Ticks.rotation_degrees += tick_angular_velocity * player.beam_charge * delta
	if player.is_dashing:
		$Circle1.modulate.a = move_toward($Circle1.modulate.a, 0.2, 5 * delta)
		$Ticks.modulate.a = move_toward($Ticks.modulate.a, 1, 5 * delta)
	else:
		$Circle1.modulate.a = move_toward($Circle1.modulate.a, 1, 5 * delta)
		$Ticks.modulate.a = move_toward($Ticks.modulate.a, 0.2, 5 * delta)
		#$Circle1.scale = Vector2.ONE * ((sqrt((global_position - player.global_position).length()) * 0.1))
		pass
	

func _input(event: InputEvent) -> void:
	pass

## do not use these functions unless you call recalculate_ticks_position() after
func add_tick() -> void:
	var newborn = TICK_MARK.instantiate()
	$Ticks.add_child(newborn)

func remove_tick() -> void:
	var dying = $Ticks.get_child($Ticks.get_child_count() - 1)
	dying.hide()
	dying.free()

func set_ticks(amount: int):
	var current: int = $Ticks.get_child_count()
	if amount > current:
		for i in range(0, amount - current):
			add_tick()
		recalculate_ticks_position()
		return
	if amount < current:
		for i in range(0, current - amount):
			remove_tick()
		recalculate_ticks_position()
		return

func recalculate_ticks_position() -> void:
	var total_ticks = $Ticks.get_child_count()
	var count: int = 0
	for tick in $Ticks.get_children():
		tick.set_meta("rotation_offset", count * (TAU / total_ticks))
		count += 1


func _on_player_beam_fired(charges_used: int) -> void:
	pass # Replace with function body.
