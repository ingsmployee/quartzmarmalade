extends CharacterBody2D

const LASER_SCENE: PackedScene = preload("res://assets/scenes/entities/laser.tscn")

var living_stats = LivingStats.new()

var max_velocity: float = 100
var dash_velocity: float = 200
var acceleration: float = 300

var can_fire_primary: bool = true
var can_parry: bool = true
var is_parrying: bool = false

var dash_charge: float
var dash_regen_speed: float = 0.8
const DASH_DEPLETE_SPEED: float = 1
const MAX_DASH_CHARGE = 3
var is_dashing: bool = false

const PARRY_WINDOW: float = 0.1
const PARRY_COOLDOWN: float = 0.2

signal collided_with_wall(body: StringName, shape: StringName)

func _ready() -> void:
	dash_charge = MAX_DASH_CHARGE
	$%DashBar.max_value = MAX_DASH_CHARGE

var last_velocity: Vector2 = Vector2.ZERO
func _physics_process(delta: float) -> void:
	# remember that direct physics things like velocity handle delta for you
	var desired_motion: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if desired_motion != Vector2.ZERO:
		if is_dashing:
			velocity = velocity.move_toward(desired_motion * dash_velocity, delta * acceleration * 10)
		else:
			velocity = velocity.move_toward(desired_motion * max_velocity, delta * acceleration)
	else:
		velocity = last_velocity.move_toward(Vector2.ZERO, delta * 200)
		#velocity = velocity.move_toward(Vector2.ZERO, delta * 0.0001)
	
	if Input.is_action_just_pressed("special"):
			dash_charge -= 0.2
			is_dashing = true
			velocity = 1.5 * desired_motion * dash_velocity
			
			if can_parry:
				dash_charge -= 0.1
				begin_parry()
	if !Input.is_action_pressed("special"):
		is_dashing = false
	
	if move_and_slide() && is_on_wall():
		var collision = get_last_slide_collision()
		var collider_name = collision.get_collider().get("name")
		# i don't think this will work
		if collider_name == "Top" || collider_name == "Right" || collider_name == "Left" || collider_name == "Bottom":
			emit_signal("collided_with_wall", collider_name, collision.get_collider_shape().get("name"))
			velocity = collision.get_collider().get("constant_linear_velocity")
			
	last_velocity = velocity

var last_desired_process_motion: Vector2
func _process(delta: float) -> void:
	$Cannon.look_at(get_global_mouse_position())
	var desired_motion = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if is_dashing:
		dash_charge -= DASH_DEPLETE_SPEED * delta
		if dash_charge < 0:
			dash_charge = 0
			is_dashing = false
	else:
		dash_charge = move_toward(dash_charge, MAX_DASH_CHARGE, dash_regen_speed * delta)
	$%DashBar.value = dash_charge
	
	last_desired_process_motion = desired_motion
	if Input.is_action_pressed("primary_fire") && can_fire_primary:
		can_fire_primary = false
		fire_laser()
		$PrimaryFireTimer.start()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("primary_fire") && $PrimaryFireTimer.time_left == 0:
		fire_laser()

func fire_laser() -> void:
	var laser = LASER_SCENE.instantiate()
	laser.global_position = $Cannon/Marker2D.global_position
	laser.rotation = $Cannon.rotation
	get_parent().get_node("Projectiles").add_child(laser)
	laser.move_speed = 500
	laser.add_collision_exception_with(self)
	laser.change_direction()

func add_impulse(desired_motion: Vector2) -> void:
	velocity = desired_motion * dash_velocity

func begin_parry() -> void:
	can_parry = false
	is_parrying = true
	for body in $ParryArea.get_overlapping_bodies():
		if body.is_in_group("parriable_projectiles"):
			execute_parry(body)
			deactivate_parry()
			return
	$ParryTimer.start()

func deactivate_parry() -> void:
	is_parrying = false
	$ParryTimer.stop()
	$ParryTimer.wait_time = PARRY_COOLDOWN
	$ParryTimer.start()

func execute_parry(body: Node2D) -> void:
	dash_charge += 0.5
	can_parry = false
	body.rotation = $Cannon.rotation
	body.change_direction()

func _on_primary_fire_timer_timeout() -> void:
	can_fire_primary = true

func _on_parry_timer_timeout() -> void:
	if is_parrying:
		deactivate_parry()
		return
	can_parry = true
	$ParryTimer.wait_time = PARRY_WINDOW

func _on_parry_area_body_entered(body: Node2D) -> void:
	if can_parry && body.is_in_group("parriable_projectiles"):
		execute_parry(body)
