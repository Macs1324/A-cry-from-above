extends State

enum phases {
	HANGING,
	SLIDING
}

onready var start_sliding_timer = $StartSliding
onready var detach_timer = $Detach

const SLIDING_SPEED = 120
const HANG_TIME = 0.3
const DETACH_TIME = 0.2
const JUMP_FORCE = 600
const JUMP_X_FORCE = 150

var phase : int = phases.HANGING
var flip_dir : float

func _enter() -> void:
	flip_dir = (2 * p.sprite.flip_h as int) - 1
	phase = phases.HANGING
	start_sliding_timer.start(HANG_TIME)

func _update(delta : float) -> void:
	match phase:
		phases.HANGING:
			pass
		phases.SLIDING:
			p.move_and_slide( Vector2(0, SLIDING_SPEED) )
			
	if Input.is_action_just_pressed("jump"):
		machine.get_node("Airborne").velocity.y = -JUMP_FORCE
		machine.get_node("Airborne").velocity.x = JUMP_X_FORCE * flip_dir
		emit_signal("transition", "Airborne")
	if flip_dir > 0:
		if Input.is_action_just_pressed("left"):
			detach_timer.start(DETACH_TIME)
	else:
		if Input.is_action_just_pressed("right"):
			detach_timer.start(DETACH_TIME)

#When he starts sliding
func _on_StartSliding_timeout() -> void:
	phase = phases.SLIDING

func _animate(animation_state : AnimationNodeStateMachinePlayback, animator : AnimationTree) -> void:
	animation_state.travel("wall_hang")



func _on_WallDetector_body_exited(body: Node) -> void:
	if active():
		emit_signal("transition", "Airborne")


func _on_Detach_timeout() -> void:
	if active():
		if flip_dir > 0:
			if Input.is_action_pressed("left"):
				detach_timer.start(DETACH_TIME)
		else:
			if Input.is_action_pressed("right"):
				detach_timer.start(DETACH_TIME)
