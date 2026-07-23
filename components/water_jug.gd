extends Node2D

var dragging := false
var draggable := false
var percentFilled := 0.0
var init_position = Vector2.ZERO
var filling_speed = 1
var is_filling = false

func process_dnd():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and draggable:
		dragging = true
	else:
		dragging = false
		
	if dragging:
		global_position = get_global_mouse_position()

func process_fillLevel():
	if is_filling:
		percentFilled = $Area2D/AnimationPlayer.current_animation_position / $Area2D/AnimationPlayer.current_animation_length
		print(percentFilled)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
		$Area2D/AnimationPlayer.play("fill")
		$Area2D/AnimationPlayer.seek(percentFilled * $Area2D/AnimationPlayer.current_animation_length)
		$Area2D/AnimationPlayer.speed_scale = filling_speed
	
	elif (area.is_in_group("water-consumer")):
		$Area2D/AnimationPlayer.seek(0)
		$Area2D/AnimationPlayer.speed_scale = 2.3 / percentFilled
		$Area2D/AnimationPlayer.play("drain")
		
		Globals.fillWater.emit(area, percentFilled)
		percentFilled = 0.0


func _on_area_2d_area_exited(area: Area2D) -> void:
	if (area.is_in_group("water-dispenser")):
		is_filling = false
		$Area2D/AnimationPlayer.pause()
