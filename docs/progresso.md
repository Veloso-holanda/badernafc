# Baderna FC - Progresso

## Sessão 1 - 07/03/2026

### Design System (concluído)
- [x] Criada estrutura de pastas: `admin/`, `usuarios/`, `shared/`
- [x] `app_colors.dart` - Paleta completa baseada no design-app.pen
- [x] `app_typography.dart` - Estilos de texto com fonte Inter
- [x] `app_sizes.dart` - Espaçamentos, border radius, alturas padrão
- [x] `app_buttons.dart` - Primary, secondary, text, FAB, FAB sortear
- [x] `app_theme.dart` - Dark theme com Material 3
- [x] `app_text_field.dart` - Widget de input reutilizável (pill, transparente)
- [x] `shared.dart` - Barrel file exportando tudo
- [x] `api.dart` - URLs local/prod com flag `apiLocal`
- [x] `main.dart` - Atualizado para usar `AppTheme.dark`

### Documentação (concluído)
- [x] `docs/arquitetura.md` - Documentação principal
- [x] `docs/progresso.md` - Registro de progresso

### Decisões
- Variáveis e nomes de módulos em **português**
- Dark theme como padrão (baseado no design do Pencil)
- Fonte **Inter** (conforme design-app.pen)

### Telas e Navegação (concluído)
- [x] `tela_login.dart` - Login com email/senha, validação, link cadastro
- [x] `tela_cadastro.dart` - Cadastro com apelido, email, telefone, senha, confirmar senha
- [x] `tela_home.dart` - Home do jogador com lista de confirmados, goleiros, espera, FAB
- [x] `navbar.dart` - Bottom navbar reutilizável (Home, Times, Jogadores, Config)
- [x] `main.dart` - Entry point agora inicia na TelaLogin
- [x] `shared.dart` - Barrel file atualizado com navbar

### Próximos Passos
- [ ] Criar tela Splash Screen
- [ ] Criar tela Home Admin (com FAB sortear)
- [ ] Criar telas: Times, Jogadores, Config
- [ ] Integrar Firebase Auth (login/cadastro)
- [ ] Definir modelos de dados (Jogador, Partida, CicloMensal)
- [ ] Integrar API REST
- [ ] Adicionar fonte Inter via google_fonts
