extends KinematicBody2D
class_name Enemy

export(float) var max_health

onready var health : float = max_health

func take_damage(amount : float) -> void:
	health -= amount
	_on_take_damage()

func _on_take_damage() -> void:
	pass
