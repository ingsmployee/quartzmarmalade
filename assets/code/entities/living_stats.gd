extends Resource
class_name LivingStats

## Maximum health of the creature. Lasers deal 1 damage to start with. Only relevant for regenarating creatures.
@export var max_health: float = 2
## Health regenerated per second on average.
@export var health_regen: float = 0
## Whether or not this creature is currently invulnerable.
@export var invulnerable: bool = false
## Can only die if the creature's health is below this number. Otherwise, it will be set to (this number - 0.01). This is mostly intended for player characters.
@export var death_threshold: float = 0

func damage(health: float, damage_number: float) -> float:
	if invulnerable:
		return -1
	
	var previous_health = health
	health -= damage_number
	if health < 0:
		if death_threshold > 0 && previous_health > death_threshold:
			return death_threshold - 0.01
		else:
			return 0
	
	return health
