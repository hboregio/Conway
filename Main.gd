extends Node2D

onready var timer: Timer = $Timer
onready var run_button: Button = $Button2
var width = 800
var height = 800
var cell_size = 20
var size = width/cell_size
var gen = []
var next_gen = []

func _ready():
	initial_setup()

func initial_setup():
	reset_gen(gen)
	reset_gen(next_gen)
	
func reset_gen(g):
	for x in range(size):
		g.append([])
		g[x] = []
		for y in range(size):
			g[x].append([])
			g[x][y] = 0

func render_state():
	# render empty grid
	for x in range(size):
		draw_line(Vector2(x*cell_size,0), Vector2(x*cell_size,width), Color(250, 250, 250, 1))
		draw_line(Vector2(0,x*cell_size), Vector2(height,x*cell_size), Color(250, 250, 250, 1))
	
	# render cells
	for x in range(size):
		for y in range(size):
			var cell = gen[x][y]
			if cell == 1:
				render_cell(x, y)

func render_cell(x, y):
	draw_rect(Rect2(Vector2(x*cell_size, y*cell_size), Vector2(cell_size, cell_size)), Color(250, 250, 250, 1))

func _draw():
	render_state()

func get_neighbors_of(x, y):
	var top = gen[x][y-1] if y-1 >= 0 else 0
	var right = gen[x+1][y] if x+1 < size else 0
	var bottom = gen[x][y+1] if y+1 < size else 0
	var left = gen[x-1][y] if x-1 >= 0 else 0
	var top_right = gen[x+1][y-1] if x+1 < size and y-1 >= 0 else 0
	var bottom_right = gen[x+1][y+1] if x+1 < size and y+1 < size else 0
	var bottom_left = gen[x-1][y+1] if x-1 >= 0 and y+1 < size else 0
	var top_left = gen[x-1][y-1] if x-1 >= 0 and y-1 >= 0 else 0
	
	return top+right+bottom+left+top_right+bottom_right+bottom_left+top_left

func process_step():
	for x in range(size):
		for y in range(size):
			var cell = gen[x][y]
			var neighbors = get_neighbors_of(x, y)
			
			if cell == 1:
				if neighbors < 2:
					next_gen[x][y] = 0
				elif neighbors == 2 or neighbors == 3:
					next_gen[x][y] = 1
				elif neighbors > 3:
					next_gen[x][y] = 0
			elif cell == 0:
				if neighbors == 3:
					next_gen[x][y] = 1
	
	# copy new state to grid
	for x in range(size):
		for y in range(size):
			gen[x][y] = next_gen[x][y]
	
	# reset next grid
	reset_gen(next_gen)
	
	update()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var x = int(event.position.x / cell_size)
		var y = int(event.position.y / cell_size)
		gen[x][y] = 1 if gen[x][y] == 0 else 0
		update()

func _on_Button_button():
	run_button.text = "Start"
	timer.stop()
	process_step()

func _on_Run_down():
	if timer.time_left > 0:
		run_button.text = "Start"
		timer.stop()
	else:
		run_button.text = "Stop"
		timer.start()
	
func _on_Timer_timeout():
	process_step()
