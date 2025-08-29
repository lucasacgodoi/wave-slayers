# WaveSlayers - Jogo de Nave Espacial Multiplataforma

Um jogo 2D em pixel art onde o jogador controla uma nave espacial, enfrenta ondas de inimigos e tenta sobreviver o máximo possível. Funciona tanto em computadores quanto em dispositivos móveis com controles adaptados.

## Características

### Gameplay
- Controles para movimentação da nave (WASD/setas no PC, D-pad virtual no mobile)
- Mecânica de tiro para atacar naves inimigas (espaço no PC, botão de tiro no mobile)
- Inimigos que aparecem em ondas e se movem em direção ao jogador
- Sistema de progressão com aumento gradual de dificuldade:
  - Inimigos mais rápidos
  - Mais inimigos por onda
  - Padrões de movimento mais complexos
- Estilo visual em pixel art para todos os elementos do jogo
- Feedback visual quando inimigos são destruídos

### Multiplataforma
- **Detecção Automática**: O jogo detecta automaticamente se você está em um computador ou dispositivo móvel
- **Versão PC**: Controles tradicionais com teclado (WASD/setas + espaço)
- **Versão Mobile**: Interface touch otimizada com D-pad virtual e botão de tiro

## Estrutura dos Arquivos

- `detector.html` - **Ponto de entrada principal** - Sistema de detecção de dispositivo e redirecionamento
- `index.html` - Versão completa para computadores (PC)
- `mobile.html` - Versão otimizada para dispositivos móveis
- `README.md` - Documentação do projeto

## Como Acessar

1. **Acesse `detector.html`** como ponto de entrada principal
2. O sistema detectará automaticamente seu dispositivo
3. Você será redirecionado para a versão apropriada:
   - **PC** → `index.html` 
   - **Mobile** → `mobile.html`

## Como Jogar

### Controles PC
- **WASD ou Setas direcionais**: Movimentam a nave
- **Barra de espaço**: Dispara tiros
- **P**: Pausar/Despausar

### Controles Mobile
- **D-pad virtual**: Movimenta a nave (setas direcionais na tela)
- **Botão vermelho**: Dispara tiros
- **Botão ⏸️**: Pausar/Despausar

### Objetivo
Sobreviva o máximo possível, destruindo naves inimigas e acumulando pontos. A dificuldade aumenta a cada onda de inimigos.

### Pontuação
- Inimigo básico: 10 pontos
- Inimigo avançado: 20 pontos  
- Inimigo chefe: 50 pontos

## Como Executar

1. Clone ou baixe este repositório
2. Abra o arquivo `detector.html` em um navegador web moderno
3. O sistema detectará automaticamente seu dispositivo e carregará a versão apropriada
4. Divirta-se!

## Tecnologias Utilizadas

- HTML5 Canvas para renderização
- CSS3 para styling e responsividade
- JavaScript ES6+ para lógica do jogo
- Touch Events API para controles móveis
- User Agent Detection para identificação de dispositivos

## Características Mobile

### Otimizações para Touch
- Interface adaptada para telas menores
- Controles virtuais otimizados para dedos
- Prevenção de scrolling e zoom indesejados
- Suporte a orientação retrato e paisagem
- Feedback visual aprimorado para toques

### Performance
- Canvas redimensionado dinamicamente para diferentes telas
- Controles responsivos com diferentes tamanhos de tela
- Otimização de eventos touch para melhor resposta

## Desenvolvimento Futuro

Possíveis melhorias para implementações futuras:

1. Sistema de Progressão Viciante
* Experiência e Level Up: Sistema de XP que persiste entre partidas
* Skill Tree: Árvore de habilidades com diferentes caminhos (Ataque, Defesa, Velocidade, Especiais)
* Achievements/Conquistas: Sistema com 50+ conquistas desbloqueáveis
* Daily Challenges: Desafios diários que dão recompensas especiais
* Battle Pass: Sistema sazonal com recompensas exclusivas

2. Arsenal Devastador
* 15+ Tipos de Armas: Laser, Plasma, Mísseis teleguiados, Shotgun espacial, etc.
* Sistema de Crafting: Combine materiais para criar armas únicas
* Modificadores de Arma: Damage, velocidade, penetração, efeitos elementais
* Armas Lendárias: Armas raras com habilidades especiais únicas

3. Nave Customizável
* 20+ Modelos de Nave: Cada uma com stats únicos
* Sistema de Upgrade: Motor, escudo, armas, habilidades especiais
* Skins Épicas: Skins animadas, holográficas, com partículas especiais
* Modificações Visuais: Rastros, auras, efeitos de propulsão

4. Inimigos Inteligentes
* IA Adaptativa: Inimigos que aprendem padrões do jogador
* 20+ Tipos Únicos: Cada um com mecânicas especiais
* Chefes Épicos: Chefes gigantes com múltiplas fases e ataques especiais
* Formações Táticas: Inimigos que se coordenam em ataques

5. Mundos Dinâmicos
* Eventos Ambientais: Tempestades de meteoros, buracos negros, anomalias
* Backgrounds Interativos: Elementos que afetam o gameplay
* Ciclos Dia/Noite: Diferentes inimigos e mecânicas por período
* Biomas Especiais: Cada mundo com mecânicas únicas

6. Power-ups Insanos
* Transformações Temporárias: Vire um mecha, drone swarm, ou energia pura
* Habilidades Ultimates: Ataques devastadores com cooldown
* Combos de Power-ups: Combinações que criam efeitos únicos
* Power-ups Raros: Efeitos que duram a partida inteira

7. Sistema Social
* Leaderboards Globais: Rankings por mundo, weekly, mensais
* Sistema de Clãs: Forme grupos e compitam por recompensas
* Eventos Comunitários: Todos os jogadores colaboram para objetivos globais
* Share System: Compartilhe seus melhores momentos

8. Economia Robusta
* Múltiplas Moedas: Coins, Gems, Dark Matter, etc.
* Marketplace: Troque itens com outros jogadores
* Investimentos: Sistema bancário espacial que gera juros
* Eventos Especiais: Double XP, drop rates aumentados

9. Modos de Jogo Épicos
* Survival Mode: Sobreviva ondas infinitas
* Time Attack: Complete objetivos no menor tempo
* Puzzle Mode: Destrua inimigos em sequências específicas
* Boss Rush: Enfrente todos os chefes em sequência
* Multiplayer Co-op: Até 4 jogadores online

10. Tecnologias Futuristas
* Sistema de Partículas Avançado: Explosões, raios, efeitos mágicos
* Física Realista: Gravitação, momentum, colisões precisas
* Shader Effects: Distorções espaciais, efeitos de luz, warping
* Audio Dinâmico: Música que se adapta à intensidade da ação

11. Meta-Game Profundo
* Base Espacial: Construa e gerencie sua estação espacial
* Research Lab: Pesquise tecnologias para desbloquear conteúdo
* Fleet Management: Gerencie uma frota de naves autônomas
* Galactic Map: Explore e conquiste setores da galáxia

12. Elementos RPG
* Character Classes: Piloto, Engenheiro, Soldado, Psíquico
* Stats Persistentes: Força, Agilidade, Inteligência, Sorte
* Equipment Sets: Conjuntos de equipamentos com bônus
* Prestige System: Reset com bônus permanentes
