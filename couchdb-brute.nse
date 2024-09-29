author = "llenzzz"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"intrusive", "brute"}

local colors = {
  red = "\27[31m",
  green = "\27[32m",
  yellow = "\27[33m",
  reset = "\27[0m"
}

function successful(combination, log_file_path)
  local log_file = io.open(log_file_path, "r")
  if log_file then
    for line in log_file:lines() do
      if line == combination then
        log_file:close()
        return true
      end
    end
    log_file:close()
  end
  return false
end

function log(combination, log_file_path)
  local log_file = io.open(log_file_path, "a")
  if log_file then
    log_file:write(combination .. "\n")
    log_file:close()
  else
    print(colors.red .. "Error: Unable to open " .. log_file_path .. colors.reset)
  end
end

function delete(user, user_file_path)
  local user_file = io.open(user_file_path, "r")
  if user_file then
    local lines = {}
    for line in user_file:lines() do
      if line ~= user then
        table.insert(lines, line)
      end
    end
    user_file:close()

    local new_file = io.open(user_file_path, "w")
    for _, line in ipairs(lines) do
      new_file:write(line .. "\n")
    end
    new_file:close()
  else
    print(colors.red .. "Error: Unable to open " .. user_file_path .. colors.reset)
  end
end

portrule = function(host, port)
  return port.number == 5984
end

action = function(host, port)
  local nmap = require "nmap"
  local http = require "http"

  local user_file_path = nmap.registry.args.user_file
  local pass_file_path = nmap.registry.args.pass_file
  local log_file_path = "/tmp/log.txt"

  if not user_file_path or user_file_path == "" then
    user_file_path = "./users.txt"
  end

  if not pass_file_path or pass_file_path == "" then
    pass_file_path = "./pass.txt"
  end

  local user_file = io.open(user_file_path, "r")
  local users = {}
  if user_file then
    for line in user_file:lines() do
      table.insert(users, line)
    end
    user_file:close()
  else
    print(colors.red .. "Error: Unable to open " .. user_file_path .. colors.reset)
    users = {"admin"}
  end

  local pass_file = io.open(pass_file_path, "r")
  local passwords = {}
  if pass_file then
    for line in pass_file:lines() do
      table.insert(passwords, line)
    end
    pass_file:close()
  else
    print(colors.red .. "Error: Unable to open " .. pass_file_path .. colors.reset)
    passwords = {"password"}
  end

  local log_file = io.open(log_file_path, "r")
  if not log_file then
    local new_file = io.open(log_file_path, "w")
    new_file:close()
  end

  for _, user in ipairs(users) do
    for _, password in ipairs(passwords) do
      local combination = user .. ":" .. password
      if not successful(combination, log_file_path) then
        local result = http.get(host, port.number, "/_utils", {auth={username=user, password=password}})
        if result.status == 200 then
          print(colors.green .. "\nCouchDB authentication successful for " .. combination .. colors.reset)
          log(combination, log_file_path)
          delete(user, user_file_path)
          return
        else
          print("CouchDB authentication failed for " .. combination)
        end
      end
    end
    delete(user, user_file_path)
  end
  print(colors.green .. "\nFinished running through all possible user/password combinations." .. colors.reset)
end
