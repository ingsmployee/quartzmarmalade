extends CharacterBody2D

@export var living_stats: LivingStats

const ACCELERATION = 100

func _physics_process(delta: float) -> void:
	var desired_motion: Vector2 = $NavigationAgent2D.get_next_path_position()
	
	velocity = velocity.move_toward(desired_motion, ACCELERATION)
	
	if move_and_slide():
		var collision: KinematicCollision2D = get_last_slide_collision()
		var collider = collision.get_collider()
		if collider is Node && collider.get_groups().has("friendly"):
			explode()

func explode() -> void:
	$AnimationPlayer.play("explode")


func _on_redo_navigation_timer_timeout() -> void:
	var target = get_tree().get_first_node_in_group("targeted")
	$NavigationAgent2D.target_position = target.global_position
