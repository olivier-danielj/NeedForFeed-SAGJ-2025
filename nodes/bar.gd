extends Node2D

@export var need : Need.Type = Need.Type.HUNGRY
@export var bar_max = 100
@export var bar_min = 0
@export var bar_warn = 50

signal full(type: Need.Type)
signal warn(type: Need.Type)

var flag_warned : bool = false

# Sprites
const SPR_HUNGRY = preload("res://sprites/bars/hungry.png")
const SPR_HUNGRY_BEHIND = preload("res://sprites/bars/hungry behind.png")

const SPR_BORED = preload("res://sprites/bars/bored.png")
const SPR_BORED_BEHIND = preload("res://sprites/bars/bored behind.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Display.min_value = bar_min
	$Display.max_value = bar_max
	set_sprite()

# Set bar's display sprites based on selected type
func set_sprite():
	match need:
		Need.Type.HUNGRY:
			$Display.texture_progress = SPR_HUNGRY
			$Display.texture_under = SPR_HUNGRY_BEHIND
		Need.Type.BORED:
			$Display.texture_progress = SPR_BORED
			$Display.texture_under = SPR_BORED_BEHIND

func _on_display_value_changed(value):
	if value >= bar_max:
		full.emit(need)
		return
	if value > bar_warn:
		warn.emit(need)
		return
