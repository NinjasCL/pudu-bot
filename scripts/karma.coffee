# Description:
#   A simple karma tracking script for hubot.
#
# Commands:
#   <name>++ - adds karma to a user
#   <name>-- - removes karma from a user
#   karma <name> - shows karma for the named user
#   karma todos|all - shows all users' karama
#   karma - shows all users' karama
#
# Adaptado para pudu por @clsource Camilo Castro
#  Basado en
#   https://www.npmjs.com/package/hubot-karma

module.exports = (robot) ->

  robot.hear /^@?(.*?)(\+\+|--)\s*$/, (response) ->
    thisUser = response.message.user
    targetToken = response.match[1].trim()
    return if not targetToken
    targetUser = userForToken targetToken, response
    return if not targetUser
    return response.send "Oe no po, el karma es pa otros no pa ti!" if thisUser is targetUser
    op = response.match[2]
    targetUser.karma += if op is "++" then 1 else -1
    response.send "#{targetUser.name} ahora tiene #{targetUser.karma} puntos de karma."

  robot.hear /^karma(?:\s+@?(.*))?$/, (response) ->
    targetToken = response.match[1]?.trim()
    if not targetToken? or targetToken.toLowerCase() is "todos" or "all"
      users = robot.brain.users()
      list = Object.keys(users)
        .sort()
        .map((k) -> [users[k].karma or 0, users[k].name])
        .sort((line1, line2) -> if line1[0] < line2[0] then 1 else if line1[0] > line2[0] then -1 else 0)
        .map((line) -> line.join " ")
      msg = "Karma de todos:\n#{list.join '\n'}"
    else
      targetUser = userForToken targetToken, response
      return if not targetUser
      msg = "#{targetUser.name} tiene #{targetUser.karma} puntos de karma."
    response.send msg

  userForToken = (token, response) ->
    users = usersForToken token
    if users.length is 1
      user = users[0]
      user.karma ?= 0
    else if users.length > 1
      response.send "Se más específico, Hay #{users.length} personas que se parecen a: #{(u.name for u in users).join ", "}."
    else
      response.send "Chaucha, no encuentro al usuario '#{token}'."
    user

  usersForToken = (token) ->
    user = robot.brain.userForName token
    return [user] if user
    user = userForMentionName token
    return [user] if user
    robot.brain.usersForFuzzyName token

  userForMentionName = (mentionName) ->
    for id, user of robot.brain.users()
      return user if mentionName is user.mention_name
