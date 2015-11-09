# Description
#   A hubot script to execute phing tasks 
#
# Configuration:
#   HUBOT_PHING_APPS_DIR
#
# Commands:
#   hubot run <task> <app> to|in|on <env>[ with param1=one, param2=two] - executes task in app with specific environment 
#   hubot list phing tasks in <app> - lists all avaliable tasks
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   hubot@gamfi.pl

module.exports = (robot) ->

  robot.respond /run (.*) (.*) (to|in|on) ([^\s]*)( with (.*))?$/i, (msg) ->
    task = msg.match[1]
    app = msg.match[2]
    env = msg.match[4]
    params = msg.match[6]
    appsDir = process.env.HUBOT_PHING_APPS_DIR

    unless robot.auth.hasRole(msg.envelope.user, app + '-deployer')
      msg.reply "I can't do what you ask, you don't have sufficient permission..."
    else
      properties = ""

      if params
      	properties += " -D" + param.trim() for param in  params.split ","

      @exec = require('child_process').exec
      command = "cd #{appsDir}/#{app}; phing -f automation/servers.deploy.xml #{task} -Denv=#{env} -Dapp=#{app} #{properties} -logger phing.listener.DefaultLogger -q"

      msg.reply "Lock and load, executing..."

      @exec command, (error, stdout, stderr) ->
        msg.send stdout
        if stderr
          msg.send "ERROR (stderr): " + stderr
        if error
          msg.send "ERROR (error)" + error

  robot.respond /list phing tasks in (.*)$/i, (msg) ->
    app = msg.match[1]
    appsDir = process.env.HUBOT_PHING_APPS_DIR
    
    unless robot.auth.hasRole(msg.envelope.user, app + '-deployer')
      msg.reply "I can't do what you ask, you don't have sufficient permission..."
    else
      @exec = require('child_process').exec
      command = "cd #{appsDir}/#{app}; phing -f automation/servers.deploy.xml -l -logger phing.listener.DefaultLogger -q"

      msg.reply "Loading please wait..."

      @exec command, (error, stdout, stderr) ->
        msg.send stdout
        if stderr
          msg.send "ERROR (stderr): " + stderr
        if error
          msg.send "ERROR (error)" + error
