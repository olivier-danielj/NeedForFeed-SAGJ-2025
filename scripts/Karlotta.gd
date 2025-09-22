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

var feeling = {
	Need.Type.HUNGRY: Need.Action.CALM,
	Need.Type.BORED: Need.Action.CALM,
	Need.Type.EEP: Need.Action.CALM,
}

var state : STATES = STATES.IDLE

signal sleeping
signal awake

# Catch need signals

func _on_warn(type):
	feel(type, Need.Action.WARN)

func _on_calm(type):
	feel(type, Need.Action.CALM)
	
func _on_panic(type):
	feel(type, Need.Action.PANIC)
	
func _on_meltdown(type):
	if type == Need.Type.LOVE:
		get_tree().change_scene_to_file("res://scenes/win.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/lose.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	update_state()

func feel(dt : Need.Type, dx : Need.Action): 
	feeling[dt] = dx
	update_state()

func isCalm(dt : Need.Type) -> bool: return not (isWarn(dt) or isPanic(dt))
func isWarn(dt : Need.Type) -> bool: return feeling[dt] == Need.Action.WARN
func isPanic(dt : Need.Type) -> bool: return feeling[dt] == Need.Action.PANIC

func update_state():
	var a = state
	transition()
	var b = state
	if isWoke(a, b):
		awake.emit()
		$Meow.play()
	update_sprite()

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

var priorities: Array[Need.Type] = [Need.Type.EEP, Need.Type.HUNGRY, Need.Type.BORED]

func next(dt : Need.Type) -> STATES:
	match dt:
		Need.Type.HUNGRY:
			if isCalm(dt): 
				$Meow.stream = preload("res://audio/cat/Cat Lick 01 .wav")
				$Meow.play()
				return STATES.IDLE
			if isWarn(dt): 
				$Meow.stream = preload("res://audio/cat/Cat Meow Short 08 .wav")
				$Meow.play()
				return STATES.HUNGRY
			if isPanic(dt): 
				$Meow.stream = preload("res://audio/cat/Cat Groan 13 .wav")
				$Meow.play()
				return STATES.HANGRY
		Need.Type.BORED:
			if isCalm(dt): return STATES.IDLE
			if isWarn(dt): 
				$Meow.stream = preload("res://audio/cat/Cat Trill 10 .wav")
				$Meow.play()
				return STATES.BORED
			if isPanic(dt): 
				$Meow.stream = preload("res://audio/cat/Cat Groan 13 .wav")
				$Meow.play()
				return STATES.EVIL
		Need.Type.EEP:
			if isCalm(dt): return STATES.IDLE
			if isWarn(dt):
				if state != STATES.SLEEPY:
					$Meow.stream = preload("res://audio/cat/Cat Trill 10 .wav")
					$Meow.play()
				return STATES.SLEEPY
			if isPanic(dt):
				sleeping.emit()
				return STATES.SLEEPING
	return STATES.IDLE

func isWoke(a, b : STATES):
	if a != STATES.SLEEPING: 
		return false
	else:
		return a != b

func transition():
	for p in priorities:
		if next(p) != STATES.IDLE:
			state = next(p)
			return
	state = STATES.IDLE
