extends Node2D

enum Ingredients {CARROT, CHILLI, LEAF_ONION, MUSHROOM, POTATO, TOMATO}

var draggable = false
var dragging = false
@export var cut = false
@export var ingredient: Ingredients

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("m_right") and draggable:
		cut = true
		$RigidBody2D/AnimatedSprite2D.animation = "sliced"
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and draggable:
		dragging = true
	else: 
		dragging = false

	if dragging:
		$RigidBody2D.freeze = true
		$RigidBody2D.rotation = 0
		$RigidBody2D.global_position = get_global_mouse_position()
	else:
		$RigidBody2D.freeze = false
		$RigidBody2D.lock_rotation = false

	$RigidBody2D/AnimatedSprite2D.frame = ingredient

func _on_area_2d_mouse_entered() -> void:
	draggable = true
	pass # Replace with function body.

func _on_area_2d_mouse_exited() -> void:
	if not dragging:
		draggable = false
	pass # Replace with function body.

func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area.get_groups())
	if area.is_in_group("utensil") and cut:
		Globals.sendIngredient.emit(ingredient, area)
		queue_free()
	pass # Replace with function body.
