extends Enemy

enum states {
	PATROL_IDLE,
	PATROL_WALK,
	CHASE,
	DIE
}

const WALK_SPEED = 100
const CHASE_SPEED = 200

const GRAVITY = 981
const MAX_GRAVITY = 10000

const MIN_PATROL_TIME = 2
const MAX_PATROL_TIME = 10

onready var colliders : Node2D = $Colliders
onready var player_detectors : Array = $Colliders/Raycasts.get_children()
onready var edge_detector : Area2D = $Colliders/EdgeDetector
onready var animator : AnimationTree = $AnimationTree
onready var animation_state : AnimationNodeStateMachinePlayback = animator["parameters/playback"] 
onready var sprite : Sprite = $Sprite
onready var patrol_timer : Timer = $Timers/PatrolTimer

var velocity : Vector2 = Vector2.ZERO
var player : Player = null

var state = states.PATROL_WALK

var patrol_direction : float = -1
var flipped : bool = false

func _ready() -> void:
	patrol_timer.start(0.1)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	
	match state:
		states.PATROL_WALK:
			velocity.x = patrol_direction * WALK_SPEED
			animation_state.travel("walk")
			#check if player is near
			for raycast in player_detectors:
				raycast = raycast as RayCast2D
				if raycast.is_colliding() and raycast.get_collider() is Player:
					player = raycast.get_collider()
					state = states.CHASE
			velocity = move_and_slide(velocity)
			#if not edge_detector.is_colliding():
			#	flip(not flipped)
			
		states.PATROL_IDLE:
			animation_state.travel("idle")
			
			#check if player is near
			for raycast in player_detectors:
				raycast = raycast as RayCast2D
				if raycast.is_colliding():
					if raycast.get_collider() is Player:
						player = raycast.get_collider()
						state = states.CHASE
					
					
		states.CHASE:
			if player:
				velocity.x = clamp(player.global_position.x - global_position.x, -1, 1) * CHASE_SPEED
				velocity = move_and_slide(velocity)
				
		states.DIE:
			animation_state.travel("die")

func apply_gravity(delta : float) -> void:
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_GRAVITY)

func flip(val : bool) -> void:
	sprite.flip_h = val
	colliders.scale.x = 1 - (2 * int(val))
	patrol_direction *= -1
	flipped = val
	

#When ur supposed to die
func _on_Hurtbox_area_entered(area: Area2D) -> void:
	state = states.DIE


func _on_PatrolTimer_timeout() -> void:
	patrol_timer.start( rand_range(MIN_PATROL_TIME, MAX_PATROL_TIME) )


func _on_EdgeDetector_body_exited(body: Node) -> void:
	if not body in edge_detector.get_overlapping_bodies():
		flip(not flipped)


func _on_WallDetector_body_entered(body: Node) -> void:
	flip(not flipped)
