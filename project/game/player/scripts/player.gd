extends KinematicBody2D
class_name Player

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree["parameters/playback"]
onready var sprite = $Sprite
onready var flippable_colliders = $Colliders/Flippable
