extends TileMap

var j
var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta*10.
	
	# Animate water
	for j in range(0,3):
		var mod3 = int(max(0,time))%3;
		var idx = int(max(0,time-1))%3;
		var tilesInTileset = self.get_used_cells_by_id(0,-1,Vector2i(8+j,idx),-1)
		for i in tilesInTileset:
			self.set_cell(0,i,self.get_cell_source_id(0,i),Vector2i(8+j,mod3))
	
	#Animate grass
	for j in range(0,8):
		var mod8 = int(max(0,time+j))%8;
		var idx = int(max(0,time+j-1))%8;
		var tilesInTileset = self.get_used_cells_by_id(0,-1,Vector2i(0+idx,2),-1)
		for i in tilesInTileset:
			self.set_cell(0,i,self.get_cell_source_id(0,i),Vector2i(0+mod8,2))
		
