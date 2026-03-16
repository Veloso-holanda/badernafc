# Baderna FC - Documentação Principal

## Sobre o App

App mobile para gerenciamento de peladas de futebol. Permite controlar jogadores, confirmar presenças, sortear times e acompanhar partidas.

---

## Convenções

### Idioma do Código

- **Variáveis, funções, classes e nomes de módulos em português**
- Exemplo: `jogador`, `confirmarPresenca()`, `listaJogadores`, `SorteioTimes`
- Exceções: palavras técnicas do Flutter/Dart que não fazem sentido traduzir (`Widget`, `State`, `Controller`, `build`, etc.)

### Nomenclatura

- Classes: `PascalCase` → `TelaLogin`, `CartaoJogador`
- Variáveis/funções: `camelCase` → `nomeJogador`, `buscarPartidas()`
- Arquivos: `snake_case` → `tela_login.dart`, `cartao_jogador.dart`
- Constantes: `camelCase` dentro de classes abstratas → `AppColors.primary`

---

## Arquitetura

### Estrutura de Pastas

```
lib/
├── main.dart                    # Entry point
├── admin/                       # Módulo do administrador
│   ├── telas/                   # Telas do admin
│   └── widgets/                 # Widgets exclusivos do admin
├── usuarios/                    # Módulo do jogador/usuário
│   ├── telas/                   # Telas do usuário
│   └── widgets/                 # Widgets exclusivos do usuário
└── shared/                      # Recursos compartilhados
    ├── shared.dart              # Barrel file (exporta tudo)
    ├── api.dart                 # Config de URLs e conexão
    ├── theme/                   # Design System
    │   ├── app_colors.dart      # Paleta de cores
    │   ├── app_typography.dart  # Estilos de texto (fonte Inter)
    │   ├── app_sizes.dart       # Espaçamentos, raios, alturas
    │   ├── app_buttons.dart     # Estilos de botões
    │   └── app_theme.dart       # ThemeData (dark theme)
    └── widgets/                 # Widgets reutilizáveis
        └── app_text_field.dart  # Campo de texto padrão
```

### Módulos

| Módulo | Descrição |
|--------|-----------|
| `admin/` | Telas e lógica exclusivas do administrador (sortear times, gerenciar jogadores, mensalistas) |
| `usuarios/` | Telas e lógica do jogador comum (confirmar presença, ver times, perfil) |
| `shared/` | Design system, widgets reutilizáveis, configuração de API, modelos compartilhados |

---

## Design System

### Tema

- **Dark theme** com gradiente verde escuro
- Fonte: **Inter**
- Material Design 3

### Paleta de Cores

| Token | Hex | Uso |
|-------|-----|-----|
| `primary` | `#1B9B0A` | Botões, destaques, splash |
| `primaryDark` | `#1B5E20` | Tabela rows |
| `star` | `#4CAF50` | Estrelas, links, navbar ativo |
| `bgDark` | `#0A1F0A` | Navbar, fundo base |
| `bgGradientStart` | `#1A3D1A` | Topo do gradiente |
| `bgGradientCenter` | `#0D2B0D` | Centro do gradiente |
| `bgGradientEnd` | `#061206` | Base do gradiente |
| `tableHeaderBg` | `#2E7D32` | Cabeçalho de tabelas |
| `tableRowBg` | `#1B5E20CC` | Linha de tabela (par) |
| `tableRowAltBg` | `#2E7D3266` | Linha de tabela (ímpar) |
| `textWhite` | `#FFFFFF` | Texto principal |
| `textMuted` | `#FFFFFFAA` | Texto secundário |
| `inputBg` | `#FFFFFF33` | Fundo do input |
| `inputBorder` | `#FFFFFF55` | Borda do input |
| `error` | `#FF5252` | Erros, remover |
| `fabSortear` | `#FF8F00` | FAB de sortear times |

### Componentes de UI

| Componente | Estilo |
|------------|--------|
| Botão primário | Pill (radius 26), h52, bg primary, texto branco bold |
| FAB | Pill (radius 25), h50, shadow, com ícone + texto |
| Input | Pill (radius 25), h50, bg transparente, borda branca sutil |
| Navbar | h70, bg escuro, ícones Lucide, ativo verde / inativo cinza |
| Tabela | Header verde, rows alternadas com transparência |

---

## API

| Config | Valor |
|--------|-------|
| URL Local | `http://192.168.100.8:3000/api` |
| URL Prod | `https://api.badernafc.com.br` |
| Flag | `Api.apiLocal` (true = local, false = prod) |
| Timeout | 15s connect / 15s receive |

---

## Telas Planejadas

### Fluxo Público
- Splash Screen
- Login
- Cadastro

### Módulo Usuário (jogador)
- Home (lista de jogadores confirmados, confirmar presença)
- Times (ver times sorteados)
- Jogadores (lista geral)
- Configurações / Perfil

### Módulo Admin
- Home Admin (mesma lista + botão sortear times)
- Gerenciar jogadores (adicionar/remover)
- Mensalistas
- Sorteio de times
- Ranking

---

## Dependências

- `flutter` SDK
- `cupertino_icons: ^1.0.8`

### Planejadas
- `http` ou `dio` (requisições HTTP)
- `provider` ou `riverpod` (gerenciamento de estado)
- `shared_preferences` (armazenamento local)
- `google_fonts` (fonte Inter)
