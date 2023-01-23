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
local file = io.open("teste.txt", "r")

-- Checa se ele foi aberto
if file then
  -- Le o arquivo todo e armazena ele na variavel content
    content = file:read("*a")
    -- a recebe a tabela de tokens do arquivo
    a = tokenize(content)
    process_tokens(a)
    
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

str = tostring_custom(a)
print(#a)

-- Abre o arquivo
local file = io.open("teste2.txt", "a")

-- Checa se ele foi aberto
if file then
  -- Insere a string no final do arquivo
  file:write(str)

  -- Fecha o arquvio
  file:close()
else
  -- Mensagem de erro
  print("Erro: nao foi possivel abrir o arquivo")
end
