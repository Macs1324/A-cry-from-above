extends State

var input_x : float = 0
	
func _animate(animation_state : AnimationNodeStateMachinePlayback, _animator : AnimationTree) -> void:
	animation_state.travel("attack_1")

func _update(delta : float) -> void:
	#machine.get_node("Walk")._update(delta)
	pass
