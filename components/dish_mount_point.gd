extends Node2D

@export var num_dish_served: int
var spawn_unlocked = false
var first_spawn = true
var spawn_timer = Timer.new()

var Pan: PackedScene
var Pot: PackedScene

func unlock_spawn(c: int):
	print(c, num_dish_served)
	if not spawn_unlocked:
		if c >= num_dish_served:
			spawn_unlocked = true
		
			if first_spawn:
				spawn_new_utensil()
				first_spawn = false
			spawn_unlocked = true

func spawn_new_utensil():
	print("spawn")
	if randi_range(1, 6) <= 3:
		# pan
		var _pan = Pan.instantiate()
		_pan.global_position = $PanMount.global_position
		get_tree().current_scene.add_child.call_deferred(_pan)
		
	else:
		var _pot = Pot.instantiate()
		_pot.global_position = self.global_position
		get_tree().current_scene.add_child.call_deferred(_pot)
		
		
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("rack ready")
	Pan = ResourceLoader.load("res://components/pan.tscn")
	Pot = ResourceLoader.load("res://components/pot.tscn")
	Globals.checkSpawnEligibility.connect(unlock_spawn)
	unlock_spawn(Globals.dishesDone)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
