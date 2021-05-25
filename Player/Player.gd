extends KinematicBody2D

const ACCEL = 500
const FRICTION = 500

export var speed = 70
export var roll_speed = 110

enum {
	MOVE,
	ROLL,
	ATTACK
}

var anim_state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var sword_hitbox = $SwordHitboxPivot/SwordHitbox
onready var stats = PlayerStats
onready var hurtbox = $Hurtbox

func _ready():
	animation_tree.active = true
	sword_hitbox.knockback_vector = roll_vector
	stats.connect("zero_health", self, "on_PlayerStats_zero_health")

func _physics_process(delta):
	match anim_state:
		MOVE:
			handle_movement(delta)
		ROLL:
			handle_roll(delta)
		ATTACK:
			handle_attack()

# Handles assigning correct velocity vector to player as well as correct animation state
func handle_movement(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		sword_hitbox.knockback_vector = input_vector
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animation_state.travel("Run")
		velocity = velocity.move_toward(input_vector.normalized() * speed, ACCEL * delta)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = move_and_slide(velocity)
	
	# Check for any changes in state
	if Input.is_action_just_pressed("attack"):
		anim_state = ATTACK
	elif Input.is_action_just_pressed("roll"):
		anim_state = ROLL

func handle_roll(delta):
	velocity = roll_vector.normalized() * roll_speed
	animation_state.travel("Roll")
	velocity = move_and_slide(velocity)

func handle_attack():
	animation_state.travel("Attack")

func on_PlayerStats_zero_health():
	queue_free()

func roll_animation_finished():
	velocity = roll_vector
	anim_state = MOVE

func attack_animation_finished():
	anim_state = MOVE

func _on_Hurtbox_area_entered(area):
	stats.take_damage(1)
	hurtbox.start_invincibility(1)
	hurtbox.create_hit_effect()
