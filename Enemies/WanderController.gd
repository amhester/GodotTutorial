extends Node2D

signal on_wander_finish

onready var start_position = global_position
onready var target_position = global_position
onready var timer = $Timer
onready var check_caster = $RayCast2D

func _physics_process(delta):
	if timer.is_stopped():
		return
	if check_caster.is_colliding():
		target_position = target_position.rotated(rand_range(22.5, 90))

func start(duration):
	check_caster.enabled = true
	update_target_position()
	timer.start(duration)

func update_target_position():
	var target_vector = Vector2(rand_range(-1, 1), rand_range(-1, 1))
	target_position = target_vector

func _on_Timer_timeout():
	check_caster.enabled = false
	emit_signal("on_wander_finish", start_position)
