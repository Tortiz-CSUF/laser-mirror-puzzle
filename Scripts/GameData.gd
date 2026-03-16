extends Node

## Grid Settings
const CELL_SIZE := 64
const GRID_OFFSET := Vector2(160, 40)

## Piece Types
enum PieceType {
	EMPTY,
	LASER,
	GOAL,
	MIRROR_STATIC_SINGLE,
	MIRROR_STATIC_DOUBLE,
	MIRROR_ROTATE_SINGLE,
	MIRROR_ROTATE_DOUBLE,
	MIRROR_SLIDE_H,
	MIRROR_SLLIDE_V,
	BARRIER,
	HAZARD,
	BOMB
	
}

## Mirror Orientation: Direction of reflection
enum MirrorDIr {
	NE,
	NW,
	SE,
	SW
	
}

enum Dir {
	UP,
	DOWN,
	LEFT,
	RIGHT
	
}

enum LevelStatus {
	LOCKED, 
	INCOMPLETE,
	COMPLETE
	
}

# Colors
const COLOR_GRID_BG := Color(0.15, 0.15, 0.2)
const COLOR_GRID_LINE := Color(0.3, 0.3, 0.4)
const COLOR_TILE_EMPTY := Color(0.2, 0.2, 0.28)
const COLOR_LASER_BEAM := Color(1.0, 0.1, 0.1, 0.9)
const COLOR_LASER_SOURCE := Color(0.8, 0.0, 0.0)
const COLOR_GOAL_INACTIVE := Color(0.0, 0.6, 0.0)
const COLOR_GOAL_ACTIVE := Color(0.0, 1.0, 0.0)
const COLOR_MIRROR := Color(0.4, 0.85, 0.95)
const COLOR_BARRIER := Color(0.4, 0.4, 0.45)
const COLOR_HAZARD := Color(1.0, 0.65, 0.0, 0.5)
const COLLOR_SLIDE_RANGE := Color(0.5, 0.5, 0.8, 0.25)
