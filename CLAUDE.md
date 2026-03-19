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
- **Serviços**: métodos estáticos (`ServicoApi.buscarCicloAtual()`, `ServicoAuth.login()`) — não crie instâncias
- **Navegação**: `Navigator.push`/`pushReplacement` imperativo — sem named routes
- **Home**: `IndexedStack` com `Navbar` — tabs: Home(0), Times(1), Jogadores(2), Config(3)
- **API toggle**: `Api.apiLocal` em `lib/shared/api.dart` (true = local, false = prod)

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

## Design no Pencil (.pen)
`design-app.pen` contém todas as telas. Componentes reutilizáveis:
- `Component/InputField` (3Dfen)
- `Component/PlayerRow` (udYmQ)
- `Component/TableRow` (MsTss)
- `Component/MensalistaRow` (BN1ax)
- `Component/TeamCard` (qBOw1)
