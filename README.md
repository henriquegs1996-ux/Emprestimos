# Controle de Empréstimos Web

Projeto inicial para GitHub Pages + Supabase, com login, clientes, empréstimos, parcelas, pagamentos parciais, alertas e relatórios.

## Configuração

1. Crie um projeto no Supabase.
2. No SQL Editor do Supabase, execute todo o arquivo `schema.sql`.
3. Em Authentication → URL Configuration, configure a URL do site do GitHub Pages como Site URL e adicione-a em Redirect URLs.
4. Abra `index.html` e substitua:
   - `COLE_AQUI_A_URL_DO_SUPABASE` pela Project URL;
   - `COLE_AQUI_A_CHAVE_PUBLICAVEL_DO_SUPABASE` pela chave publicável (anon/publishable) do projeto.
5. Envie `index.html` e `schema.sql` para um repositório GitHub.
6. Em Settings → Pages, publique a branch e a pasta que contém `index.html`.
7. Abra o link publicado, crie a conta e confirme o e-mail, se a confirmação estiver habilitada.

## Segurança

- Nunca coloque a chave `service_role` no HTML ou no GitHub.
- Mantenha RLS habilitado; o `schema.sql` cria políticas para cada usuário acessar somente seus próprios registros.
- CPF, RG, endereço e dados financeiros são dados pessoais. Limite o acesso, use senha forte, habilite confirmação de e-mail e avalie os requisitos da LGPD.
- A versão inicial guarda os campos pessoais diretamente no banco. Não insira dados reais antes de testar a configuração de segurança e o fluxo completo.

## Funcionalidades da versão inicial

- Login e cadastro por e-mail/senha.
- Cadastro de clientes.
- Cadastro de empréstimos com parcelas geradas por periodicidade.
- Registro de pagamentos parciais.
- Dashboard de totais e alertas de parcelas vencidas/que vencem hoje.
- Estimativa de juros diários por percentual ou valor fixo.
- Relatórios e impressão/salvamento como PDF pelo navegador.

## Limitações a revisar antes do uso real

Esta é uma versão inicial, não um sistema financeiro auditado. O cálculo de juros é uma estimativa simples, sem capitalização; valide as regras legais aplicáveis. Os pagamentos parciais atualizam a parcela selecionada, e os registros precisam de testes de consistência. A versão inicial não tem edição/exclusão de registros nem notificações fora do site. Alertas aparecem quando o usuário abre o sistema. Faça testes com dados fictícios antes de inserir informações pessoais.
