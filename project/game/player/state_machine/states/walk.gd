extends State

const MAX_WALK_SPEED = 200
const MAX_RUN_SPEED = 280
const ACCELERATION = 900
const FRICTION = 1000

const GRAVITY = 2000
const MAX_GRAVITY = 1000

const JUMP_FORCE = 800

var sprite : Sprite

var input_x : int = 0
var velocity : Vector2
var jump_queued : bool = false

func _enter() -> void:
	if jump_queued:
		velocity.y = -JUMP_FORCE

func _initialize() -> void:
	sprite = p.sprite

#basic platform movement code
func _update(delta : float) -> void:
	apply_gravity(delta) #adds GRAVITY * delta to the velocity y
	
	#-----------------------------------------------------------------------------			X AXIS MOVEMENT
	input_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	#IF PLAYER IS MOVING
	if input_x != 0:
		if not p.swords_out:
			velocity.x = move_toward(velocity.x, input_x * MAX_WALK_SPEED, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, input_x * MAX_RUN_SPEED, ACCELERATION * delta)
		
		#if player is going left
		if input_x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		p.flippable_colliders.rotation_degrees = 180 * int(input_x < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		
	velocity = p.move_and_slide(velocity)
	
	
	#-------------------------------------------------------------------------------------			JUMPING
	if Input.is_action_just_pressed("jump"):
		velocity.y = -JUMP_FORCE
		
	#----------------------------------------------------------------------				CHECKS FOR ATTACKING AND TRANSITIONS IF NEEDED
	if Input.is_action_just_pressed("attack"):
		emit_signal("transition", "Attack")
	
	
#animates dat shiet
func _animate(animation_state : AnimationNodeStateMachinePlayback, animator : AnimationTree) -> void:
	if input_x != 0:
		if not p.swords_out:
			animation_state.travel("run")
		else:
			animation_state.travel("run_swords")
	else:
		if not p.swords_out:
			animation_state.travel("idle")
		else:
			animation_state.travel("idle_swords")
			
func apply_gravity(delta : float) -> void:
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_GRAVITY)

func _exit(newstate : String) -> void:
	match newstate:
		"Airborne":
			get_parent().get_node("Airborne").velocity = velocity
			velocity = Vector2.ZERO
		"Attack":
			get_parent().get_node("Attack").input_x = input_x

func _on_GroundDetector_body_exited(_body: Node) -> void:
	emit_signal("transition", "Airborne")
