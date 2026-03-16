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
	COMLETE
	
}
