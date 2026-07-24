extends Node

signal fillWater(areaFilled: Area2D, qty: float)
signal forceStirringIdle(exceptForPot: Node2D)
signal deactivateFillMeterExcept(fillMeter: Node2D)
signal checkSpawnEligibility(dishesDone: int)

const maxDishes = 1000
var dishesDone = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("autoload ready")
	checkSpawnEligibility.emit(dishesDone)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
