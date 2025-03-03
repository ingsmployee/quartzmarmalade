extends Node2D

var started: bool = false
var desired_length: float
var attack_damage: int
var light_tween: Tween

signal add_beam_charge(amount: float)

func fire(target: Node2D, beam_damage: int = attack_damage) -> void:
	attack_damage = beam_damage
	get_tree().create_tween().bind_node(self).tween_property($PointLight2D, "texture_scale", 0.2, 0.1).set_ease(Tween.EASE_OUT)
	$AnimationPlayer.play("fire")
	if target.is_in_group("hostile"):
		if target.damage(attack_damage):
			add_beam_charge.emit(max(2, attack_damage - 2))
		else:
			add_beam_charge.emit(max(0, floor(attack_damage / 2)))
	if attack_damage > 3:
		$StrongTexture.show()
	if !started:
		start(target.global_position)

func start(target_position: Vector2, beam_damage: int = 0) -> void:
	attack_damage = beam_damage
	started = true
	desired_length = (target_position - global_position).length()
	$Area2D.global_position = target_position
	call_deferred("attack")

func _process(delta: float) -> void:
	if $WeakTexture.size.x < desired_length:
		$WeakTexture.size.x += 10000 * delta
	
	if $StrongTexture.size.x < desired_length:
		$StrongTexture.size.x += 8000 * delta
	
	if $PointLight2D.position.x < desired_length:
		$PointLight2D.position.x += 5000 * delta
	elif light_tween == null:
		light_tween = get_tree().create_tween()
		light_tween.tween_property($PointLight2D, "energy", 0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	

func _on_despawn_timer_timeout() -> void:
	queue_free()

func attack() -> void:
	var bodies: Array[Node2D] = $Area2D.get_overlapping_bodies()
	for body: Node2D in bodies:
		if body.is_in_group("hostile"):
			body.damage(attack_damage)

func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
