extends Node

# Example of game-wide variables
var score = 0
var player_lives = 3
var _score_label: Label
var _mass_label: Label
var _speed_label: Label


enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }
var current_state = GameState.MENU


func change_state(new_state: GameState):
	current_state = new_state

func reset_game():
	score = 0
	player_lives = 3
	change_state(GameState.MENU)

func add_score(points: int):
	score += points
	_score_label.text = str(score)

func change_mass_label(new_mass: float):
	_mass_label.text = str(int(new_mass))

func change_speed_label(new_speed: float):
	_speed_label.text = str(int(new_speed))

func _init_labels(score_label: Label, mass_label: Label, speed_label: Label):
	_score_label = score_label
	_mass_label = mass_label
	_speed_label = speed_label

