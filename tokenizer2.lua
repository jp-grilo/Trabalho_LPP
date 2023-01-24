-- Lista de keywords
keywords = { "class", "method", "begin", "self", "vars", "end", "end-method", "end-class", "if", "else", "return", "eq", "ne", "lt", "le", "gt", "ge", "new", "io" }

-- função pra transformar a string em token
function tokenize(input)
  -- Inicializa uma tabela pra armazenar os tokens
  local tokens = {}
  
  local pos = 1

  -- Enquanto a posição atual for menor/igual que o tamanho da string
  while pos <= #input do
    -- Pega o proximo caracter na string
    local c = input:sub(pos, pos)

    -- Se o proximo caracter for uma letra ou um _
    if c:match("[a-zA-Z_]") then
      -- Inicializa a variavel para armazenar o token
      local token = ""

      -- Enquanto o caracter atual for uma letra, underscore ou digito
      while c:match("[a-zA-Z_0-9]") do
        -- Adiciona um caracter ao token atual
        token = token .. c

        -- Move para o proximo caracter
        pos = pos + 1
        c = input:sub(pos, pos)
      end

      -- Checa se o token atual é uma keyword dupla end-class, etc
      while token:sub(-1) == "-" do
        -- Concatena o token atual com o proximo token
        local next_token = input:match("^[a-zA-Z_]+", pos + 1)
        if not next_token then
          break
        end
        token = token .. next_token
        pos = pos + #next_token
      end

      -- Checa se o token atual é uma keyword
      local is_keyword = false
      for i, keyword in ipairs(keywords) do
        if token == keyword then
          is_keyword = true
          break
        end
      end
      if is_keyword then
        --  Se é uma keyword é adicionada na tabela como uma keyword
        table.insert(tokens, { type = "keyword", value = token })
      else
        --  Se não é uma keyword é adicionada na tabela como um identifier
        table.insert(tokens, { type = "identifier", value = token })
      end
    -- Se o caracter for um digito
    elseif c:match("[0-9]") then
      -- Inicializa a variavel para armazenar na tabela
      local token = ""

      -- Enquanto o caracter for um digito
      while c:match("[0-9]") do
        -- Adiciona o caracter atual
        token = token .. c

        -- Move para o proximo caracter
        pos = pos + 1
        c = input:sub(pos, pos)
      end

      -- Adiciona o token na tabela de tokens com o alias number
      table.insert(tokens, { type = "number", value = tonumber(token) })
          -- Se o caracter tem um espaço
    elseif c:match("%s") then
      -- Incrementa a posicao
      pos = pos + 1
    -- Se o caracter for um simbolo
    else
     -- Inicializa a variavel para armazenar na tabela
      local token = ""

     -- Enquanto o caracter for um simbolo
      while c:match("[^a-zA-Z_0-9%s]") do
        -- Adiciona o caracter ao token
        token = token .. c

        -- Move para a proxima posicao
        pos = pos + 1
        c = input:sub(pos, pos)
      end

      -- Checa se o token é uma keyword
      local is_keyword = false
      for i, keyword in ipairs(keywords) do
        if token == keyword then
          is_keyword = true
          break
        end
      end
      if is_keyword then
        -- Se é uma keyword é adicionada na tabela como uma keyword
        table.insert(tokens, { type = "keyword", value = token })
      else
        -- Se não é uma keyword é adicionada na tabela como um symbol
        table.insert(tokens, { type = "symbol", value = token })
      end
    end
  end

  -- Retorna a tabela de tokens
  return tokens
end

--local input = tokenize('class Base vars id method showid() begin self.id = 10 io.print(self.id) return 0 end-method end-class') 

function process_tokens(tokens)
  -- Itera pela tabela de tokens
  for i, token in ipairs(tokens) do
    -- Printa o tipo e o valor do token atual
    print(string.format("Token %d: type = %s, value = %s", i, token.type, token.value))
  end
end

--print(process_tokens(input))

-- Abre o arquivo

local file_name = arg[1]
local file = io.open(file_name, "r")

-- Checa se ele foi aberto
if file then
  -- Le o arquivo todo e armazena ele na variavel content
    content = file:read("*a")
    -- a recebe a tabela de tokens do arquivo
    TabelaDeTokens = tokenize(content)

  -- Fecha o arquivo
  file:close()
else
  -- Mensagem de erro
  print("Erro: Nao foi possivel abrir o arquivo")
end

-- funcao para transformar a tabela em string pra salvar em um arquivo
local function tostring_custom(value)
  if type(value) == 'table' then
    local result = '{'
    for k, v in pairs(value) do
      result = result .. ' ' .. tostring_custom(k) .. ' = ' .. tostring_custom(v) .. ','
    end
    result = result .. ' }'
    return result
  else
    return tostring(value)
  end
end

str = tostring_custom(TabelaDeTokens)

print(str)

-- Abre o arquivo
local file = io.open("teste1.txt", "a")

-- Checa se ele foi aberto
if file then
  -- Insere a string no final do arquivo
  file:write(str)

  -- Fecha o arquivo
  file:close()
else
  -- Mensagem de erro
  print("Erro: nao foi possivel abrir o arquivo")
end

print(#TabelaDeTokens)


-- Tabelas padrão



-- Inicio do processamento da tabela

Iterador = 1


--Cria table com as variáveis do método
local function CriaVariaveis()
  local Variaveis = {}
  Iterador=Iterador+1
  -- Loop pro caso de o próximo token ser ",", o que garante que o token subsequente será outro atributo
  while TabelaDeTokens[Iterador+1]["value"] == "," do
    Variaveis[TabelaDeTokens[Iterador]["value"]] = 0
    Iterador=Iterador+2
  end
  -- Pega o último atributo da classe, o qual não é sequigo de ","
  Variaveis[TabelaDeTokens[Iterador]["value"]] = 0
  Iterador=Iterador+1
  --Retorna a tabela de variáveis para a tabela de Metodos
  return Variaveis
end

-- Cria table com os parâmetros do método
local function CriaParametros()
  local Parametros = {}
  Iterador=Iterador+1
  -- Enquanto não acharmos ")", quer dizer que teremos outro parâmetro para ser processado 
  while TabelaDeTokens[Iterador+1]["value"] ~= ")" do
    Parametros[TabelaDeTokens[Iterador]["value"]]=0
    Iterador=Iterador+2
  end
  -- Pega o último parâmetro do método, o qual é sequigo de ")"
    Parametros[TabelaDeTokens[Iterador]["value"]]=0
    Iterador=Iterador+1
  return Parametros
end

-- Cria os métodos
local function CriaMetodos()
  local Metodos = {}
  local Metodo = {}

  -- Loop para que todos os metodos sejam pegos, caso ao fim desse loop resulte em um token diferente, sabemos que findamos todos os métodos da classe
  while TabelaDeTokens[Iterador]["value"] == "method" do
    Iterador=Iterador+1

    Metodo["Nome"] = TabelaDeTokens[Iterador]["value"]
    
    Iterador=Iterador+1
    --Caso o token seja "()", o método não tem parâmtros
    if TabelaDeTokens[Iterador]["value"] ~= "()" then
      -- Recebe uma tabela com todos os parâmetros do método como valor para a chave "parametros"
      Metodo["parametros"] = CriaParametros()
    else 
      Metodo["parametros"] = {}
    end

    Iterador=Iterador+1
    -- Caso seja encontrado o token "vars", o método possui variáveis próprias
    if TabelaDeTokens[Iterador]["value"] == "vars" then
      -- Recebe uma tabela com todos as variáveis do método como valor para a chave "variaveis"
      Metodo["variaveis"] = CriaVariaveis()
    else
      Metodo["variaveis"] = {}
    end
  
    -- Adiciona o método processado à tabela de Metodos, a qual acessará cada método pelo seu nome
    Metodos["Nome"] = Metodo
    
    -- Procura pelo fim do método, já que não há mais nada para ser armazenado nas tabelas mencionadas
    while TabelaDeTokens[Iterador]["value"] ~= "end" do
      Iterador=Iterador+1
    end
    Iterador=Iterador+3
  end
  -- Retorna a tabela com todos os Metodos para a tabela de Classe
  return Metodos
end

-- Cria os atributos da classe
local function CriaAtributos()
  local Atributos = {}
  Iterador=Iterador+1
  -- Loop pro caso de o próximo token ser ",", o que garante que o token subsequente será outro atributo
  while TabelaDeTokens[Iterador+1]["value"] == "," do
    Atributos[TabelaDeTokens[Iterador]["value"]] = 0
    Iterador=Iterador+2
  end
  -- Pega o último atributo da classe, o qual não é sequigo de ","
  Atributos[TabelaDeTokens[Iterador]["value"]] = 0
  Iterador=Iterador+1
  -- Retorna a tabela com todos os Atributos para a Tabela de Classe
  return Atributos
end


local function CriaClasses()
  local Classes = {}
  local CorpoDaClasse = {}

  while TabelaDeTokens[Iterador]["value"] == "class" do 
    
    CorpoDaClasse["Nome"] = TabelaDeTokens[Iterador]["value"]
    Iterador=Iterador+1
    
    --Atributos: se o token atual for igual a "vars", iremos pra uma função onde serão criadas as variáveis
    if TabelaDeTokens[Iterador]["value"] == "vars" then 
      CorpoDaClasse["Atributos"] = CriaAtributos()
    end
  
    --Metodos: se o token atual for igual a "method", iremos pra uma função onde serão criados os metodos
    if TabelaDeTokens[Iterador]["value"] == "method" then 
      CorpoDaClasse["Metodos"] = CriaMetodos()
    end
    
    -- Adiciona a Classe processada à tabela de Classes, a qual acessará cada classe pelo seu nome
    Classes[CorpoDaClasse["Nome"]] = CorpoDaClasse

    -- Procura pelo fim da classe, já que não há mais nada para ser armazenado nas tabelas mencionadas
    while TabelaDeTokens[Iterador]["value"] ~= "end" do
      Iterador=Iterador+1
    end
    Iterador=Iterador+3

  end
  -- Retorna a tabela com as classes para a tabela de Classes do programa
  return Classes
end


local function CriarClasses() 
  while
end


while Iterador < #TabelaDeTokens do
  local ClassesDoPrograma = {}
  while TabelaDeTokens[Iterador]["value"] == "class" do
    ClassesDoPrograma=CriaClasse()
  end
end