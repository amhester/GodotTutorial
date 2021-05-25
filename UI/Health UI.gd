extends Control

var max_hearts = 4 setget set_max_hearts
var hearts = 4 setget set_hearts

const HEART_WIDTH = 15
onready var hearts_full_ui = $HeartUIFull
onready var hearts_empty_ui = $HeartUIEmpty

func set_max_hearts(value):
	max_hearts = max(value, 1)
	hearts_empty_ui.rect_size.x = HEART_WIDTH*max_hearts

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	hearts_full_ui.rect_size.x = HEART_WIDTH*hearts

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_change", self, "_on_PlayerStats_health_change")
	PlayerStats.connect("max_health_change", self, "_on_PlayerStats_max_health_change")

func _on_PlayerStats_health_change(new_health):
	self.hearts = new_health

func _on_PlayerStats_max_health_change(new_max_health):
	self.max_hearts = new_max_health
