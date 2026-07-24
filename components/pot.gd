extends Node2D

# basic impl done: needs stirring, needs water, ruined
enum States { IDLE, NEEDS_INGREDIENTS, NEEDS_STIRRING, NEEDS_HEAT_REDUCTION, NEEDS_WATER, RUINED, DONE}
enum Action { IDLE, STIRRING }

var state = States.NEEDS_WATER
var action = Action.IDLE

# stirring variables
var stirring_init = false
var stirring_progress = 0
var stirring_progress_reward = 2
var stirring_need_primary_key = true
var stirring_anim_scale = 0.0
var stirring_anim_scale_boost = 200
var stirring_anim_scale_max = 6.0
var stirring_anim_scale_decel = 10
var stirring_countdown_waittime = 20

# smoking status variable
var smoking_init = false
var smoking_countdown_waittime = 10
const water_required = 0.5
var water_fed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.fillWater.connect(fill_water)
	Globals.forceStirringIdle.connect(_disable_stirring)

func fill_water(area: Area2D, qty: float):
	if (area == $StaticBody2D/Area2D):
		water_fed += qty

func init_stirring():
	if not stirring_init:
		$Stir/AnimationPlayer.speed_scale = stirring_anim_scale
		$Stir/AnimationPlayer.seek(0)
		$Stir/AnimationPlayer.play("stirring")
		$StirringCountdown.wait_time = stirring_countdown_waittime
		$StirringCountdown.start()
		
		stirring_progress = 0
		stirring_init = true

func proc_stirring(delta: float):
	if action != Action.STIRRING:
		return
	
	if stirring_need_primary_key:
		if Input.is_action_just_pressed("stir_primary"):
			stirring_anim_scale += stirring_anim_scale_boost * delta
			stirring_progress += stirring_progress_reward
			stirring_need_primary_key = not stirring_need_primary_key
			print(stirring_progress)
	else:
		if Input.is_action_just_pressed("stir_secondary"):
			
			stirring_anim_scale += stirring_anim_scale_boost * delta
			
			stirring_progress += stirring_progress_reward
			stirring_need_primary_key = not stirring_need_primary_key
			print(stirring_progress)
	
	stirring_anim_scale = min(stirring_anim_scale, stirring_anim_scale_max)
	stirring_anim_scale = max(0, stirring_anim_scale - stirring_anim_scale_decel * delta)
	#print(stirring_anim_scale)
	$Stir/AnimationPlayer.speed_scale = stirring_anim_scale
	
	if stirring_progress >= 100:
		$StirringCountdown.stop()
		state = States.IDLE

func init_smoke():
	if smoking_init == false:
		$Smoke.visible = true
		$SmokeCountdown.wait_time = smoking_countdown_waittime
		$SmokeCountdown.start()
		water_fed = 0.0
		smoking_init = true

func proc_smoke():
	if water_fed >= water_required:
		$SmokeCountdown.stop()
		state = States.IDLE

func init_ruined():
	# TODO: Implement ruined anims and penalties here
	$Stir.visible = false
	$Bubble.visible = false
	$Smoke.visible = false
	pass

func stirring_failed():
	print("stirring failed!")
	$StirringCountdown.stop()
	state = States.RUINED
	pass
	
func watering_failed():
	print("Watering failed")
	$SmokeCountdown.stop()
	state = States.RUINED
	pass

func proc_idle(delta: float):
	$Stir.visible = false
	$Bubble.visible = false
	$Smoke.visible = false
	smoking_init = false
	stirring_init = false	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == States.IDLE:
		proc_idle(delta)
	elif state == States.NEEDS_STIRRING:
		$Stir.visible = false
		$Stir.visible = true
		init_stirring()
		proc_stirring(delta)
	elif state == States.RUINED:
		init_ruined()
	elif state == States.NEEDS_WATER:
		init_smoke()
		proc_smoke()
		
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton) and event.pressed:
		if state == States.NEEDS_STIRRING:
			action = Action.STIRRING
			Globals.forceStirringIdle.emit(self)
	pass # Replace with function body.

func _disable_stirring(exceptForPot: Node2D):
	if self != exceptForPot:
		action = Action.IDLE
