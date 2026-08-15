extends Node2D

@export var panAnimationPlayer: AnimationPlayer

enum FlipStates { IDLE, MOVING, RESET, RETRY }
enum UnsuccessfulState {TOO_LOW, TOO_HIGH}

var direction = 1
@export var speed = 300
@export var safezone_scale = 0.7
@export var needs_flipping = false
@export var state = FlipStates.IDLE
var within_safezone = false
var mouse_inside = false
var click_prevent = false

signal report_successful_flip()
signal report_unsuccessful_flip(s: Variant)

func reset():
	position.x = 0
	$Pointer.position.x = 0
	$Safezone.scale.x = safezone_scale
	var safezone_width = $Safezone.scale.x * $Safezone.texture.get_width()
	
	# avoid pointer init pos
	if randi_range(0, 1) == 0:
		$Safezone.position.x = randi_range($LeftBound/CollisionShape2D.position.x + 10 + safezone_width / 2, 0 - safezone_width)
	else:
		$Safezone.position.x = randi_range(safezone_width, $RightBound/CollisionShape2D.position.x - 10 - safezone_width / 2)
	pass

func activate():
	state = FlipStates.MOVING

func deactivate():
	state = FlipStates.IDLE

func deactivate_except(target: Node2D):
	if target != self:
		state = FlipStates.IDLE

func meter_idle_proc(delta: float):
	self.visible = false

func safezone_hit():
	print("safezone hit on ", self)
	report_successful_flip.emit()
	state = FlipStates.RESET

func safezone_miss():
	# check too high or too low
	# if to the left of safezone: too high
	# if to the right: too low
	
	if $Pointer.position.x < $Safezone.position.x:
		print("too low")
		report_unsuccessful_flip.emit(UnsuccessfulState.TOO_LOW)
		state = FlipStates.RETRY
	else:
		report_unsuccessful_flip.emit(UnsuccessfulState.TOO_HIGH)
		print("too high")
		state = FlipStates.RESET
	

func safezone_reset():
	self.visible = false
	reset()
	state = FlipStates.IDLE
	
func retry():
	self.visible = false 
	if not panAnimationPlayer.is_playing():
		reset()
		state = FlipStates.MOVING

func meter_proc(delta: float):
	
	if !needs_flipping:
		state = FlipStates.IDLE
	
	self.visible = true
	if state == FlipStates.MOVING:
		$Pointer.position.x += speed * delta * direction
		
		if Input.is_action_just_pressed("flip_meter_accept") or mouse_inside and not click_prevent and (Input.is_action_just_pressed("m_left") or Input.is_action_just_pressed("m_right")):
			if within_safezone:
				safezone_hit()
			else:
				safezone_miss()
		

func revert():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.deactivateFillMeterExcept.connect(deactivate_except)
	reset()
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if state == FlipStates.MOVING:
		meter_proc(delta)
	elif state == FlipStates.RESET:
		safezone_reset()
	elif state == FlipStates.RETRY:
		retry()
	else:
		meter_idle_proc(delta)
		
func _process(delta: float):
	pass

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("bound"):
		direction = -direction
		return
	
	if area.is_in_group("safezone"):
		within_safezone = true
		return

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton) and event.pressed and needs_flipping and state == FlipStates.IDLE:
		activate()
		Globals.deactivateFillMeterExcept.emit(self)
		# add a click buffer here
		click_prevent = true
		$ClickPreventCountdown.start()
		

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("safezone"):
		within_safezone = false


func _on_area_2d_mouse_entered() -> void:
	mouse_inside = true
	pass # Replace with function body.


func _on_area_2d_mouse_exited() -> void:
	mouse_inside = false
	
	pass # Replace with function body.


func _on_click_prevent_countdown_timeout() -> void:
	click_prevent = false
	pass # Replace with function body.
