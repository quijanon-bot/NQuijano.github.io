-- Incluye código desde los archivos del repositorio (misma fuente que las notas).
-- Uso en un .qmd:
--   ```{.matlab include="../../codigo/cap10.../C1_Ej1.m" marca="senoide"}
--   ```
-- Sin "marca" incluye el archivo completo. Las marcas son líneas
--   % [ini:nombre]   ...   % [fin:nombre]
-- igual que en LaTeX (\codigorepo).
function CodeBlock(el)
  local ruta = el.attributes["include"]
  if not ruta then return nil end
  local f = io.open(ruta, "r")
  if not f and PANDOC_STATE and PANDOC_STATE.input_files[1] then
    local dir = PANDOC_STATE.input_files[1]:match("^(.*)/[^/]*$")
    if dir then f = io.open(dir .. "/" .. ruta, "r") end
  end
  if not f then
    el.text = "% No se encontró " .. ruta
    return el
  end
  local marca = el.attributes["marca"]
  local lineas, dentro = {}, (marca == nil)
  for l in f:lines() do
    if marca and l:match("%%%s*%[ini:" .. marca .. "%]") then
      dentro = true
    elseif marca and l:match("%%%s*%[fin:" .. marca .. "%]") then
      dentro = false
    elseif dentro then
      if marca or not l:match("^%s*%%%s*%[[if][ni][in]:") then
        table.insert(lineas, l)
      end
    end
  end
  f:close()
  el.text = table.concat(lineas, "\n")
  el.attributes["include"] = nil
  el.attributes["marca"] = nil
  if not el.attributes["filename"] then
    el.attributes["filename"] = ruta:gsub("^.*/codigo/", "")
  end
  return el
end
