extends Node2D

enum States { IDLE, NEEDS_FLIPPING, NEEDS_INGREDIENTS, DONE, RUINED }

# idle states
var idle_inited = false
var state = States.NEEDS_FLIPPING

# flipping state
var flipping_countdown_waittime = 10
var flipping_inited = false

# ruined state
var ruined_init = false

func init_ruined():
	if not ruined_init:
		print("pan ruined")
		$Node2D/Area2D/FlipMeter.needs_flipping = false
		ruined_init = true

func init_idle():
	pass

func idle_proc():
	flipping_inited = false
	$Node2D/Area2D/Smoke.visible = false
	$Node2D/Area2D/FlipMeter.state = $Node2D/Area2D/FlipMeter.FlipStates.IDLE
	$Node2D/Area2D/FlipMeter.needs_flipping = false

func flipping_init():
	if not flipping_inited:
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
	$Node2D/Area2D/FlipMeter.report_successful_flip.connect(successful_flip)
	$Node2D/Area2D/FlipMeter.report_unsuccessful_flip.connect(unsuccessful_flip)

func successful_flip():
	$Node2D/Area2D/AnimationPlayer.play("flipping")
	$FlippingCountdown.stop()
	state = States.IDLE
	pass
	
func unsuccessful_flip(u: Variant ):
	if u == $Node2D/Area2D/FlipMeter.UnsuccessfulState.TOO_LOW:
		$Node2D/Area2D/AnimationPlayer.play("flipping_too_low")
	else:
		$Node2D/Area2D/AnimationPlayer.play("flipping_too_far")
		$FlippingCountdown.stop()
		state = States.RUINED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if state == States.IDLE:
		init_idle()
		idle_proc()
	elif state == States.NEEDS_FLIPPING:
		flipping_init()
		flipping_proc()
	elif state == States.RUINED:
		init_ruined()
	
	pass # Replace with function body.


func _on_flipping_countdown_timeout() -> void:
	state = States.RUINED
