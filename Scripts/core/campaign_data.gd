extends RefCounted
class_name CampaignData

static func get_classes() -> Dictionary:
	return {
		"Guardian": {
			"might": 3,
			"agility": 1,
			"presence": 1,
			"insight": 0
		},
		"Rogue": {
			"might": 1,
			"agility": 3,
			"presence": 1,
			"insight": 0
		},
		"Wizard": {
			"might": 0,
			"agility": 1,
			"presence": 1,
			"insight": 3
		}
	}

static func get_ancestries() -> Dictionary:
	return {
		"Human": {"presence": 1},
		"Dwarf": {"might": 1},
		"Elf": {"agility": 1},
		"Faerie": {"insight": 1}
	}

static func get_scene(scene_id: String) -> Dictionary:
	var scenes := {
		"tavern_start": {
			"title": "A Taverna do Javali Cego",
			"narrative": "Você desperta no calor de uma taverna cheia, em busca de pistas sobre o desaparecimento de uma caravana.",
			"elements": [
				{
					"id": "beer_full",
					"name": "Beer",
					"color": Color("d4a017"),
					"pos": Vector2(150, 220),
					"interactions": [
						{
							"id": "drink_beer",
							"label": "Drink",
							"description": "Você vira a caneca em um único gole.",
							"set_flags": ["beer_drank"],
							"goto": "tavern_after_drink"
						},
						{
							"id": "spill_beer",
							"label": "Derrubar no chão",
							"description": "Você derruba a cerveja para observar quem reage.",
							"set_flags": ["beer_spilled"],
							"goto": "tavern_after_drink"
						}
					],
					"requires_flags_absent": ["beer_drank", "beer_spilled"]
				},
				{
					"id": "bartender",
					"name": "Bartender",
					"color": Color("8b4513"),
					"pos": Vector2(420, 120),
					"interactions": [
						{
							"id": "ask_job",
							"label": "Pedir informações",
							"description": "Você pergunta sobre a caravana desaparecida.",
							"dc": 10,
							"attribute": "presence",
							"on_success": {
								"log": "O bartender revela que bandidos rondam o beco ao norte.",
								"set_flags": ["has_bartender_tip"],
								"goto": "tavern_after_talk"
							},
							"on_failure": {
								"log": "O bartender ignora suas perguntas e manda você comprar outra bebida.",
								"goto": "tavern_after_talk"
							}
						},
						{
							"id": "threaten_bartender",
							"label": "Ameaçar",
							"description": "Você bate no balcão exigindo respostas.",
							"dc": 12,
							"attribute": "might",
							"on_success": {
								"log": "Ele cede e conta sobre um contato na guilda.",
								"set_flags": ["bartender_scared", "knows_guild_contact"],
								"goto": "guild_offer"
							},
							"on_failure": {
								"log": "Os clientes se irritam com seu tom e uma briga começa.",
								"set_flags": ["tavern_brawl"],
								"goto": "brawl_aftermath"
							}
						}
					]
				},
				{
					"id": "suspicious_npc",
					"name": "Hooded NPC",
					"color": Color("4b0082"),
					"pos": Vector2(300, 280),
					"interactions": [
						{
							"id": "talk_npc",
							"label": "Conversar",
							"description": "A figura encapuzada fala em voz baixa sobre o beco.",
							"set_flags": ["met_hooded_npc"],
							"goto": "alley_ambush"
						},
						{
							"id": "rob_npc",
							"label": "Roubar",
							"description": "Você tenta puxar a bolsa do desconhecido.",
							"dc": 11,
							"attribute": "agility",
							"on_success": {
								"log": "Você consegue um mapa rabiscado da região.",
								"set_flags": ["has_stolen_map"],
								"goto": "alley_ambush"
							},
							"on_failure": {
								"log": "O NPC percebe e chama os guardas da taverna.",
								"set_flags": ["wanted_in_tavern"],
								"goto": "brawl_aftermath"
							}
						}
					]
				}
			]
		},
		"tavern_after_drink": {
			"title": "A Taverna após sua ação",
			"narrative": "A sala continua barulhenta, mas agora sua mesa revela as consequências do que você fez.",
			"elements": [
				{
					"id": "beer_empty",
					"name": "Empty Mug",
					"color": Color("9c7a3c"),
					"pos": Vector2(150, 220),
					"interactions": [
						{
							"id": "inspect_mug",
							"label": "Inspecionar",
							"description": "A caneca já está vazia. Não há mais nada para beber."
						}
					]
				},
				{
					"id": "door_north",
					"name": "North Door",
					"color": Color("2f4f4f"),
					"pos": Vector2(500, 80),
					"interactions": [
						{
							"id": "go_alley",
							"label": "Ir para o beco",
							"description": "Você segue para o beco indicado pelos rumores.",
							"goto": "alley_ambush"
						}
					]
				}
			]
		},
		"tavern_after_talk": {
			"title": "Rumores e suspeitas",
			"narrative": "A conversa movimentou a taverna. Agora você precisa decidir se segue pistas discretas ou age com força.",
			"elements": [
				{
					"id": "bartender_again",
					"name": "Bartender",
					"color": Color("8b4513"),
					"pos": Vector2(420, 120),
					"interactions": [
						{
							"id": "accept_tip",
							"label": "Seguir a dica",
							"description": "Você decide ir ao beco imediatamente.",
							"goto": "alley_ambush"
						}
					]
				},
				{
					"id": "guild_emissary",
					"name": "Guild Emissary",
					"color": Color("006400"),
					"pos": Vector2(260, 140),
					"interactions": [
						{
							"id": "talk_guild",
							"label": "Ouvir proposta",
							"description": "Uma emissária da guilda oferece contrato para proteger rotas.",
							"goto": "guild_offer"
						}
					],
					"requires_flags_present": ["has_bartender_tip"]
				}
			]
		},
		"alley_ambush": {
			"title": "Beco Nebuloso",
			"narrative": "A névoa toma conta do beco e vultos cercam sua passagem. A campanha principal começa aqui.",
			"elements": [
				{
					"id": "bandit",
					"name": "Bandit",
					"color": Color("8b0000"),
					"pos": Vector2(320, 180),
					"interactions": [
						{
							"id": "fight_bandit",
							"label": "Atacar",
							"description": "Você enfrenta o bandido.",
							"dc": 12,
							"attribute": "might",
							"on_success": {
								"log": "Você derrota o bandido e encontra um selo de caravana.",
								"set_flags": ["bandit_defeated"]
							},
							"on_failure": {
								"log": "Você é ferido e recua para planejar melhor.",
								"set_flags": ["player_wounded"]
							}
						}
					]
				}
			]
		},
		"guild_offer": {
			"title": "Proposta da Guilda",
			"narrative": "A guilda oferece ouro e recursos, mas exige lealdade total em sua campanha.",
			"elements": [
				{
					"id": "guild_contract",
					"name": "Contract",
					"color": Color("1e90ff"),
					"pos": Vector2(310, 170),
					"interactions": [
						{
							"id": "sign_contract",
							"label": "Assinar",
							"description": "Você aceita o contrato e ganha apoio da guilda.",
							"set_flags": ["guild_allied"]
						},
						{
							"id": "refuse_contract",
							"label": "Recusar",
							"description": "Você recusa e segue sozinho, mantendo sua liberdade.",
							"set_flags": ["guild_refused"]
						}
					]
				}
			]
		},
		"brawl_aftermath": {
			"title": "Consequências da Confusão",
			"narrative": "A taverna entra em caos. Seu nome corre pela cidade e cada escolha passa a ter peso maior.",
			"elements": [
				{
					"id": "exit_window",
					"name": "Window",
					"color": Color("708090"),
					"pos": Vector2(520, 120),
					"interactions": [
						{
							"id": "escape_window",
							"label": "Escapar",
							"description": "Você salta pela janela e cai no beco.",
							"goto": "alley_ambush"
						}
					]
				}
			]
		}
	}
	return scenes.get(scene_id, {})
