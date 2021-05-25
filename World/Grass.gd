extends Node2D

onready var GrassEffect = preload("res://Effects/GrassEffect.tscn")

func _on_Hurtbox_area_entered(area):
	kill_grass()

func kill_grass():
	var grass_effect = GrassEffect.instance()
	grass_effect.global_position = global_position
	get_parent().add_child(grass_effect)
	queue_free()
