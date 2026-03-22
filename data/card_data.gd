extends Resource
class_name CardData

enum CardType{
	ENVIRONMENT,
	ANIMAL,
	MATERIAL
}

@export var id: String
@export var name: String
@export var icon: Texture2D
@export var card_type: CardType
@export var cursor: Texture2D
@export var logic_script: Script
