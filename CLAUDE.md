# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Comandos
```bash
flutter pub get                          # Instalar dependências
flutter run                              # Rodar no dispositivo conectado
flutter analyze                          # Linter
flutter test                             # Testes
flutter pub run flutter_launcher_icons   # Regerar ícones (source: images/baderna_icon.png)
```

## Referências Obrigatórias
Antes de qualquer implementação, leia:
- `docs/resumo_api.md` — endpoints e modelos da API
- `docs/progresso.md` — o que já foi feito

## Regras de Estilo
- **Todo código em português** (variáveis, funções, classes, módulos). Exceção: termos Flutter/Dart (`Widget`, `State`, `build`)
- Classes: PascalCase (`TelaLogin`), variáveis/funções: camelCase (`nomeJogador`), arquivos: snake_case (`tela_login.dart`)
- Telas sempre importam apenas `shared/shared.dart` — nunca importe arquivos individuais de `shared/`
- Novos exports devem ser adicionados ao barrel file `shared/shared.dart`

## Arquitetura
- **Estado**: `StatefulWidget` + `setState()` — não use Provider, Riverpod, BLoC
- **Serviços**: métodos estáticos (`ServicoApi.obterCicloAtual(timeId)`, `ServicoAuth.login()`) — não crie instâncias
- **Navegação**: `Navigator.push`/`pushReplacement` imperativo — sem named routes
- **Home**: `IndexedStack` com `Navbar` — tabs: Home(0), Times(1), Jogadores(2), Config(3)
- **API toggle**: `Api.apiLocal` em `lib/shared/api.dart` (true = local, false = prod)
- **Multi-time**: Todas as rotas de negócio ficam sob `/times/:timeId/`. O `ContextoTime` armazena o time ativo.
- **Fluxo pós-login**: Login/Cadastro → `TelaSelecaoTime` → (0 times: criar/entrar | 1 time: direto | N times: seletor) → `TelaHome`

## Contexto de Time (`ContextoTime`)
Variáveis estáticas globais que armazenam o time ativo:
- `ContextoTime.timeIdAtivo` — ID do time selecionado (passar em todas as chamadas `ServicoApi`)
- `ContextoTime.ehAdmin` — se o usuário é admin naquele time (substitui `usuario.ehAdmin`)
- `ContextoTime.jogadorIdAtual` — ID do jogador do usuário naquele time (substitui `usuario.jogadorVinculadoId`)
- `ContextoTime.membroAtual` — objeto `Membro` completo
- `ContextoTime.timeAtivo` — objeto `Time` completo
- `ContextoTime.definir(time, membro)` — seta tudo de uma vez
- `ContextoTime.limpar()` — limpa no logout

## Modelos
- `Time` — id, nome, descricao, logoUrl, codigoConvite, criadorId, ativo
- `Membro` — id, timeId, usuarioId, jogadorId, papel ('admin'|'membro'), ativo
- `Usuario` — id, nome, email, telefone, fotoUrl, perfil (sem campo jogador — relação agora é via Membro)
- `Jogador`, `Partida`, `CicloMensal`, `ConfiguracoesGerais`, `Despesa`, `ResumoFinanceiro`

## NUNCA faça
- **Nunca use `Color(0xFF...)` ou valores numéricos inline** — sempre `AppColors`, `AppSizes`, `AppTypography`, `AppButtons`
- **Nunca use `TextStyle(...)` direto** — sempre constantes de `AppTypography`
- **Nunca use `EdgeInsets` com valores mágicos** — use `AppSizes.screenPadding`, `AppSizes.contentPadding`, ou as constantes de spacing
- **Nunca crie um `ElevatedButton`/`OutlinedButton` com style manual** — use `AppButtons.primary`, `AppButtons.secondary`, etc.
- **Nunca importe `dart:ui`** para pegar cores — tudo vem de `AppColors`
- **Nunca adicione pacote de state management** — o projeto usa `setState` por decisão
- **Nunca use `google_fonts`** diretamente nas telas — tipografia centralizada em `AppTypography`
- **Nunca crie widget novo para variante de um existente** — adicione parâmetros ao widget original

## Design System
Constantes completas nos arquivos `lib/shared/theme/`:
- `AppColors` — cores (app_colors.dart)
- `AppTypography` — estilos de texto (app_typography.dart)
- `AppSizes` — spacing, radius, alturas (app_sizes.dart)
- `AppButtons` — estilos de botão (app_buttons.dart)

Se o design usa um valor novo: adicione a constante no arquivo correto do theme, nunca inline.

## Widgets Reutilizáveis
- `AppTextField` — input pill-shaped com label, hint, prefixIcon, suffixIcon, validator
- `Navbar` — bottom nav com `ItemNavbar(icone, label)`, `indiceAtual`, `aoTrocar`

## ServicoApi — regras
- **Todos os métodos de negócio recebem `String timeId` como primeiro argumento** (exceto: `criarUsuario`, `obterMeuPerfil`, `atualizarMeuPerfil`, `buscarMeusTimes`, `criarTime`, `entrarNoTime`)
- Use `ContextoTime.timeIdAtivo!` ao chamar os métodos
- Métodos de time: `buscarMeusTimes`, `criarTime`, `entrarNoTime`, `buscarTime`, `atualizarTime`, `buscarMembros`, `atualizarPapelMembro`, `removerMembro`

## Design no Pencil (.pen)
`design-app.pen` contém todas as telas. Componentes reutilizáveis:
- `Component/InputField` (3Dfen)
- `Component/PlayerRow` (udYmQ)
- `Component/TableRow` (MsTss)
- `Component/MensalistaRow` (BN1ax)
- `Component/TeamCard` (qBOw1)
