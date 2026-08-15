extends Node2D

enum States { IDLE, NEEDS_FLIPPING, DONE, RUINED }

# idle states
var idle_inited = false
var state = States.IDLE

# flipping state
var flipping_countdown_waittime = 10
var flipping_inited = false

# ruined state
var ruined_init = false

# free-falling settings
var freefall_scale = 1.9
var is_freefalling = false
var freefalling_vel = -1000 * freefall_scale
var freefalling_accel = 900 * freefall_scale
var freefalling_accel_phase_2 = 1900 * freefall_scale
var deathzone = 3000

var FLIPPING_SPEED_MIN = 300
var FLIPPING_SPEED_MAX = 550
var FLIPPING_SAFEZONE_SCALE_MIN = 0.4
var FLIPPING_SAFEZONE_SCALE_MAX = 1.2
var IDLE_TIMEOUT_MIN = 5
var IDLE_TIMEOUT_MAX = 8

var flips_done = 0
const TARGET_MIN = 3
const TARGET_MAX = 5
var target = 0
@export var slot: Node2D

func lifecycle_proc():
	if state != States.RUINED:
		$IdleTimer.stop()
		$IdleTimer.wait_time = randf_range(IDLE_TIMEOUT_MIN, IDLE_TIMEOUT_MAX)
		state = States.NEEDS_FLIPPING

var hp_removed = false
func freefall_proc(delta: float):
	if not is_freefalling:
		return
	
	global_position.y += freefalling_vel * delta	
	
	if freefalling_vel < 0:
		freefalling_vel += freefalling_accel * delta
	else:
		freefalling_vel += freefalling_accel_phase_2 * delta
	
	if global_position.y > deathzone:
		Globals.freeSlot.emit(slot)
		if _curclock:
			_curclock.queue_free()
			_curclock = null
		queue_free()
	
	if not hp_removed:
		hp_removed = true
		Globals.panRemaining -= 1
		

	pass

func init_ruined():

	if not ruined_init:
		if _curclock:
			_curclock.queue_free()
			_curclock = null
		Globals.panRemaining -= 1
		print("pan ruined")
		$Node2D/Area2D/FlipMeter.needs_flipping = false
		ruined_init = true
		
		$Node2D/Area2D/Smoke.visible = false
		$Node2D/Area2D/RuinedAnim.visible = true
		$Node2D/Area2D/AnimationPlayer.play("ruined")
		
		$DestructionCountdown.start()
		
func init_idle():
	pass

func idle_proc():
	$Hint.visible = false
	flipping_inited = false
	$Node2D/Area2D/Smoke.visible = false
	$Node2D/Area2D/FlipMeter.state = $Node2D/Area2D/FlipMeter.FlipStates.IDLE
	$Node2D/Area2D/FlipMeter.needs_flipping = false

var _curclock = null
func flipping_init():
	if not flipping_inited:
		
		_curclock = ResourceLoader.load("res://assets/timer-clock.tscn").instantiate()
		
		_curclock.global_position = $mp.global_position
		_curclock.scale = Vector2(0.45, 0.45)
		
		get_tree().current_scene.add_child(_curclock)
		
		$Hint.visible = true 
		$Node2D/Area2D/FlipMeter.speed = randf_range(FLIPPING_SPEED_MIN, FLIPPING_SPEED_MAX)
		$Node2D/Area2D/FlipMeter.safezone_scale = randf_range(FLIPPING_SAFEZONE_SCALE_MIN, FLIPPING_SAFEZONE_SCALE_MAX)
		
		$Node2D/Area2D/Smoke.visible = true
		$Node2D/Area2D/FlipMeter.state = States.IDLE
		$Node2D/Area2D/FlipMeter.needs_flipping = true
		
		$FlippingCountdown.wait_time = flipping_countdown_waittime
		$FlippingCountdown.start()
		flipping_inited = true

func flipping_proc():
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = randi_range(TARGET_MIN, TARGET_MAX)
	$Node2D/Area2D/FlipMeter.report_successful_flip.connect(successful_flip)
	$Node2D/Area2D/FlipMeter.report_unsuccessful_flip.connect(unsuccessful_flip)

func progress_check():
	flips_done += 1
	if flips_done >= target:
		state = States.DONE

func successful_flip():
	if _curclock:
		_curclock.queue_free()
		_curclock = null
	$Node2D/Area2D/AnimationPlayer.play("flipping")
	$FlippingCountdown.stop()
	state = States.IDLE
	$IdleTimer.start()
	
	progress_check()
	
	pass
	
func unsuccessful_flip(u: Variant ):
	
	if u == $Node2D/Area2D/FlipMeter.UnsuccessfulState.TOO_LOW:
		$Hint.visible = false
		$Node2D/Area2D/AnimationPlayer.play("flipping_too_low")
	else:
		$Hint.visible = false
		$Node2D/Area2D/AnimationPlayer.play("flipping_too_far")
		$FlippingCountdown.stop()
		

var init_done_lock = false
func init_done():
	if _curclock:
		_curclock.queue_free()
		_curclock = null
	# TODO: Play some sparkle anims here
	if not init_done_lock:
		Globals.dishesDone += 2
		Globals.checkSpawnEligibility.emit(Globals.dishesDone)
		$DestructionCountdown.start()
		init_done_lock = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if is_freefalling:
		freefall_proc(delta)
	
	if state == States.IDLE:
		init_idle()
		idle_proc()
	elif state == States.NEEDS_FLIPPING:
		flipping_init()
		flipping_proc()
	elif state == States.RUINED:
		init_ruined()
	elif state == States.DONE:
		init_done()
	
	pass # Replace with function body.


func _on_flipping_countdown_timeout() -> void:
	state = States.RUINED


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "flipping_too_far":
		$Hint.visible = false
		$Node2D/Area2D/AnimationPlayer.play("flipping_too_far_loop_v2")
		is_freefalling = true
	elif anim_name == "flipping_too_low":
		$Hint.visible = true
	pass # Replace with function body.


func _on_destruction_countdown_timeout() -> void:
	Globals.freeSlot.emit(slot)
	if _curclock:
		_curclock.queue_free()
		_curclock = null
	queue_free()
	
	pass # Replace with function body.


func _on_idle_timer_timeout() -> void:
	lifecycle_proc()
	pass # Replace with function body.
