extends CharacterBody2D

signal add_beam_charge(amount: float)

var move_speed: float
var desired_vel: Vector2
var damage = 1
var charge_from_damage = 0

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
				if collider.damage(damage):
					add_beam_charge.emit(1)
				else:
					add_beam_charge.emit(charge_from_damage)
			explode()

func explode() -> void:
	queue_free()

func _on_despawn_timer_timeout() -> void:
	queue_free()
