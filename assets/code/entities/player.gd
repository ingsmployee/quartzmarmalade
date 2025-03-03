extends CharacterBody2D

const LASER_SCENE: PackedScene = preload("res://assets/scenes/entities/laser.tscn")
const BEAM_SCENE: PackedScene = preload("res://assets/scenes/entities/beam.tscn")

@export var living_stats: LivingStats
@onready var health = living_stats.max_health
var random = RandomNumberGenerator.new()

var max_velocity: float = 100
var dash_velocity: float = 200
var acceleration: float = 300

var can_fire_projectile: bool = true
var can_parry: bool = true
var is_parrying: bool = false


var dash_charge: float
var dash_regen_speed: float = 0.5
const DASH_DEPLETE_SPEED: float = 1
const MAX_DASH_CHARGE = 3
var is_dashing: bool = false

## This is how much damage the beam will deal.
var beam_charge: float = 0
## This is how much damage the beam gains per second of dash.
var beam_charge_rate: float = 1.2
## This is how much charge you get for beginning a dash.
var beam_charge_from_dash: float = 0.5

const PARRY_WINDOW: float = 0.1
const PARRY_COOLDOWN: float = 0.2

signal collided_with_wall(body: StringName, shape: StringName) ## for rearranging tiles
signal beam_fired(charges_used: int) ## for special cursor effects when you fire the beam

func _ready() -> void:
	dash_charge = MAX_DASH_CHARGE
	#$%DashBar.max_value = MAX_DASH_CHARGE

var last_velocity: Vector2 = Vector2.ZERO
func _physics_process(delta: float) -> void:
	# remember that direct physics things like velocity handle delta for you
	var desired_motion: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if desired_motion != Vector2.ZERO:
		if is_dashing:
			velocity = velocity.move_toward(desired_motion * dash_velocity, delta * acceleration * 50)
		else:
			var current_movement_factor: float = max(1, max_velocity / max(0.01,velocity.length()))
			
			velocity = velocity.move_toward(desired_motion * max_velocity, delta * current_movement_factor * acceleration * (1 + 0.3 * velocity.normalized().dot(desired_motion)))
	else:
		if is_dashing:
			velocity = Vector2.ZERO
		else:
			velocity = last_velocity.move_toward(Vector2.ZERO, delta * 200)
		#velocity = velocity.move_toward(Vector2.ZERO, delta * 0.0001)
	
	if Input.is_action_just_pressed("special") && dash_charge > 0.2:
			dash_charge -= 0.4
			is_dashing = true
			velocity = 2.5 * desired_motion * dash_velocity
			beam_charge += beam_charge_from_dash
			
			if can_parry:
				dash_charge -= 0.1
				begin_parry()
	if Input.is_action_just_released("special"):
		is_dashing = false
		velocity = velocity * 1.05
	
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
		beam_charge += delta * beam_charge_rate
		dash_charge -= DASH_DEPLETE_SPEED * delta
		if dash_charge < 0:
			dash_charge = 0
			is_dashing = false
	else:
		#beam_charge = move_toward(beam_charge, 0, delta * 0.15)
		dash_charge = move_toward(dash_charge, MAX_DASH_CHARGE, dash_regen_speed * delta)
	
	modulate = lerp(Color(1,0,0,1), Color(1,1,1,1), dash_charge / MAX_DASH_CHARGE)
	$PointLight2D.energy = lerp(1.0, 0.5, dash_charge / MAX_DASH_CHARGE)
	$PointLight2D.color = modulate
	$BodySprite2D.material.set_shader_parameter("glow_strength", lerp(0.3, 0.0, dash_charge / MAX_DASH_CHARGE))
	
	last_desired_process_motion = desired_motion
	if is_dashing && beam_charge >= 1:
		if Input.is_action_just_pressed("primary_fire"):
			fire_beam(floor(beam_charge))
		elif Input.is_action_just_pressed("secondary_fire"):
			fire_beam(1)
	elif Input.is_action_pressed("primary_fire") && can_fire_projectile && !is_dashing:
		can_fire_projectile = false
		fire_projectile()
		$PrimaryFireTimer.start()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash"):
		$"..".spawn_entity("traffic_cone", get_global_mouse_position())

func fire_projectile() -> void:
	var laser = LASER_SCENE.instantiate()
	laser.global_position = $Cannon/Marker2D.global_position
	laser.rotation = $Cannon.rotation
	laser.rotation_degrees += random.randfn(0, 2)
	$"../../Projectiles".add_child(laser)
	laser.move_speed = 500
	laser.add_collision_exception_with(self)
	laser.set_meta("owner", self)
	laser.add_beam_charge.connect(_on_beam_return_charge)
	laser.change_direction()

func fire_beam(power: int) -> void:
	var beam = BEAM_SCENE.instantiate()
	beam.global_position = $Cannon/Marker2D.global_position
	beam.rotation = $Cannon.rotation
	$"../../Projectiles".add_child(beam)
	beam.set_meta("owner", self)
	beam.add_beam_charge.connect(_on_beam_return_charge)
	beam.fire($Cannon/Marker2D/RayCast2D.get_collider(), floor(beam_charge))
	beam_charge -= power

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
	print("executing parry")
	can_parry = false
	body.rotation = $Cannon.rotation
	body.change_direction()

func damage(damage_number: float) -> bool:
	health = living_stats.damage(health, damage_number)
	return health <= 0

func _on_primary_fire_timer_timeout() -> void:
	can_fire_projectile = true

func _on_parry_timer_timeout() -> void:
	if is_parrying:
		deactivate_parry()
		return
	can_parry = true
	$ParryTimer.wait_time = PARRY_WINDOW

func _on_parry_area_body_entered(body: Node2D) -> void:
	if can_parry && body.is_in_group("parriable_projectiles") && body.get_meta("owner", Node2D) != self:
		execute_parry(body)

func _on_beam_return_charge(amount: float) -> void:
	beam_charge += amount
	dash_charge = move_toward(dash_charge, 2, amount * 0.5)
