# BadernaFC — Escopo Definitivo do Produto

## 1. Visão Geral

BadernaFC é um aplicativo mobile para gerenciamento completo de peladas (partidas de futebol amador recorrentes). O app permite que um grupo de amigos organize seu futebol mensal com controle de jogadores, presença, sorteio equilibrado de times e gestão financeira.

**Público-alvo:** Grupos de futebol amador que jogam regularmente (semanal/quinzenal) e precisam organizar lista de presença, cobranças e formação de times equilibrados.

**Proposta de valor:** Substituir os grupos de WhatsApp caóticos por uma ferramenta dedicada que automatiza lista de presença, garante sorteio justo e dá visibilidade financeira ao administrador.

---

## 2. Papéis e Permissões

### 2.1 Admin
Criador ou promotor do time. Também pode ser jogador. Tem acesso total:
- Criar e gerenciar o time
- Cadastrar, editar e remover jogadores
- Criar ciclos mensais
- Configurar parâmetros do time e do ciclo
- Atribuir e alterar notas de jogadores (fixa e por partida)
- Abrir/gerenciar lista de presença
- Realizar e refazer sorteio de times
- Definir goleiros por time manualmente
- Lançar despesas e controlar pagamentos
- Gerar e visualizar resumo financeiro
- Convidar novos membros via código de convite
- Alterar papel de membros e remover membros

### 2.2 Membro (Jogador)
Usuário comum vinculado ao time. Pode:
- Confirmar presença nas partidas (dentro das janelas de tempo)
- Visualizar lista de presença
- Visualizar sorteio dos times e balanço
- Visualizar lista de jogadores do time
- Visualizar perfil/carta de qualquer jogador do time
- Participar de múltiplos times simultaneamente

---

## 3. Entidades e Conceitos

### 3.1 Usuário
Conta pessoal no app. Campos: nome, email, telefone, foto de perfil. Um usuário pode ser membro de vários times.

### 3.2 Time
Grupo de futebol. Campos: nome, descrição, logo, código de convite, criador, status ativo/inativo. Possui suas próprias configurações gerais.

### 3.3 Membro
Vínculo entre Usuário e Time. Campos: papel (admin | membro), jogador vinculado, status ativo/inativo. Um usuário tem um registro de membro por time.

### 3.4 Jogador
Registro de um participante do futebol dentro de um time. Campos: apelido, nome completo, nota fixa (1–5 estrelas), flag goleiro, foto, status ativo/inativo. Um jogador pode existir sem estar vinculado a um usuário (ex: amigo que não tem o app). Jogadores marcados como goleiro não pagam mensalidade e não entram na lista de presença nem no sorteio — são gerenciados à parte.

### 3.5 Ciclo Mensal
Representa um mês de pelada. Apenas um ciclo ativo por vez por time. Campos: data de início, data de fim (mesmo dia do próximo mês), status (ativo | fechado), valor da mensalidade, valor da diária, quantidade de mensalistas. Ao ser criado, o sistema calcula automaticamente quantas partidas compõem o ciclo com base no dia da semana configurado no time. O ciclo fecha automaticamente na data de fim.

### 3.6 Partida
Uma ocorrência individual de jogo dentro de um ciclo. Gerada automaticamente na criação do ciclo. Campos: data, horário, status (agendada | lista aberta | lista fechada para mensalistas | sorteio realizado | finalizada), lista de presença, notas da partida por jogador, resultado do sorteio.

### 3.7 Configurações Gerais do Time
Parâmetros que mudam raramente. Definidos uma vez e herdados pelos ciclos/partidas:
- **Dia da semana** da partida (ex: quarta-feira)
- **Horário** da partida (ex: 20:00)
- **Quantidade de jogadores por time** no sorteio (ex: 5)
- **Quantidade de times** a serem sorteados (ex: 4)
- **Antecedência de abertura da lista** — horas antes da partida em que a lista abre automaticamente para mensalistas (ex: 48h)
- **Tempo limite para mensalistas** — horas antes da partida em que a lista fecha para mensalistas e abre para diaristas (ex: 6h)

### 3.8 Despesa
Lançamento financeiro dentro de um ciclo. Tipos:
- **Aluguel do campo** — valor fixo mensal
- **Despesa avulsa** — valor + descrição livre (coletes, bolas, água, etc.)

### 3.9 Resumo Financeiro
Calculado em tempo real por ciclo mensal:
- **Entradas:** (valor mensalidade × mensalistas que pagaram) + (valor diária × diaristas que pagaram por partida)
- **Saídas:** soma de todas as despesas do ciclo
- **Saldo:** entradas − saídas
- Visão consolidada anual: saldo de cada ciclo mensal do ano

---

## 4. Fluxos Principais

### 4.1 Onboarding e Acesso ao Time

```
Cadastro/Login
    → Tela de Seleção de Time
        → 0 times: opções de Criar Time ou Entrar com Código
        → 1 time: vai direto para Home
        → N times: exibe seletor de times
    → Home (com navbar: Home, Partidas, Times, Jogadores, Config)
```

- **Criar Time:** Admin preenche dados do time → time criado → código de convite gerado
- **Entrar no Time:** Usuário insere código de convite → vira membro do time
- **Troca de time:** Usuário pode alternar entre times a qualquer momento

### 4.2 Gestão de Jogadores (Admin)

1. Admin acessa a lista de jogadores do time
2. Cadastra novo jogador: apelido, nome completo, nota fixa (1–5), flag goleiro
3. Pode vincular jogador a um membro existente (usuário que já entrou no time)
4. Pode editar nota fixa, dados e remover jogador
5. Jogadores sem vínculo com usuário aparecem na lista mas não podem confirmar presença sozinhos

### 4.3 Ciclo Mensal (Admin)

1. Admin cria novo ciclo mensal (só se não houver outro ativo)
2. Define: data de início, valor mensalidade, valor diária, quantidade de mensalistas
3. Sistema calcula data de fim (mesmo dia do próximo mês) e gera as partidas automaticamente com base no dia da semana configurado
4. Admin pode marcar pagamento de mensalistas ao longo do ciclo
5. Ciclo fecha automaticamente na data de fim
6. Resumo financeiro disponível em tempo real durante todo o ciclo

### 4.4 Lista de Presença (por Partida)

```
[X horas antes] Lista abre automaticamente
    → Mensalistas podem confirmar presença
    → Mensalistas que pagaram o ciclo têm prioridade na lista

[Y horas antes] Tempo de mensalistas encerra
    → Mensalistas NÃO podem mais confirmar
    → Diaristas podem confirmar presença nas vagas restantes

[Lista aberta até o sorteio]
    → Diaristas continuam podendo entrar nas vagas disponíveis
    → Admin pode gerenciar a lista manualmente a qualquer momento

[Admin realiza o sorteio]
    → Lista efetivamente "fecha"
```

- A quantidade total de jogadores na lista é definida pela configuração (ex: 20)
- Goleiros ficam à parte — não ocupam vaga na lista e não entram no sorteio
- Se um mensalista desiste, a vaga abre para diarista

### 4.5 Sorteio de Times

**Pré-condições:**
- Lista de presença com jogadores suficientes
- Cada jogador na lista precisa ter uma nota (fixa ou ajustada para a partida)
- Distribuição de notas adequada: pelo menos 1 jogador de cada estrela (1–5) por time a ser formado

**Lógica do sorteio:**
- Com base na configuração (ex: 4 times de 5 jogadores = 20 jogadores)
- Cada time recebe exatamente 1 jogador de cada nível de estrela (1★, 2★, 3★, 4★, 5★)
- Dentro de cada nível, a distribuição é aleatória
- Isso garante equilíbrio: todos os times têm a mesma soma de estrelas

**Nota da partida:**
- O admin pode ajustar a nota de qualquer jogador especificamente para aquela partida, sem alterar a nota fixa
- Isso permite balanceamento fino (ex: jogador de 4★ que está machucado vira 3★ só naquela partida)

**Validação:**
- Se a distribuição de notas não permitir equilíbrio perfeito (ex: 3 jogadores de 5★ para 4 times), o sistema exibe alerta orientando o admin a ajustar notas da partida antes de sortear

**Pós-sorteio:**
- Resultado visível para todos os membros do time imediatamente
- Exibe os times formados com jogadores e a soma/balanço de cada time
- Admin define manualmente qual goleiro vai para cada time
- Admin pode refazer o sorteio se necessário

### 4.6 Financeiro (Admin)

**Entradas:**
- Pagamento de mensalidade: admin marca individualmente quais mensalistas pagaram no ciclo
- Pagamento de diária: admin marca quais diaristas pagaram em cada partida

**Saídas:**
- Aluguel do campo (valor mensal)
- Despesas avulsas com descrição (coletes, bolas, água, etc.)

**Resumo por ciclo (tempo real):**
- Total de entradas
- Total de saídas
- Saldo

**Visão anual:**
- Lista de ciclos mensais do ano com saldo de cada um
- Permite ao admin ter visão geral de saúde financeira do futebol

---

## 5. Carta do Jogador (Perfil Público)

Acessível por qualquer membro do time ao clicar no nome de um jogador em qualquer lista. Inspirada visualmente em uma figurinha de álbum da Copa do Mundo.

**Informações exibidas (v1):**
- Foto do jogador
- Apelido
- Nome completo
- Nota (estrelas)

**Futuro:**
- Estatísticas (partidas jogadas, frequência, gols, assistências, etc.)
- Exibição de todos os times que o jogador participa
- Badges e conquistas

---

## 6. Navegação (Navbar)

| Índice | Aba | Descrição |
|--------|-----|-----------|
| 0 | Home | Dashboard do time ativo — próxima partida, status da lista, resumo rápido |
| 1 | Partidas | Lista de partidas do ciclo ativo, acesso à lista de presença e sorteio |
| 2 | Jogadores | Lista de jogadores do time, acesso à carta do jogador |
| 3 | Config | Configurações gerais do time, ciclo mensal, financeiro (admin) |

---

## 7. Escopo Futuro (não incluído na v1)

- Resultado da partida (placar, MVP, destaques)
- Estatísticas detalhadas na carta do jogador
- Descoberta de times próximos e desafios entre times
- Integração com meios de pagamento
- Notificações push (abertura de lista, lembrete de partida, cobrança)
- Chat interno por time
- Histórico de desempenho do jogador ao longo dos ciclos
- Ranking/classificação entre jogadores do time

---

## 8. Regras de Negócio — Resumo

| # | Regra |
|---|-------|
| RN01 | Apenas um ciclo mensal ativo por time por vez |
| RN02 | Partidas são geradas automaticamente ao criar o ciclo, com base no dia da semana configurado |
| RN03 | Lista de presença abre automaticamente X horas antes (configurável) |
| RN04 | Mensalistas que pagaram têm prioridade na lista |
| RN05 | Após Y horas antes da partida, mensalistas não podem mais confirmar e diaristas podem entrar |
| RN06 | Lista permanece aberta para diaristas até o admin realizar o sorteio |
| RN07 | Goleiros não entram na lista de presença, não participam do sorteio e não pagam mensalidade |
| RN08 | Sorteio distribui 1 jogador de cada nível de estrela por time |
| RN09 | Sistema alerta se distribuição de notas não permite sorteio equilibrado |
| RN10 | Admin pode alterar nota de jogador por partida sem afetar nota fixa |
| RN11 | Admin define goleiros por time manualmente após o sorteio |
| RN12 | Admin pode refazer sorteio a qualquer momento |
| RN13 | Resumo financeiro calculado em tempo real |
| RN14 | Ciclo fecha automaticamente na data de fim |
| RN15 | Usuário pode ser membro de múltiplos times |
| RN16 | Jogador pode existir sem vínculo com usuário |
| RN17 | Pagamentos são marcados manualmente pelo admin (sem integração de pagamento) |
| RN18 | Desistência de mensalista abre vaga para diarista |
