extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

var invincible = false setget set_invincible

signal on_invincibility_start
signal on_invincibility_end

onready var timer = $Timer

func set_invincible(is_invincible):
	invincible = is_invincible
	if invincible == true:
		emit_signal("on_invincibility_start")
	else:
		emit_signal("on_invincibility_end")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	effect.global_position = global_position
	main.add_child(effect)

func _on_Timer_timeout():
	self.invincible = false

func _on_Hurtbox_on_invincibility_start():
	set_deferred("monitorable", false)

func _on_Hurtbox_on_invincibility_end():
	set_deferred("monitorable", true)
