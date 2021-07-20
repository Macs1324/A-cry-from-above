extends State

const GRAVITY = 2000
const MAX_GRAVITY = 1000
const MAX_SPEED = 280
const MAX_SPEED_SWORDSOUT = 350

const ACCELERATION = 800
const ACCELERATION_SWORDSOUT = 1500
const FRICTION = 600

const JUMP_CUTOFF = 3
const JUMP_QUEUE_TIME = 0.1
const COYOTE_TIME = 0.2

const LAND_CUTOFF = 3

#node references
var sprite : Sprite
onready var jump_queue = $JumpQueue
onready var coyote_timer = $CoyoteTimer

#global variables
var velocity : Vector2
var input_x : float
var can_coyote_jump : bool = false

func _initialize() -> void:
	sprite = p.sprite
	
func _enter() -> void:
	can_coyote_jump = true
	coyote_timer.start(COYOTE_TIME)
	
func _update(delta : float) -> void:
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_GRAVITY)
	
	input_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	if input_x != 0:
		sprite.flip_h = input_x < 0                              #flips sprite and hitboxes according to the input
		p.flippable_colliders.rotation_degrees = 180 * int(input_x < 0)
		
		velocity.x = move_toward(velocity.x, input_x * MAX_SPEED_SWORDSOUT, ACCELERATION_SWORDSOUT * delta)  #accelerates the player
			
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)       #decelerates the player
		
	if velocity.y < 0:
		if Input.is_action_just_released("jump"):        #Allows the player to control jump height
			velocity.y /= JUMP_CUTOFF
	
	if Input.is_action_just_pressed("jump"):
		if can_coyote_jump and velocity.y >= 0:
			velocity.y = -machine.get_node("Walk").JUMP_FORCE        #Does the coyote jump
		else:
			jump_queue.start(JUMP_QUEUE_TIME)
			machine.get_node("Walk").jump_queued = true     #Jump-queues
	
	velocity = p.move_and_slide(velocity)

func _on_GroundDetector_body_entered(_body: Node) -> void:
	emit_signal("transition", "Walk")

func _animate(animation_state : AnimationNodeStateMachinePlayback, _animator : AnimationTree) -> void:
	if velocity.y < 0:
		animation_state.travel("jump_up_swords")
	else:
		animation_state.travel("jump_down_swords")


func _on_JumpQueue_timeout() -> void:
	machine.get_node("Walk").jump_queued = false


func _on_CoyoteTimer_timeout() -> void:
	can_coyote_jump = false

func _exit(newstate : String):
	if newstate == "Walk":
		machine.get_node("Walk").velocity = velocity
		machine.get_node("Walk").velocity.x /= LAND_CUTOFF

#Wall Sliding
func _on_WallDetector_body_entered(body: Node) -> void:
	#we only want that when our swords are out
	if active():
		emit_signal("transition", "WallHang")
