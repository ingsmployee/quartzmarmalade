extends CharacterBody2D

var move_speed: float
var desired_vel: Vector2
var damage = 1

func change_direction() -> void:
	desired_vel = Vector2(cos(rotation) * move_speed, sin(rotation) * move_speed)

func _physics_process(delta: float) -> void:
	velocity = desired_vel
	if move_and_slide():
		var collision = get_last_slide_collision()
		var collider = collision.get_collider()
		if collider is Node:
			var groups: Array[StringName] = collider.get_groups()
			if groups.has("living"):
				collider.damage(damage)
			explode()

func explode() -> void:
	queue_free()

func _on_despawn_timer_timeout() -> void:
	queue_free()
