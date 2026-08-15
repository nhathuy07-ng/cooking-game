extends Node2D

var dragging := false
var draggable := false
var percentFilled := 0.0
var init_position = Vector2.ZERO
var filling_speed = 1
var is_filling = false
var area_to_fill = null
var percent_to_fill = 0.0

func process_dnd():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and draggable:
		dragging = true
		$RigidBody2D.rotation = 0
		$RigidBody2D.gravity_scale = 0.0
		$RigidBody2D.freeze = true
	else:
		dragging = false
		$RigidBody2D.gravity_scale = 9.8
		$RigidBody2D.freeze = false
		$RigidBody2D.lock_rotation = false
		
	if dragging:
		$RigidBody2D.global_position = get_global_mouse_position()

func process_fillLevel():
	if is_filling:
		percentFilled = $RigidBody2D/Area2D/AnimationPlayer.current_animation_position / $RigidBody2D/Area2D/AnimationPlayer.current_animation_length
		print(percentFilled)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	process_dnd()
	process_fillLevel()
	
func _on_area_2d_mouse_entered() -> void:
	draggable = true

func _on_area_2d_mouse_exited() -> void:
	if not dragging:
		draggable = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if (area.is_in_group("water-dispenser")):
		if percentFilled == 1.0:
			is_filling = false
			return
		is_filling = true
		$RigidBody2D/Area2D/AnimationPlayer.play("fill")
		$RigidBody2D/Area2D/AnimationPlayer.seek(percentFilled * $RigidBody2D/Area2D/AnimationPlayer.current_animation_length)
		$RigidBody2D/Area2D/AnimationPlayer.speed_scale = filling_speed
	
	elif (area.is_in_group("water-consumer")):
		$RigidBody2D/Area2D/AnimationPlayer.seek(0)
		$RigidBody2D/Area2D/AnimationPlayer.speed_scale = 2.3 / percentFilled
		$RigidBody2D/Area2D/AnimationPlayer.play("drain")
		
		area_to_fill = area
		percent_to_fill = percentFilled
		#Globals.fillWater.emit(area, percentFilled)
		percentFilled = 0.0


func _on_area_2d_area_exited(area: Area2D) -> void:
	if (area.is_in_group("water-dispenser")):
		is_filling = false
		$RigidBody2D/Area2D/AnimationPlayer.pause()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "drain":
		Globals.fillWater.emit(area_to_fill, percent_to_fill)
		area_to_fill = null
		percent_to_fill = 0.0
		pass # Replace with function body.
