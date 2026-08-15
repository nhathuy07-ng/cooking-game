extends Node

signal fillWater(areaFilled: Area2D, qty: float)
signal forceStirringIdle(exceptForPot: Node2D)
signal deactivateFillMeterExcept(fillMeter: Node2D)
signal checkSpawnEligibility(dishesDone: int)
signal assignSlot(mount: Node2D, utensil: Node2D)
signal freeSlot(mount: Node2D)
signal sendIngredient(ingredient: int, utensil_area: Area2D)

const maxDishes = 1000
var dishesDone = 0
var potRemaining = 5
var panRemaining = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("autoload ready")
	checkSpawnEligibility.emit(dishesDone)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
