extends Node
class_name StateMachine

onready var player : Player = get_parent()
onready var states : Array = get_children()

var current_state : State

func _ready() -> void:
	yield(get_tree().root, "ready")
	for state in states:
		state = state as State
		state.p = player
		state.connect("transition", self, "transition")
		state._initialize()
	current_state = $Walk
	current_state._enter()

func _physics_process(delta: float) -> void:
	current_state._update(delta)
	current_state._animate(player.animation_state, player.animation_tree)
	
func transition(newstate : String) -> void:
	current_state._exit(newstate)
	current_state = get_node(newstate)
	current_state._enter()
