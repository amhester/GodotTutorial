extends Node

export(int) var max_health = 1
onready var health = max_health

signal zero_health
signal health_change(new_health)
signal max_health_change(new_max_health)

func set_max_health(value):
	max_health = value
	set_health(min(health, max_health))
	emit_signal("max_health_change", max_health)

func set_health(value):
	health = clamp(value, 0, max_health)
	emit_signal("health_change", health)
	if health == 0:
		emit_signal("zero_health")

func take_damage(dmg):
	set_health(health - dmg)
