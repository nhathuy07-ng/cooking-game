extends Node2D

# basic impl done: needs stirring, needs water, ruined
enum States { IDLE, NEEDS_INGREDIENTS, NEEDS_STIRRING, NEEDS_WATER, RUINED, DONE}
enum Action { IDLE, STIRRING }
enum Ingredients {CARROT, CHILLI, LEAF_ONION, MUSHROOM, POTATO, TOMATO}

# constants
const IDLE_TIMEOUT_MIN = 4
const IDLE_TIMEOUT_MAX = 7
const NEEDS_INGREDIENT_TIMEOUT_MIN = 7
const NEEDS_INGREDIENT_TIMEOUT_MAX = 12
const NEEDS_STIRRING_TIMEOUT_MIN = 10
const NEEDS_STIRRING_TIMEOUT_MAX = 15
const NEEDS_WATER_TIMEOUT_MIN = 10
const NEEDS_WATER_TIMEOUT_MAX = 13

var state = States.IDLE
var action = Action.IDLE

# stirring variables
var stirring_init = false
var stirring_progress = 0
var stirring_progress_reward = 2
var stirring_need_primary_key = true
var stirring_anim_scale = 6.0
var stirring_anim_scale_boost = 200
var stirring_anim_scale_max = 12.0
var stirring_anim_scale_decel = 10
var stirring_countdown_waittime = 20
var stirring_mouse_inside = false

# smoking status variable
var smoking_init = false
var smoking_countdown_waittime = 10
var water_required = 0.5
var water_fed = 0.0
const WATER_REQ_RANGE = Vector2(0.6, 2.0)

@export var slot: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.fillWater.connect(fill_water)
	Globals.forceStirringIdle.connect(_disable_stirring)
	

var actions_needs_performing = 0
var actions_performed = 0
var first_action_assigned = false

var lifecycle_mgmt_post_action_checked = false
func lifecycle_management_post_action_check():
	print("post action check for pot ", self)
	lifecycle_mgmt_post_action_checked = true
	
	if not first_action_assigned:
		return
		
	# TODO: run congrats anim here
	$Symbol.visible = true
	$Symbol/AnimatedSprite2D.animation = "default"
	$Symbol/AnimatedSprite2D.frame = 2
	# trigger idle clock again
	$LifecycleTimeoutClock.start()
	
	pass
	
var needs_ingredient_init_exec = false
var ingredient_needed: Ingredients

var init_done_lock = false
func init_done():
	if not init_done_lock:
		# TODO: Play some sparkle anims here
		Globals.dishesDone += 3
		Globals.checkSpawnEligibility.emit(Globals.dishesDone)
		$DestructionClock.start()
		init_done_lock = true

func ingredient_handling(ingredient: int, utensil: Area2D):
	if $StaticBody2D/Area2D == utensil and ingredient == ingredient_needed:
		state = States.IDLE
		actions_recorded = true
		Globals.sendIngredient.disconnect(ingredient_handling)
	
func needs_ingredient_init():
	if not needs_ingredient_init_exec:
		$Smoke.visible = false
		$Bubble.visible = false
		$Stir.visible = false
		ingredient_needed = randi_range(0, Ingredients.size() - 1)
		$Symbol.visible = true
		$Symbol/AnimatedSprite2D.scale = Vector2(0.275, 0.275)
		$Symbol/AnimatedSprite2D.animation = "ingredient"
		$Symbol/AnimatedSprite2D.frame = ingredient_needed
		
		needs_ingredient_init_exec = true
		print("needs ingr ", ingredient_needed)
		Globals.sendIngredient.connect(ingredient_handling)

func lifecycle_management_assign_action():
	print('assigning action')
	if (actions_needs_performing == 0):
		actions_needs_performing = randi_range(5, 7)
	
	# TODO: create ingredients and ingredient whitelist for stew type
	# if first task is not done AND is idle, assign needs_ingredient
	# if first task has been done: assign either needs_ingredient, needs_stirring, or needs_water
	# assign random time in allowed time range
	# assign random time for next idle timeout clock
	
	if actions_performed == 0:
		await get_tree().create_timer(0.2).timeout
		state = States.NEEDS_INGREDIENTS
	else:
		var _rnd = randf_range(1, 10)
		if 1.0 <= _rnd and _rnd <= 3.0 :
			state = States.NEEDS_STIRRING
			stirring_countdown_waittime = randi_range(NEEDS_STIRRING_TIMEOUT_MIN, NEEDS_STIRRING_TIMEOUT_MAX)
		elif 3.0 < _rnd and _rnd <= 7.0:
			state = States.NEEDS_WATER
			smoking_countdown_waittime = randi_range(NEEDS_STIRRING_TIMEOUT_MIN, NEEDS_STIRRING_TIMEOUT_MAX)
		elif 7.0 < _rnd and _rnd == 10.0:
			state = States.NEEDS_INGREDIENTS # (add later)
			# this -> allow indef time
	
	# RNG idle time for next round
	$LifecycleTimeoutClock.stop()
	$LifecycleTimeoutClock.wait_time = randi_range(IDLE_TIMEOUT_MIN, IDLE_TIMEOUT_MAX)
	
	first_action_assigned = true
	lifecycle_mgmt_post_action_checked = false
	print('state', state)
	pass

func fill_water(area: Area2D, qty: float):
	if (area == $StaticBody2D/Area2D):
		water_fed += qty

func init_stirring():
	if not stirring_init:
		
		$StirHints.visible = true
		$Symbol/AnimatedSprite2D.animation = "default"
		$Stir/AnimationPlayer.speed_scale = stirring_anim_scale
		$Stir/AnimationPlayer.seek(0)
		$Stir/AnimationPlayer.play("stirring")
		$StirringCountdown.wait_time = stirring_countdown_waittime
		$StirringCountdown.start()
		
		$Symbol.visible = true
		$Symbol/AnimatedSprite2D.frame = 0
		
		stirring_progress = 0
		stirring_init = true

var actions_recorded = false
func proc_stirring(delta: float):
	if action != Action.STIRRING:
		#stirring_anim_scale = max(0, stirring_anim_scale - stirring_anim_scale_decel * 2 * delta)
		pass
	
	else:
		
		$StirHints/StirProgBar.value = stirring_progress 
		
		if stirring_need_primary_key:
			$StirHints/PrimKeyHint.frame = 0
			$StirHints/SecKeyHint.frame = 1
			if Input.is_action_just_pressed("stir_primary") or (stirring_mouse_inside and Input.is_action_just_pressed("m_left", false)):
				stirring_anim_scale += stirring_anim_scale_boost * delta
				stirring_progress += stirring_progress_reward
				stirring_need_primary_key = not stirring_need_primary_key
				print(stirring_progress)
		else:
			$StirHints/PrimKeyHint.frame = 1
			$StirHints/SecKeyHint.frame = 0
			if Input.is_action_just_pressed("stir_secondary") or (stirring_mouse_inside and Input.is_action_just_pressed("m_right", false)):
				
				stirring_anim_scale += stirring_anim_scale_boost * delta
				
				stirring_progress += stirring_progress_reward
				stirring_need_primary_key = not stirring_need_primary_key
				print(stirring_progress)
	
			
	stirring_anim_scale = max(0, stirring_anim_scale - stirring_anim_scale_decel * delta)
	stirring_anim_scale = min(stirring_anim_scale, stirring_anim_scale_max)
	
	#print(stirring_anim_scale)
	$Stir/AnimationPlayer.speed_scale = stirring_anim_scale
	
	if stirring_progress >= 100:
		$StirringCountdown.stop()
		$Stir/AnimationPlayer.speed_scale = 0
		state = States.IDLE
		
		if not actions_recorded:
			actions_recorded = true
			actions_performed += 1

func init_smoke():
	if smoking_init == false:
		
		$Symbol.visible = true
		$Symbol/AnimatedSprite2D.animation = "default"
		$Symbol/AnimatedSprite2D.frame = 1
		
		$Stir.visible = false
		$Smoke.visible = true
		$SmokeCountdown.wait_time = smoking_countdown_waittime
		$SmokeCountdown.start()
		water_required = randf_range(WATER_REQ_RANGE.x, WATER_REQ_RANGE.y)
		water_fed = 0.0
		smoking_init = true

func proc_smoke():
	if water_fed >= water_required:
		$SmokeCountdown.stop()
		state = States.IDLE
		if not actions_recorded:
			actions_recorded = true
			actions_performed += 1

var ruin_init = false
func init_ruined():
	if not ruin_init:
		
		Globals.potRemaining -= 1
		
		# TODO: Implement ruined anims and penalties here
		$Stir.visible = false
		$Bubble.visible = false
		$Smoke.visible = false
		$RuinedAnim/AnimationPlayer.play("ruined")
		ruin_init = true
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
	print(actions_recorded)
	actions_recorded = false
	
	if actions_performed >= actions_needs_performing:
		state = States.DONE
	
	$StirHints.visible = false
	$Stir.visible = false
	$Bubble.visible = false
	$Smoke.visible = false
	
	$Symbol.visible = false
	$Symbol/AnimatedSprite2D.scale = Vector2(0.087, 0.087)
	
	smoking_init = false
	stirring_init = false
	
	if not lifecycle_mgmt_post_action_checked:
		lifecycle_management_post_action_check()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if state == States.DONE:
		init_done()
	
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
	elif state == States.NEEDS_INGREDIENTS:
		needs_ingredient_init()
		
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton) and event.pressed:
		if state == States.NEEDS_STIRRING:
			action = Action.STIRRING
			Globals.forceStirringIdle.emit(self)
	pass # Replace with function body.

func _disable_stirring(exceptForPot: Node2D):
	if self != exceptForPot:
		action = Action.IDLE

func _on_area_2d_mouse_entered() -> void:
	stirring_mouse_inside = true
	pass # Replace with function body.


func _on_area_2d_mouse_exited() -> void:
	stirring_mouse_inside = false
	pass # Replace with function body.


func _on_lifecycle_timeout_clock_timeout() -> void:
	lifecycle_management_assign_action()
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "ruined"):
		$DestructionClock.start()
		


func _on_destruction_clock_timeout() -> void:
	Globals.freeSlot.emit(slot)
	queue_free()
	pass # Replace with function body.
