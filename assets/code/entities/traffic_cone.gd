extends CharacterBody2D

@export var living_stats: LivingStats
@onready var health = living_stats.max_health

const ACCELERATION = 100
var max_velocity = 100

func _physics_process(delta: float) -> void:
	var desired_motion: Vector2 = ($NavigationAgent2D.get_next_path_position() - position).normalized()
	
	velocity = velocity.move_toward(desired_motion * max_velocity * (1 + 0.5*((living_stats.max_health - health) / living_stats.max_health)), ACCELERATION * delta)
	
	if move_and_slide():
		var collision: KinematicCollision2D = get_last_slide_collision()
		var collider = collision.get_collider()
		if collider is Node && collider.get_groups().has("friendly"):
			explode()

func explode() -> void:
	$AnimationPlayer.play("explode")

func spawn() -> void:
	pass

var energy_bar: Label
func damage(damage_number: float) -> bool:
	health = living_stats.damage(health, damage_number)
	if health == 0:
		queue_free()
	if !energy_bar:
		energy_bar = UI.create_energy_bar(self, Vector2(0, -20), 10)
	energy_bar.value = round(lerp(10, 0, health / living_stats.max_health))
	
	return health <= 0

func _process(delta: float) -> void:
	health = move_toward(health, living_stats.max_health, living_stats.health_regen * delta)
	if energy_bar != null:
		energy_bar.value = round(lerp(10, 0, health / living_stats.max_health))
		if health == living_stats.max_health:
			energy_bar.queue_free()
	#print(health)

func _on_redo_navigation_timer_timeout() -> void:
	var target = get_tree().get_first_node_in_group("targeted")
	$NavigationAgent2D.target_position = target.global_position
