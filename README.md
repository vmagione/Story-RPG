# Story RPG (Godot 4)

Base de jogo narrativo com decisões, cenas em nós e interações por elemento.

## Arquitetura

- `Scripts/core/campaign_data.gd`: banco de dados inicial da campanha (cenas, elementos, interações, classes, ancestralidades).
- `Scripts/core/game_state.gd`: estado global da campanha (ficha do jogador, flags persistentes, histórico e resolução de testes d20).
- `Scripts/ui/main_game.gd`: camada de UI e renderização de cena.
- `Scenes/Main.tscn`: tela principal com criação de personagem + layout de jogo (ficha à esquerda e cena à direita).

## Como expandir

1. Adicione novas cenas em `CampaignData.get_scene()` com um novo `scene_id`.
2. Em cada cena, adicione novos elementos no array `elements`.
3. Cada elemento aceita:
   - `id`, `name`, `color`, `pos`
   - `interactions`: lista de ações clicáveis.
   - `requires_flags_present`/`requires_flags_absent`: controle condicional de disponibilidade.
4. Cada interação aceita:
   - `label`, `description`
   - opcional `dc` + `attribute` para rolagem de d20.
   - `set_flags` para persistência de consequências.
   - `goto` para transição de cena.
   - `on_success`/`on_failure` para ramificações após testes.

## Fluxo atual de exemplo

- Começa na taverna.
- Jogador cria personagem (nome, classe, ancestralidade).
- Interage com `Beer`, `Bartender` e `Hooded NPC`.
- Decisões ramificam para cenas como `tavern_after_drink`, `guild_offer`, `brawl_aftermath` e `alley_ambush`.
- Histórico e flags garantem memória de ações passadas (ex: cerveja não reaparece cheia após beber/derramar).
