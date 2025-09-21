extends Node

enum STATES {
	# General
	IDLE, 
	
	# Food
	HUNGRY,
	HANGRY,
	EATING,
	POOPING,
	
	# Play
	BORED,
	EVIL,
	
	# Energy
	SLEEPY,
	SLEEPING,
}

var isPanic : bool = false
var state : STATES = STATES.IDLE

signal sleeping

# Catch need signals

func _on_warn(type):
	update_state(type, Need.Action.WARN)

func _on_calm(type):
	update_state(type, Need.Action.CALM)
	
func _on_panic(type):
	isPanic = true
	update_state(type, Need.Action.PANIC)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_button_button_down():
	$Sprite.texture = preload("res://sprites/karlotta/sniffs.png")

func _on_button_button_up():
	$Sprite.texture = preload("res://sprites/karlotta/stance.png")

func update_state(dt : Need.Type, dx : Need.Action):
	match state:
		STATES.IDLE: 
			idle.call(dt, dx)
		STATES.HUNGRY, STATES.HANGRY: 
			hungry.call(dt, dx)
		STATES.BORED, STATES.EVIL: 
			bored.call(dt, dx)
		STATES.SLEEPY:
			sleep.call(dt, dx)
		STATES.SLEEPING:
			bedjie.call(dt, dx)
	update_sprite()
	return

const spr_idle = preload("res://sprites/karlotta/sit.png")
const spr_hungry = preload("res://sprites/karlotta/lick.png")
const spr_hangry = preload("res://sprites/karlotta/sniffs.png")
const spr_eating = preload("res://sprites/karlotta/happy.png")
const spr_bored = preload("res://sprites/karlotta/curious.png")
const spr_evil = preload("res://sprites/karlotta/slap r.png")
const spr_sleepy = preload("res://sprites/karlotta/loaf.png")
const spr_sleeping = preload("res://sprites/karlotta/curl.png")

func update_sprite():
	var s = spr_idle
	match state:
		STATES.IDLE: $Sprite.texture = spr_idle
		STATES.HUNGRY: $Sprite.texture = spr_hungry
		STATES.HANGRY: $Sprite.texture = spr_hangry
		STATES.EATING: $Sprite.texture = spr_eating
		STATES.BORED: $Sprite.texture = spr_bored
		STATES.EVIL: $Sprite.texture = spr_evil
		STATES.SLEEPY: $Sprite.texture = spr_sleepy
		STATES.SLEEPING: $Sprite.texture = spr_sleeping

# Idle can bounce to hungry or bored based on needs
var idle: Callable = func(dt : Need.Type, dx : Need.Action):
	if dx != Need.Action.WARN:
		return
	match dt:
		Need.Type.HUNGRY:
			state = STATES.HUNGRY
		Need.Type.BORED:
			state = STATES.BORED
		Need.Type.EEP:
			state = STATES.SLEEPY

# State transitions

var hungry: Callable = func(dt : Need.Type, dx : Need.Action):
	if dt != Need.Type.HUNGRY:
		return # ignore all other needs
	match dx:
		Need.Action.CALM:
			state = STATES.IDLE
		Need.Action.PANIC:
			state = STATES.HANGRY
	return

var bored: Callable = func(dt : Need.Type, dx : Need.Action):
	match dx:
		Need.Action.CALM:
			if dt == Need.Type.BORED:
				state = STATES.IDLE
		Need.Action.WARN:
			match dt:  # Swap to priorities
				Need.Type.HUNGRY: 
					state = STATES.HUNGRY
				Need.Type.EEP: 
					state = STATES.SLEEPY
		Need.Action.PANIC:
			state = STATES.EVIL

var sleep: Callable = func(dt : Need.Type, dx : Need.Action):
	match dx:
		Need.Action.CALM:
			if dt == Need.Type.EEP:
				state = STATES.IDLE
		Need.Action.WARN:
			match dt:  # Swap to priorities
				Need.Type.HUNGRY: 
					state = STATES.HUNGRY
		Need.Action.PANIC:
			sleeping.emit()
			state = STATES.SLEEPING

var bedjie: Callable = func(dt : Need.Type, dx : Need.Action):
	if dt == Need.Type.EEP and dx == Need.Action.CALM:
		state = STATES.IDLE

# TODO - Store next state and revert to it after calm instead of just idle

# TODO - Fix bug where sleeping means you never need to sleep again?
