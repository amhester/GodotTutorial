extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

var velocity = Vector2.ZERO
export var acceleration = 500
export var max_speed = 50
export var friction = 200

export var knockback = Vector2.ZERO
export var knockback_velocity = 150
export var knockback_friction = 500

onready var sprite = $BatSprite
onready var stats = $Stats
onready var player_zone = $PlayerDetection
onready var hurtbox = $Hurtbox
onready var soft_collider = $SoftCollision
onready var wander_controller = $WanderController

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = IDLE

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_friction * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			handle_idle(delta)
		WANDER:
			handle_wander(delta)
		CHASE:
			handle_chase(delta)
	
	handle_move(delta)

func handle_move(delta):
	velocity += soft_collider.get_push_vector() * delta * acceleration
	velocity = move_and_slide(velocity)

func handle_idle(delta):
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	seek_player()
	update_wander_controller()

func handle_wander(delta):
	seek_player()
	var wander_position = (wander_controller.target_position.normalized() * max_speed) + global_position
	velocity = velocity.move_toward(wander_position, acceleration * delta)
	sprite.flip_h = velocity.x < 0

func handle_chase(delta):
	var player = player_zone.player
	if player != null:
		move_to(player.global_position, delta)
	else:
		state = IDLE

func move_to(position, delta):
	var direction = global_position.direction_to(position).normalized()
	velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if player_zone.can_see_player():
		state = CHASE

func update_wander_controller():
	if randi() % 100 > 99:
		state = WANDER
		wander_controller.start(rand_range(1, 2))

func _on_Hurtbox_area_entered(area):
	stats.take_damage(area.damage)
	hurtbox.create_hit_effect()
	var knockback_direction = area.knockback_vector
	knockback = knockback_direction * knockback_velocity


func _on_Stats_zero_health():
	var death_effect = EnemyDeathEffect.instance()
	death_effect.global_position = global_position
	get_parent().add_child(death_effect)
	queue_free()

func _on_WanderController_on_wander_finish(start_position):
	state = IDLE
