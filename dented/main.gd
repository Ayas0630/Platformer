extends Node2D
## DENTED - a "Bouncing Back" platformer.
## Everything is built in code, so the whole game lives in this one script.
## Change the numbers at the top to tune how it feels.

# ---------- numbers you can tweak ----------
const MAX_HEALTH := 3
const GRAVITY := 1800.0
const MAX_FALL := 900.0
const SPEEDS := {3: 300.0, 2: 210.0, 1: 130.0}   # run speed for each health
const JUMPS := {3: 620.0, 2: 560.0, 1: 440.0}    # jump power for each health
const KNOCKBACK := Vector2(380.0, -330.0)         # push when a spike hits you
const BOUNCE_BACK_JUMP := 700.0                   # hop when you respawn
const HURT_STUN_TIME := 0.25                      # seconds controls are off after a hit
const PLAYER_SIZE := Vector2(32, 44)
const SCREEN := Vector2(960, 540)
const START_POS := Vector2(60, 476)
const BALL_SPEED := 650.0          # how fast the ball flies out
const BALL_RANGE := 320.0          # how far it flies before turning back
const BALL_RETURN_SPEED := 800.0   # how fast it comes back to you
const BALL_RADIUS := 9.0
const BALL_COOLDOWN := 2.0         # seconds after catching the ball before you can throw again
const SPIKE_HITS := 3              # ball hits needed to destroy a spike
const ENEMY_HITS := 3              # ball hits needed to destroy a flying enemy
const LEVEL_CLEAR_HEAL := 0        # health you get for finishing a level (0 = none)
const RAINBOW_DEATHS := 5          # deaths in one level before you turn rainbow
const RAINBOW_SPEED_MULT := 1.4
const RAINBOW_JUMP_MULT := 1.2
const RAINBOW_SIZE := Vector2(96, 44)
const EXPLOSION_SCALE := 0.4       # blob art is 384x384 with the body at (174, 198)
const EXPLOSION_OFFSET := Vector2(18, -6)
const EXPLOSION_FRAME_TIME := 0.07
const EXPLOSION_TIME := 0.5        # pause between exploding and coming back
const MUSIC_VOLUME_DB := -8.0      # lower = quieter (0 is full volume)
const SFX_VOLUME_DB := -4.0
const MUSIC_FILES := ["res://audio/background_music.ogg", "res://audio/background_music.mp3", "res://audio/background_music.wav"]
const RESPAWN_FILES := ["res://audio/respawn.ogg", "res://audio/respawn.wav"]

# ---------- levels ----------
# platforms/spikes are Rect2(x, y, width, height) from the top-left corner.
# bandages, checkpoints and goal are centre positions. Ground top is y = 500.
var levels := [
	{ # 1
		"name": "First steps",
		"platforms": [Rect2(0, 500, 960, 40), Rect2(300, 430, 140, 20)],
		"spikes": [Rect2(180, 476, 40, 24), Rect2(520, 476, 40, 24)],
		"bandages": [Vector2(370, 395)],
		"checkpoints": [Vector2(640, 475)],
		"goal": Vector2(910, 470),
	},
	{ # 2
		"name": "Mind the gap",
		"enemies": [{"pos": Vector2(340, 440), "axis": "y", "range": 30, "speed": 80}],
		"platforms": [Rect2(0, 500, 300, 40), Rect2(380, 500, 200, 40), Rect2(660, 500, 300, 40), Rect2(540, 420, 100, 20)],
		"spikes": [Rect2(470, 476, 40, 24), Rect2(800, 476, 40, 24)],
		"bandages": [Vector2(590, 390)],
		"checkpoints": [Vector2(720, 475)],
		"goal": Vector2(920, 470),
	},
	{ # 3
		"name": "Stepping stones",
		"enemies": [{"pos": Vector2(240, 440), "axis": "y", "range": 30, "speed": 90}, {"pos": Vector2(640, 440), "axis": "y", "range": 30, "speed": 90}],
		"platforms": [Rect2(0, 500, 200, 40), Rect2(280, 500, 120, 40), Rect2(480, 500, 120, 40), Rect2(680, 500, 280, 40), Rect2(380, 430, 100, 20)],
		"spikes": [Rect2(300, 476, 40, 24), Rect2(520, 476, 40, 24), Rect2(780, 476, 40, 24), Rect2(850, 476, 40, 24)],
		"bandages": [Vector2(430, 400), Vector2(750, 470)],
		"checkpoints": [Vector2(380, 475), Vector2(700, 475)],
		"goal": Vector2(925, 470),
	},
	{ # 4
		"name": "Stairs",
		"enemies": [{"pos": Vector2(470, 485), "axis": "x", "range": 50, "speed": 70}],
		"platforms": [Rect2(0, 500, 960, 40), Rect2(260, 440, 120, 20), Rect2(440, 380, 120, 20), Rect2(620, 320, 120, 20), Rect2(790, 380, 170, 20)],
		"spikes": [Rect2(150, 476, 40, 24), Rect2(560, 476, 40, 24), Rect2(700, 476, 40, 24), Rect2(820, 476, 40, 24)],
		"bandages": [Vector2(320, 410), Vector2(680, 290)],
		"checkpoints": [Vector2(500, 355)],
		"goal": Vector2(900, 350),
	},
	{ # 5
		"name": "Long jumps",
		"enemies": [{"pos": Vector2(230, 440), "axis": "y", "range": 30, "speed": 90}, {"pos": Vector2(710, 440), "axis": "y", "range": 30, "speed": 90}],
		"platforms": [Rect2(0, 500, 180, 40), Rect2(280, 500, 140, 40), Rect2(520, 500, 140, 40), Rect2(760, 500, 200, 40), Rect2(430, 440, 60, 20)],
		"spikes": [Rect2(320, 476, 40, 24), Rect2(580, 476, 40, 24), Rect2(840, 476, 40, 24)],
		"bandages": [Vector2(460, 415)],
		"checkpoints": [Vector2(545, 475), Vector2(790, 475)],
		"goal": Vector2(930, 470),
	},
	{ # 6
		"name": "Spike alley",
		"platforms": [Rect2(0, 500, 960, 40)],
		"spikes": [Rect2(160, 476, 40, 24), Rect2(270, 476, 40, 24), Rect2(380, 476, 40, 24), Rect2(520, 476, 80, 24), Rect2(700, 476, 40, 24), Rect2(800, 476, 80, 24)],
		"bandages": [Vector2(345, 470), Vector2(640, 470)],
		"checkpoints": [Vector2(450, 475), Vector2(770, 475)],
		"goal": Vector2(925, 470),
	},
	{ # 7
		"name": "Rooftops",
		"enemies": [{"pos": Vector2(415, 405), "axis": "y", "range": 30, "speed": 80}, {"pos": Vector2(815, 375), "axis": "y", "range": 30, "speed": 80}],
		"platforms": [Rect2(0, 500, 200, 40), Rect2(270, 450, 110, 20), Rect2(450, 400, 150, 20), Rect2(670, 350, 110, 20), Rect2(850, 400, 110, 20)],
		"spikes": [Rect2(510, 376, 40, 24)],
		"bandages": [Vector2(325, 420), Vector2(725, 320)],
		"checkpoints": [Vector2(470, 375), Vector2(690, 325)],
		"goal": Vector2(920, 370),
	},
	{ # 8
		"name": "Walls",
		"platforms": [Rect2(0, 500, 960, 40), Rect2(250, 430, 50, 70), Rect2(520, 420, 50, 80), Rect2(800, 430, 50, 70)],
		"spikes": [Rect2(150, 476, 40, 24), Rect2(330, 476, 40, 24), Rect2(420, 476, 40, 24), Rect2(620, 476, 40, 24), Rect2(720, 476, 40, 24)],
		"bandages": [Vector2(210, 470), Vector2(395, 470), Vector2(670, 470)],
		"checkpoints": [Vector2(275, 405), Vector2(545, 395), Vector2(775, 475)],
		"goal": Vector2(920, 470),
	},
	{ # 9
		"name": "The climb",
		"enemies": [{"pos": Vector2(605, 200), "axis": "y", "range": 25, "speed": 80}],
		"platforms": [Rect2(0, 500, 960, 40), Rect2(260, 450, 100, 20), Rect2(110, 390, 100, 20), Rect2(270, 330, 100, 20), Rect2(110, 270, 100, 20), Rect2(270, 210, 100, 20), Rect2(450, 210, 120, 20), Rect2(640, 210, 120, 20), Rect2(820, 270, 140, 20)],
		"spikes": [Rect2(300, 476, 40, 24), Rect2(420, 476, 40, 24), Rect2(560, 476, 40, 24), Rect2(700, 476, 40, 24)],
		"bandages": [Vector2(320, 300), Vector2(510, 180)],
		"checkpoints": [Vector2(300, 185), Vector2(700, 185)],
		"goal": Vector2(910, 240),
	},
	{ # 10
		"name": "Bounce back",
		"enemies": [{"pos": Vector2(210, 455), "axis": "y", "range": 30, "speed": 90}, {"pos": Vector2(390, 415), "axis": "y", "range": 30, "speed": 90}, {"pos": Vector2(870, 430), "axis": "y", "range": 25, "speed": 90}],
		"platforms": [Rect2(0, 500, 170, 40), Rect2(250, 460, 100, 20), Rect2(430, 420, 100, 20), Rect2(610, 500, 230, 40), Rect2(900, 440, 60, 20)],
		"spikes": [Rect2(100, 476, 40, 24), Rect2(650, 476, 40, 24), Rect2(760, 476, 40, 24)],
		"bandages": [Vector2(300, 430), Vector2(480, 390)],
		"checkpoints": [Vector2(450, 395), Vector2(725, 475)],
		"goal": Vector2(930, 410),
	},
]

# ---------- game state ----------
var state := "menu"          # "menu" or "playing"
var level_index := 0
var health := MAX_HEALTH
var invincible := false
var stunned := false
var checkpoint := START_POS
var changing_level := false
var run_id := 0              # bumped on every new run so old timers do nothing

var player: CharacterBody2D
var player_visual: CanvasItem
var world: Node2D
var menu_layer: CanvasLayer
var hud_layer: CanvasLayer
var hud_label: Label
var status_label: Label
var start_button: Button
var music_player: AudioStreamPlayer
var respawn_player: AudioStreamPlayer
var facing := 1.0            # 1 = right, -1 = left
var ball: Area2D
var ball_returning := false
var ball_dir := 1.0
var ball_start_x := 0.0
var ball_cooldown := 0.0
var deaths_in_level := 0
var rainbow := false
var dying := false
var ball_hit_ids: Array = []   # things this throw has already hit


func _ready() -> void:
	var bg := ColorRect.new()
	bg.size = SCREEN
	bg.color = Color(0.09, 0.11, 0.17)
	bg.z_index = -10
	add_child(bg)
	build_audio()
	build_player()
	build_hud()
	build_menu()
	show_menu("", "Start")


# =====================================================
#  Building things
# =====================================================
func build_player() -> void:
	player = CharacterBody2D.new()
	player.z_index = 10
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = PLAYER_SIZE
	shape.shape = rs
	player.add_child(shape)
	player.visible = false
	add_child(player)


func build_hud() -> void:
	hud_layer = CanvasLayer.new()
	add_child(hud_layer)
	hud_label = Label.new()
	hud_label.position = Vector2(16, 12)
	hud_label.add_theme_font_size_override("font_size", 22)
	hud_layer.add_child(hud_label)


func build_menu() -> void:
	menu_layer = CanvasLayer.new()
	add_child(menu_layer)

	# The pixel-art logo is the only title-screen graphic.
	if ResourceLoader.exists("res://art/menu.png"):
		var pic := TextureRect.new()
		pic.texture = load("res://art/menu.png")
		pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		pic.set_anchors_preset(Control.PRESET_FULL_RECT)
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		menu_layer.add_child(pic)

	# One simple button; no extra title, subtitle, or control instructions.
	start_button = Button.new()
	start_button.text = "▶ PLAY"
	start_button.anchor_left = 0.5
	start_button.anchor_right = 0.5
	start_button.anchor_top = 1.0
	start_button.anchor_bottom = 1.0
	start_button.offset_left = -160
	start_button.offset_right = 160
	start_button.offset_top = -112
	start_button.offset_bottom = -42
	start_button.add_theme_font_size_override("font_size", 28)
	start_button.pressed.connect(start_game)
	menu_layer.add_child(start_button)


# Loads the first audio file that exists from a list (ogg, mp3 or wav).
func find_audio(paths: Array) -> AudioStream:
	for path in paths:
		if ResourceLoader.exists(path):
			var stream := load(path) as AudioStream
			if stream != null:
				return stream
	return null


# Makes a looping copy of a sound. A WAV needs its loop start and end set,
# otherwise LOOP_FORWARD does nothing and the music plays once and stops.
func make_looping(stream: AudioStream) -> AudioStream:
	var looped := stream.duplicate() as AudioStream
	if looped is AudioStreamWAV:
		var wav := looped as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * wav.mix_rate)
	elif looped is AudioStreamOggVorbis:
		(looped as AudioStreamOggVorbis).loop = true
	elif looped is AudioStreamMP3:
		(looped as AudioStreamMP3).loop = true
	return looped


func build_audio() -> void:
	# Background music loops for the whole game, including the title screen.
	music_player = AudioStreamPlayer.new()
	music_player.name = "BackgroundMusic"
	music_player.volume_db = MUSIC_VOLUME_DB
	add_child(music_player)
	var music := find_audio(MUSIC_FILES)
	if music == null:
		push_warning("No music found. Put background_music.ogg (or .mp3 / .wav) in res://audio/")
	else:
		music_player.stream = make_looping(music)
		music_player.finished.connect(music_player.play)   # backup: restart if it ever ends
		music_player.play()

	# The respawn effect is played on demand.
	respawn_player = AudioStreamPlayer.new()
	respawn_player.name = "RespawnSound"
	respawn_player.volume_db = SFX_VOLUME_DB
	respawn_player.stream = find_audio(RESPAWN_FILES)
	add_child(respawn_player)


func start_music() -> void:
	# browsers only allow sound after a click, so also start it when Play is pressed
	if is_instance_valid(music_player) and music_player.stream != null and not music_player.playing:
		music_player.play()


func play_respawn_sound() -> void:
	if is_instance_valid(respawn_player) and respawn_player.stream != null:
		respawn_player.stop()
		respawn_player.play()


# Returns a sprite if res://art/<name>.png exists, otherwise a coloured box.
# Transparent padding around your picture is cut off so it fills its box.
# stretch=true squashes the picture to the box; otherwise it keeps its shape
# and stands on the bottom edge of the box.
func make_visual(art_name: String, size: Vector2, color: Color, stretch: bool = false) -> CanvasItem:
	var path := "res://art/%s.png" % art_name
	if ResourceLoader.exists(path):
		var tex: Texture2D = load(path)
		var img := tex.get_image()
		if img != null:
			var used := img.get_used_rect()
			if used.size.x > 0 and used.size != img.get_size():
				var atlas := AtlasTexture.new()
				atlas.atlas = tex
				atlas.region = Rect2(used)
				tex = atlas
		var s := Sprite2D.new()
		s.texture = tex
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var tsize := tex.get_size()
		if stretch:
			s.scale = size / tsize
		else:
			var k := minf(size.x / tsize.x, size.y / tsize.y)
			s.scale = Vector2(k, k)
			s.position.y = size.y / 2.0 - tsize.y * k / 2.0
		return s
	var r := ColorRect.new()
	r.size = size
	r.position = -size / 2.0
	r.color = color
	return r


func add_platform(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.position + rect.size / 2.0
	body.add_to_group("solid")
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = rect.size
	shape.shape = rs
	body.add_child(shape)
	body.add_child(make_visual("platform", rect.size, Color(0.35, 0.4, 0.55), true))
	world.add_child(body)


func add_spikes(rect: Rect2) -> void:
	var area := Area2D.new()
	area.position = rect.position + rect.size / 2.0
	area.add_to_group("hazard")
	area.set_meta("hp", SPIKE_HITS)
	area.set_meta("max_hp", SPIKE_HITS)
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = rect.size * 0.8   # slightly forgiving hitbox
	shape.shape = rs
	area.add_child(shape)
	if ResourceLoader.exists("res://art/spike.png"):
		area.add_child(make_visual("spike", rect.size, Color.WHITE, true))
	else:
		var count := int(rect.size.x / 20.0)
		for k in count:
			var x0 := -rect.size.x / 2.0 + k * 20.0
			var tri := Polygon2D.new()
			tri.polygon = PackedVector2Array([
				Vector2(x0, rect.size.y / 2.0),
				Vector2(x0 + 20.0, rect.size.y / 2.0),
				Vector2(x0 + 10.0, -rect.size.y / 2.0)])
			tri.color = Color(0.9, 0.2, 0.25)
			area.add_child(tri)
	world.add_child(area)


func add_enemy(data: Dictionary) -> void:
	var pos: Vector2 = data["pos"]
	var axis: String = data.get("axis", "x")
	var area := Area2D.new()
	area.position = pos
	area.z_index = 6
	area.add_to_group("hazard")
	area.add_to_group("enemy")
	area.set_meta("hp", ENEMY_HITS)
	area.set_meta("max_hp", ENEMY_HITS)
	area.set_meta("axis", axis)
	area.set_meta("origin", pos.y if axis == "y" else pos.x)
	area.set_meta("range", float(data.get("range", 60)))
	area.set_meta("speed", float(data.get("speed", 70)))
	area.set_meta("dir", 1.0)
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(24, 24)
	shape.shape = rs
	area.add_child(shape)
	area.add_child(make_visual("enemy", Vector2(30, 30), Color(0.75, 0.3, 0.85)))
	world.add_child(area)


func move_enemies(delta: float) -> void:
	for e in get_tree().get_nodes_in_group("enemy"):
		var dir: float = e.get_meta("dir")
		var speed: float = e.get_meta("speed")
		var origin: float = e.get_meta("origin")
		var reach: float = e.get_meta("range")
		var vertical: bool = e.get_meta("axis") == "y"
		var v: float = (e.position.y if vertical else e.position.x) + dir * speed * delta
		if v > origin + reach:
			e.set_meta("dir", -1.0)
		elif v < origin - reach:
			e.set_meta("dir", 1.0)
		if vertical:
			e.position.y = v
		else:
			e.position.x = v


func add_area(group: String, pos: Vector2, size: Vector2, art: String, color: Color) -> void:
	var area := Area2D.new()
	area.position = pos
	area.add_to_group(group)
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = size
	shape.shape = rs
	area.add_child(shape)
	area.add_child(make_visual(art, size, color))
	world.add_child(area)


func add_background(i: int) -> void:
	# uses background_1.png, background_2.png... or background.png for every level
	for path in ["res://art/background_%d.png" % (i + 1), "res://art/background.png"]:
		if ResourceLoader.exists(path):
			var s := Sprite2D.new()
			s.texture = load(path)
			s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			s.centered = false
			s.scale = SCREEN / s.texture.get_size()
			s.z_index = -5
			world.add_child(s)
			return


func load_level(i: int) -> void:
	ball = null
	if world:
		world.queue_free()
	world = Node2D.new()
	add_child(world)
	add_background(i)
	var data: Dictionary = levels[i]
	for r in data["platforms"]:
		add_platform(r)
	for r in data["spikes"]:
		add_spikes(r)
	for e in data.get("enemies", []):
		add_enemy(e)
	for p in data["bandages"]:
		add_area("heal", p, Vector2(26, 26), "bandage", Color(0.95, 0.95, 0.95))
	for p in data["checkpoints"]:
		add_area("checkpoint", p, Vector2(20, 50), "checkpoint", Color(0.3, 0.6, 1.0))
	add_area("goal", data["goal"], Vector2(34, 60), "goal", Color(1.0, 0.85, 0.2))
	player.position = START_POS
	player.velocity = Vector2.ZERO
	checkpoint = START_POS
	changing_level = false


func update_player_look() -> void:
	if player_visual:
		player_visual.queue_free()
	var h := clampi(health, 1, MAX_HEALTH)
	var colors := {3: Color(0.3, 0.8, 0.4), 2: Color(0.95, 0.65, 0.2), 1: Color(0.9, 0.3, 0.3)}
	if rainbow:
		player_visual = make_visual("rainbow", RAINBOW_SIZE, Color.WHITE)
	else:
		player_visual = make_visual("player_%d" % h, PLAYER_SIZE, colors[h])
	player.add_child(player_visual)


func update_hud() -> void:
	var level_name: String = levels[level_index].get("name", "")
	var ball_text := "ready"
	if is_instance_valid(ball):
		ball_text = "out"
	elif ball_cooldown > 0.0:
		ball_text = "%.1f s" % ball_cooldown
	var mode_text := "Deaths: %d / %d" % [deaths_in_level, RAINBOW_DEATHS]
	if rainbow:
		mode_text = "RAINBOW MODE!"
	hud_label.text = "Health: %d / %d      Ball: %s      %s      Level %d / %d: %s" % [
		maxi(health, 0), MAX_HEALTH, ball_text, mode_text, level_index + 1, levels.size(), level_name]


# =====================================================
#  Menu / game flow
# =====================================================
func show_menu(msg: String = "", button_text: String = "Start") -> void:
	run_id += 1
	state = "menu"
	player.visible = false
	hud_layer.visible = false
	dying = false
	ball = null
	if world:
		world.queue_free()
		world = null
	start_button.text = "▶ PLAY" if button_text == "Start" else button_text
	menu_layer.visible = true
	start_button.grab_focus()


func start_game() -> void:
	run_id += 1
	start_music()
	health = MAX_HEALTH
	level_index = 0
	invincible = false
	stunned = false
	dying = false
	rainbow = false
	deaths_in_level = 0
	player.modulate = Color.WHITE
	menu_layer.visible = false
	hud_layer.visible = true
	player.visible = true
	load_level(0)
	update_player_look()
	update_hud()
	state = "playing"


func next_level() -> void:
	level_index += 1
	rainbow = false          # rainbow mode only lasts for one level
	deaths_in_level = 0
	if level_index >= levels.size():
		level_index = levels.size() - 1
		show_menu("You bounced back! You win!", "Play again")
		return
	health = mini(health + LEVEL_CLEAR_HEAL, MAX_HEALTH)
	load_level(level_index)
	update_player_look()
	update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and state == "playing":
		if event.keycode == KEY_ESCAPE:
			show_menu("", "Start")
		elif event.keycode == KEY_R:
			fell()   # stuck? go back to the checkpoint for 1 health
		elif event.keycode == KEY_X or event.keycode == KEY_J or event.keycode == KEY_F:
			throw_ball()


# =====================================================
#  Injuries
# =====================================================
func hurt(from_x: float) -> void:
	if invincible or dying:
		return
	var my_run := run_id
	health -= 1
	update_hud()
	if health <= 0:
		bounce_back()
		return
	update_player_look()
	invincible = true
	stunned = true
	var away := 1.0 if player.position.x >= from_x else -1.0
	player.velocity = Vector2(KNOCKBACK.x * away, KNOCKBACK.y)
	await get_tree().create_timer(HURT_STUN_TIME).timeout
	if my_run != run_id:
		return
	stunned = false
	var flash := create_tween().set_loops(3)
	flash.tween_property(player, "modulate:a", 0.3, 0.1)
	flash.tween_property(player, "modulate:a", 1.0, 0.1)
	await flash.finished
	if my_run != run_id:
		return
	player.modulate.a = 1.0
	invincible = false


func bounce_back() -> void:
	# health reached 0: the blob explodes, then pops back at the checkpoint
	var my_run := run_id
	dying = true
	invincible = true
	stunned = false
	deaths_in_level += 1
	explode(player.position)
	player.visible = false
	shake_screen()
	update_hud()
	await get_tree().create_timer(EXPLOSION_TIME).timeout
	if my_run != run_id:
		return
	dying = false
	if deaths_in_level >= RAINBOW_DEATHS and not rainbow:
		rainbow = true          # died too many times: RAINBOW MODE
		ball_cooldown = 0.0
	play_respawn_sound()
	health = MAX_HEALTH if rainbow else 2
	player.position = checkpoint
	player.velocity = Vector2(0, -BOUNCE_BACK_JUMP)
	player.visible = true
	player.modulate = Color.WHITE
	update_player_look()
	update_hud()
	if rainbow:
		invincible = false
		return
	var flash := create_tween().set_loops(6)
	flash.tween_property(player, "modulate", Color(1, 1, 0.3), 0.1)
	flash.tween_property(player, "modulate", Color.WHITE, 0.1)
	await flash.finished
	if my_run != run_id:
		return
	player.modulate = Color.WHITE
	invincible = false


func explode(pos: Vector2) -> void:
	var frames: Array = []
	for i in range(1, 6):
		var path := "res://art/explode_%d.png" % i
		if ResourceLoader.exists(path):
			frames.append(load(path))
	var holder := Node2D.new()
	holder.position = pos
	holder.z_index = 20
	world.add_child(holder)
	if frames.is_empty():
		# no art: a simple burst of orange squares
		for k in 12:
			var bit := ColorRect.new()
			bit.size = Vector2(8, 8)
			bit.position = -bit.size / 2.0
			bit.color = Color(1.0, 0.55, 0.0)
			holder.add_child(bit)
			var ang := TAU * k / 12.0
			var bt := bit.create_tween().set_parallel(true)
			bt.tween_property(bit, "position", bit.position + Vector2(cos(ang), sin(ang)) * 70.0, 0.4)
			bt.tween_property(bit, "modulate:a", 0.0, 0.4)
		var cleanup := holder.create_tween()
		cleanup.tween_interval(0.6)
		cleanup.tween_callback(holder.queue_free)
		return
	var spr := Sprite2D.new()
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.scale = Vector2(EXPLOSION_SCALE, EXPLOSION_SCALE)
	spr.offset = EXPLOSION_OFFSET
	holder.add_child(spr)
	var anim := holder.create_tween()
	for f in frames:
		anim.tween_callback(spr.set_texture.bind(f))
		anim.tween_interval(EXPLOSION_FRAME_TIME)
	anim.tween_property(spr, "modulate:a", 0.0, 0.1)
	anim.tween_callback(holder.queue_free)


func shake_screen() -> void:
	var t := create_tween()
	for i in 6:
		t.tween_property(self, "position", Vector2(randf_range(-6.0, 6.0), randf_range(-6.0, 6.0)), 0.03)
	t.tween_property(self, "position", Vector2.ZERO, 0.03)


func smash(a: Area2D) -> void:
	# rainbow mode: touching a hazard destroys it
	poof(a.global_position)
	a.remove_from_group("hazard")
	a.remove_from_group("enemy")
	a.queue_free()


func current_speed() -> float:
	if rainbow:
		return SPEEDS[MAX_HEALTH] * RAINBOW_SPEED_MULT
	return SPEEDS[health]


func current_jump() -> float:
	if rainbow:
		return JUMPS[MAX_HEALTH] * RAINBOW_JUMP_MULT
	return JUMPS[health]


func fell() -> void:
	if dying:
		return
	player.position = checkpoint
	player.velocity = Vector2(0, -400)
	if invincible or rainbow:
		return
	health -= 1
	update_hud()
	if health <= 0:
		bounce_back()
	else:
		play_respawn_sound()
		update_player_look()


func heal() -> void:
	health = mini(health + 1, MAX_HEALTH)
	update_player_look()
	update_hud()


# =====================================================
#  The ball: throw it, it destroys spikes, then bounces back to you
# =====================================================
func make_ball_visual() -> CanvasItem:
	if ResourceLoader.exists("res://art/ball.png"):
		return make_visual("ball", Vector2(24, 24), Color.WHITE)
	var poly := Polygon2D.new()
	var pts := PackedVector2Array()
	for k in 16:
		var ang := TAU * k / 16.0
		pts.append(Vector2(cos(ang), sin(ang)) * BALL_RADIUS)
	poly.polygon = pts
	poly.color = Color(1.0, 0.9, 0.3)
	return poly


func throw_ball() -> void:
	if stunned or dying or ball_cooldown > 0.0 or is_instance_valid(ball) or world == null:
		return
	ball_hit_ids.clear()
	ball = Area2D.new()
	var shape := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = BALL_RADIUS
	shape.shape = c
	ball.add_child(shape)
	ball.add_child(make_ball_visual())
	ball.z_index = 9
	ball.position = player.position + Vector2(facing * 22.0, 8.0)
	ball_dir = facing
	ball_returning = false
	ball_start_x = ball.position.x
	world.add_child(ball)


func poof(pos: Vector2) -> void:
	var puff := ColorRect.new()
	puff.size = Vector2(30, 30)
	puff.position = pos - puff.size / 2.0
	puff.color = Color(1.0, 0.9, 0.4)
	puff.z_index = 5
	world.add_child(puff)
	var t := puff.create_tween()
	t.tween_property(puff, "modulate:a", 0.0, 0.3)
	t.tween_callback(puff.queue_free)


func update_ball(delta: float) -> void:
	if not is_instance_valid(ball):
		ball = null
		return
	if ball_returning:
		var to_player := player.position - ball.position
		if to_player.length() < 28.0:
			ball.queue_free()   # caught!
			ball = null
			ball_cooldown = BALL_COOLDOWN
			return
		ball.position += to_player.normalized() * BALL_RETURN_SPEED * delta
	else:
		ball.position.x += ball_dir * BALL_SPEED * delta
		if absf(ball.position.x - ball_start_x) > BALL_RANGE or ball.position.x < -20.0 or ball.position.x > SCREEN.x + 20.0:
			ball_returning = true
		for b in ball.get_overlapping_bodies():
			if b.is_in_group("solid"):
				ball_returning = true   # hit a wall: bounce back
				break
	# the ball damages spikes and enemies, then turns back to you
	for a in get_tree().get_nodes_in_group("hazard"):
		var id := a.get_instance_id()
		if ball_hit_ids.has(id) or not (a as Area2D).overlaps_area(ball):
			continue
		ball_hit_ids.append(id)
		ball_returning = true
		var hp: int = 0 if rainbow else int(a.get_meta("hp", 1)) - 1
		var max_hp: int = int(a.get_meta("max_hp", 1))
		if hp <= 0:
			poof(a.global_position)
			a.remove_from_group("hazard")
			a.remove_from_group("enemy")
			a.queue_free()
		else:
			a.set_meta("hp", hp)
			var tint := 0.3 + 0.7 * float(hp) / float(max_hp)
			a.modulate = Color(1.0, tint, tint)


# =====================================================
#  Main loop
# =====================================================
func _physics_process(delta: float) -> void:
	if state != "playing":
		return

	ball_cooldown = maxf(ball_cooldown - delta, 0.0)
	move_enemies(delta)
	update_hud()
	if dying:
		return
	if rainbow and player_visual is ColorRect:
		(player_visual as ColorRect).color = Color.from_hsv(fmod(Time.get_ticks_msec() / 800.0, 1.0), 0.7, 1.0)

	var dir := 0.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		dir += 1.0
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		dir -= 1.0

	if stunned:
		player.velocity.x = move_toward(player.velocity.x, 0.0, 900.0 * delta)
	else:
		player.velocity.x = dir * current_speed()
		if dir != 0.0:
			facing = dir
		if dir != 0.0 and player_visual is Sprite2D:
			(player_visual as Sprite2D).flip_h = dir < 0.0

	player.velocity.y = minf(player.velocity.y + GRAVITY * delta, MAX_FALL)

	var jump_pressed := Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W)
	if jump_pressed and player.is_on_floor() and not stunned:
		player.velocity.y = -current_jump()

	player.move_and_slide()
	update_ball(delta)

	if player.position.y > 700.0:
		fell()
		return

	for a in get_tree().get_nodes_in_group("hazard"):
		if (a as Area2D).overlaps_body(player):
			if rainbow:
				smash(a)
			else:
				hurt(a.global_position.x)
				break
	for a in get_tree().get_nodes_in_group("heal"):
		if health < MAX_HEALTH and (a as Area2D).overlaps_body(player):
			heal()
			a.queue_free()
	for a in get_tree().get_nodes_in_group("checkpoint"):
		if (a as Area2D).overlaps_body(player):
			checkpoint = Vector2(a.global_position.x, a.global_position.y + 25.0 - PLAYER_SIZE.y / 2.0 - 1.0)
	for a in get_tree().get_nodes_in_group("goal"):
		if not changing_level and (a as Area2D).overlaps_body(player):
			changing_level = true
			call_deferred("next_level")
			return
