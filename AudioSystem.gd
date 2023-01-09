extends Node

var scale_key_ratios = {
	# major keys
	"C major": [1.0, 1.12, 1.26, 1.33, 1.5, 1.68, 1.89], # bright and cheerful
	"G major": [1.0, 1.12, 1.24, 1.5, 1.68, 1.8, 2.0], # bright and joyful
	"D major": [1.0, 1.14, 1.26, 1.5, 1.61, 1.78, 2.0], # happy and energetic
	"A major": [1.0, 1.12, 1.25, 1.5, 1.67, 1.87, 2.0], # happy and triumphant
	"E major": [1.0, 1.12, 1.25, 1.5, 1.67, 1.84, 2.0], # bright and optimistic
	"B major": [1.0, 1.12, 1.25, 1.5, 1.64, 1.87, 2.0], # cheerful and uplifting
	"F# major": [1.0, 1.12, 1.25, 1.5, 1.62, 1.87, 2.0], # happy and playful
	"C# major": [1.0, 1.12, 1.25, 1.5, 1.61, 1.87, 2.0], # bright and cheerful
	# minor keys
	"A minor": [1.0, 1.12, 1.24, 1.36, 1.5, 1.68, 1.8], # sad and emotional
	"E minor": [1.0, 1.12, 1.24, 1.36, 1.5, 1.64, 1.8], # sad and introspective
	#"B minor": [1.0, 1.12, 1.
	"F# minor": [1.0, 1.12, 1.24, 1.36, 1.5, 1.61, 1.8], # sad and melancholy
	"C# minor": [1.0, 1.12, 1.24, 1.36, 1.5, 1.61, 1.78], # sad and introspective
	"G# minor": [1.0, 1.12, 1.24, 1.36, 1.5, 1.61, 1.76], # sad and poignant
	"D# minor": [1.0, 1.12, 1.24, 1.36, 1.5, 1.61, 1.74], # sad and mournful
	"A# minor": [1.0, 1.12, 1.24, 1.36, 1.5, 1.61, 1.68], # sad and introspective
}

# Minor key ratios
var minor_scale = [1.0, 1.122, 1.189, 1.335, 1.498, 1.682, 1.89]

# Sample chords in minor key
var minor_chords = [
	[0, 3, 7], # tonic chord
	[2, 5, 9], # ii chord
	[3, 6, 10], # iii chord
	[5, 8, 12], # iv chord
	[7, 11, 14], # v chord
	[8, 12, 15], # vi chord
	[10, 13, 17] # vii chord
]

var time_at_last_beat : float = 0.0
var time_at_last_bar : float = 0.0

signal pulse_beat()


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.audio_manager = self

func subscribe_to_pulse_beat(listenerNode, callbackFunction):
	# nodes which need precise timing for audio events can subscribe to the audio_manager to receive timed signals
	connect("pulse_beat", listenerNode, callbackFunction)

func unsubscribe(uninterestedListenerNode, callbackFunction):
	if is_connected("pulse_beat", uninterestedListenerNode, callbackFunction):
		disconnect("pulse_beat", uninterestedListenerNode, callbackFunction)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	var bpm = Global.bpm
	var beat_duration = 60 / bpm

	if Time.get_ticks_msec() - time_at_last_beat > beat_duration * 1000:
		emit_signal("pulse_beat")
		time_at_last_beat = Time.get_ticks_msec()

func get_next_pitch_scale():
	pass

func play_chord():
	# Create four audio players
	var player1 = AudioStreamPlayer.new()
	var player2 = AudioStreamPlayer.new()
	var player3 = AudioStreamPlayer.new()
	var player4 = AudioStreamPlayer.new()

	# Set up the audio files for the players
	player1.set_stream(load("sine_wave.wav"))
	player2.set_stream(load("sine_wave.wav"))
	player3.set_stream(load("sine_wave.wav"))
	player4.set_stream(load("sine_wave.wav"))

	# Set the pitch scale for each player
	var pitch_scale = [1.0, 1.122, 1.189, 1.335, 1.498, 1.682, 1.89]
	player1.set_pitch_scale(pitch_scale[0])
	player2.set_pitch_scale(pitch_scale[2])
	player3.set_pitch_scale(pitch_scale[4])
	player4.set_pitch_scale(pitch_scale[5])

	# Play the notes on each player
	player1.play()
	player2.play()
	player3.play()
	player4.play()



