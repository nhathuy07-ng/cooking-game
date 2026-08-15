extends Node2D

enum Ingredients { CARROT, CHILLI, LEAF_ONION, MUSHROOM, POTATO, TOMATO }
@export var ingrdropper: Node2D
@export var ingredient: Ingredients

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D/Node2D/AnimatedSprite2D.frame = ingredient
	pass # Replace with function body.

func spawn_ingredient(_i: Ingredients):
	var _res = ResourceLoader.load("res://components/ingredient.tscn")
	var ingr = _res.instantiate()
	ingr.ingredient = _i
	ingr.global_position = ingrdropper.global_position
	ingr.global_position.y -= 20
	
	get_tree().current_scene.add_child(ingr)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if clickable and Input.is_action_just_pressed("m_left"):
		spawn_ingredient(ingredient)


var clickable = false
func _on_area_2d_mouse_entered() -> void:
	clickable = true
	$AnimatedSprite2D.frame = 1
	$AnimatedSprite2D/Node2D.position.y = 30.945
	$AnimatedSprite2D/Node2D.scale.y = 0.805
	pass # Replace with function body.


func _on_area_2d_mouse_exited() -> void:
	clickable = false
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D/Node2D.position.y = 0
	$AnimatedSprite2D/Node2D.scale.y = 1
	pass # Replace with function body.
