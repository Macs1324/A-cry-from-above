extends Node
class_name State

var p : Player
signal transition(newstate)
onready var machine = get_parent()

func _ready() -> void:
	pass
	#owner = get_parent()

func _enter() -> void:
	pass
	
func _update(delta : float) -> void:
	pass
	
func _animate(animation_state : AnimationNodeStateMachinePlayback, animator : AnimationTree) -> void:
	pass
	
func _exit(newstate : String) -> void:
	pass

func _initialize() -> void:
	pass

func active() -> bool:
	return machine.current_state.name == name
