-- debugPrint.lua
PRINT_SOURCE = true
CWD = "" -- you can set a global value CWD to current working directory and the log will include it

local print_loggers = {}
local dir = CWD
dir = string.gsub(dir, "\\", "/") .. "/"
local oldprint = print

-- string ops from https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/extensions/string.lua
function string.Explode(separator, str, withpattern)
  if ( separator == "" ) then return totable( str ) end
  if ( withpattern == nil ) then withpattern = false end

  local ret = {}
  local current_pos = 1

  for i = 1, string.len( str ) do
    local start_pos, end_pos = string.find( str, separator, current_pos, not withpattern )
    if ( not start_pos ) then break end
    ret[ i ] = string.sub( str, current_pos, start_pos - 1 )
    current_pos = end_pos + 1
  end

  ret[ #ret + 1 ] = string.sub( str, current_pos )

  return ret
end

function string.split( str, delimiter )
  return string.Explode( delimiter, str )
end

function AddPrintLogger( fn )
  table.insert(print_loggers, fn)
end

-- https://stackoverflow.com/a/7574047/4394850
local function toarray(...)
  return {...}
end

local function _packTable (t, tableRecorder)
  tableRecorder[t] = true
  local str = ""
  -- for small table
  for i,v in ipairs(t) do
    if v then
      if type(v) == "table" then
        if tableRecorder[v] ~= true then
          tableRecorder[v] = true
          str = str.._packTable(v, tableRecorder).."\n"
        else
          str = str.."recursive "..tostring(v).."\n"
        end

      elseif type(v) == "function" then
        -- TODO: get function name or code?
        str = str.."function".."\n"
      else
        str = str..tostring(v).."\n"
      end

    end
  end
  -- TODO for large one use stack
  return str
end

-- e.g. oldprint(packTable(debugstr))
local function packTable(t)
  local rec = {}
  return "\n".._packTable(t, rec)
end

local function pack(v)
  if type(v) == "table" then
    return packTable(v).." "
  elseif type(v) == "function" then
    return "function".." "
  else
    return tostring(v).." "
  end

end


local function packArg(...)
  local str = ""
  local n = select('#', ...)
--  oldprint("n is", n, "for", ...)
  if n > 1 then
    local args = toarray(...)
    for i=1, n do
--          str = str..tostring(arg[i]).."\t"
      str = str..pack(args[i])
    end
    return str
  else
    return pack(...)
  end
end

--this wraps print in code that shows what line number it is coming from, and pushes it out to all of the print loggers
print = function(...)

  local str = ""
  if PRINT_SOURCE then
    local info = debug.getinfo(2, "Sl") -- print function is call stack 1, and the caller is 2
    local source = info and info.source
    if source then
      str = string.format("%s(%d,1) %s", source, info.currentline, packArg(...))
    else
      str = packArg(...)
    end
  else
    str = packArg(...)
  end
--  oldprint("str for loggers:", str)


  for i,v in ipairs(print_loggers) do
    v(str)
  end

end

-- TODO: This is for times when you want to print without showing your line number (such as in the interactive console)
local nolineprint = function(...)
  for i,v in ipairs(print_loggers) do
    v(...)
  end
end

---- This keeps a record of the last n print lines, so that we can feed it into the debug console when it is visible
local debugstr = {}
local MAX_CONSOLE_LINES = 20

local consolelog = function(...)

  local str = packArg(...)
  str = string.gsub(str, dir, "")

  for idx,line in ipairs(string.split(str, "\r\n")) do
    table.insert(debugstr, line)
  end

  while #debugstr > MAX_CONSOLE_LINES do
    table.remove(debugstr,1)
  end
end

local textlog = function (...)
  oldprint(...)
end


function GetConsoleOutputList()
  return debugstr
end

-- add our print loggers
-- AddPrintLogger(consolelog)
AddPrintLogger(textlog)
