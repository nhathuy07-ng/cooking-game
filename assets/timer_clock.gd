extends Node2D

enum States {STOP, RUNNING}
var state = States.RUNNING
var running_init = false
var stop_init = false

@export var wait_time = 10;

func start_clock():
	state = States.RUNNING

func reset_clock():
	state = States.STOP

func init_stop():
	pass

func init_run():
	stop_init = false
	if not running_init:
		running_init = true
		$Timer.wait_time = wait_time
		$AnimationPlayer.speed_scale = 1 / wait_time
		
		$AnimationPlayer.seek(0)
		$AnimationPlayer.play("clock_hand_rotate")
		$Timer.start()
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = wait_time
	$AnimationPlayer.speed_scale = 1.0 / wait_time
	print(1.0/ wait_time)
	$AnimationPlayer.seek(0)
	$AnimationPlayer.play("clock_hand_rotate")
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if state == States.RUNNING:
		#init_run()
	pass
