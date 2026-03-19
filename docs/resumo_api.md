Baderna FC API - Guia para o Frontend
Base URL: http://localhost:3000
Auth: Todas as rotas (exceto / e /health) exigem header Authorization: Bearer <firebase-token>

1. Usuarios (/usuarios)
Metodo	Rota	Body	Descricao
POST	/usuarios	{ nome, email, apelido?, fotoUrl?, telefone?, perfil? }	Cria perfil (firebaseUid vem do token)
GET	/usuarios	-	Lista todos
GET	/usuarios/eu	-	Meu perfil
GET	/usuarios/:id	-	Buscar por ID
PUT	/usuarios/eu	{ nome?, apelido?, fotoUrl?, telefone?, perfil?, ativo? }	Atualizar meu perfil
DELETE	/usuarios/eu	-	Remover minha conta
Perfis: "admin" ou "usuario"

2. Jogadores (/jogadores)
Metodo	Rota	Body	Descricao
POST	/jogadores	{ nome, apelido?, nivel }	Admin cria jogador (gera codigoVincular automatico)
GET	/jogadores	-	Lista todos (com dados do usuario vinculado)
GET	/jogadores/:id	-	Buscar por ID
PUT	/jogadores/:id	{ nome?, apelido?, nivel? }	Atualizar jogador
DELETE	/jogadores/:id	-	Remover jogador
POST	/jogadores/vincular	{ codigoVincular }	Usuario vincula-se a um jogador pelo codigo
nivel: 1 a 5 (estrelas)
Vinculacao: ao vincular, email e telefone sao preenchidos automaticamente do cadastro do usuario

3. Configurações Gerais (/configuracoes-gerais) — Admin only
Metodo	Rota	Body	Descricao
POST	/configuracoes-gerais	{ valorCicloMensal, diaria, valorMensalista, diaFutebol, horaFutebol }	Criar (singleton, só permite 1)
GET	/configuracoes-gerais	-	Buscar configurações
PUT	/configuracoes-gerais	{ valorCicloMensal?, diaria?, valorMensalista?, diaFutebol?, horaFutebol? }	Atualizar
diaFutebol: 0=Domingo, 1=Segunda, 2=Terca, 3=Quarta, 4=Quinta, 5=Sexta, 6=Sabado
horaFutebol: formato "HH:MM" (ex: "21:30")

4. Ciclos Mensais (/ciclos-mensais)
Metodo	Rota	Body	Descricao
POST	/ciclos-mensais	{ dataInicial, mensalistas? }	Cria ciclo (usa ConfiguracoesGerais para dia/hora/valores)
GET	/ciclos-mensais	-	Lista todos (com mensalistas populados)
GET	/ciclos-mensais/atual	-	Ciclo ativo pela data de hoje
GET	/ciclos-mensais/:id	-	Buscar por ID
PUT	/ciclos-mensais/:id	{ mensalistas? }	Atualizar mensalistas
DELETE	/ciclos-mensais/:id	-	Remover ciclo
dataInicial: formato ISO "2026-03-10" - a dataFinal sera 1 mes depois automaticamente
mensalistas: array de IDs de jogadores ["id1", "id2"]

5. Partidas (/partidas)
Metodo	Rota	Body	Descricao
GET	/partidas	-	Lista todas
GET	/partidas/:id	-	Buscar por ID
GET	/partidas/ciclo/:cicloMensalId	-	Partidas de um ciclo
POST	/partidas/:id/confirmar	{ jogadorId }	Confirmar presenca (valida aberturaLista/fechamentoLista)
POST	/partidas/:id/promover	{ jogadorId }	Promover da lista de espera
DELETE	/partidas/:id/jogador/:jogadorId	-	Remover jogador da partida
PUT	/partidas/:id/nota	{ jogadorId, nota }	Alterar nota do jogador nessa partida
PUT	/partidas/:id/fechar	-	Fechar lista (status = fechada)
PUT	/partidas/:id/pagamento-diarista	{ jogadorId, pago }	Marcar pagamento de diarista (admin)
DELETE	/partidas/:id	-	Remover partida
Status da partida: "aguardando" → "aberta" → "fechada" → "sorteada" → "finalizada"
Campos de controle: aberturaLista (1 dia antes às 00:00), fechamentoLista (1h antes do horário)
Partidas são criadas automaticamente ao criar um ciclo (não há POST /partidas manual)

Resposta dos jogadores na partida:


{
  "jogadores": [
    {
      "jogador": { "_id": "...", "nome": "Fulano", "nivel": 4 },
      "nota": 4,
      "mensalista": true,
      "pago": false,
      "confirmadoEm": "2026-03-10T08:30:00Z"
    }
  ],
  "listaEspera": [
    { "_id": "...", "nome": "Diarista", "nivel": 3 }
  ]
}
Regra de prioridade:

Antes das 18h: mensalista → lista principal / diarista → lista de espera
Apos 18h: qualquer um entra na lista principal (se houver vaga)
Lista cheia (20): vai pra espera
Fluxo tipico no app
Login → Firebase Auth no front → obtem token
Cadastro → POST /usuarios com nome/email
Vincular jogador → POST /jogadores/vincular com codigo do admin
Ver ciclo atual → GET /ciclos-mensais/atual
Ver partidas do ciclo → GET /partidas/ciclo/:id
Confirmar presenca → POST /partidas/:id/confirmar
Admin: criar ciclo → POST /ciclos-mensais
Admin: criar partida → POST /partidas
Admin: ajustar notas → PUT /partidas/:id/nota
Admin: fechar lista → PUT /partidas/:id/fechar
Admin: marcar pagamento diarista → PUT /partidas/:id/pagamento-diarista
Admin: criar despesa → POST /financeiro/despesas
Admin: ver resumo financeiro → GET /financeiro/resumo/:cicloMensalId

6. Financeiro (/financeiro) — Admin only
Metodo	Rota	Body	Descricao
POST	/financeiro/despesas	{ cicloMensalId, descricao, valor, data? }	Criar despesa
GET	/financeiro/despesas/ciclo/:cicloMensalId	-	Listar despesas do ciclo
PUT	/financeiro/despesas/:id	{ descricao?, valor?, data? }	Atualizar despesa
DELETE	/financeiro/despesas/:id	-	Remover despesa
GET	/financeiro/resumo/:cicloMensalId	-	Resumo financeiro do ciclo

Resposta do resumo financeiro:
{
  "cicloMensalId": "...",
  "receitaMensalistas": 2000,
  "quantidadeMensalistas": 10,
  "valorMensalista": 200,
  "receitaDiaristas": 300,
  "quantidadeDiaristasPagos": 6,
  "diaria": 50,
  "receitaTotal": 2300,
  "despesasManuais": 500,
  "valorCicloMensal": 300,
  "despesasTotal": 800,
  "saldo": 1500
}

Notas:
- Todos os endpoints de /financeiro exigem perfil "admin" (AdminGuard)
- Valores de mensalista e diária vêm de ConfiguracoesGerais (não mais do ciclo)
- despesasManuais = soma das despesas cadastradas manualmente
- valorCicloMensal = despesa automática vinda de ConfiguracoesGerais
- despesasTotal = despesasManuais + valorCicloMensal
- Campo "pago" no JogadorPartida rastreia se o diarista pagou

Pendente na API: modulo de Sorteio (balanceamento de times com base nas notas). Quando quiser implementar, e so dizer.