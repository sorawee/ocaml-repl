fs = require 'fs'
child_process = require 'child_process'
ansiRegex = require 'ansi-regex'

module.exports =
class Repl
    remove: () ->
      console.log("kill Repl")
      @replProcess.kill('SIGKILL')

    processCmd: ()->
      @indiceH = -1
      # @retour(@prompt, true) if @processing # show prompt
      if @cmdQueue.length > 0 # list of cmd to execute
        @processing = true
        cmd = @cmdQueue.shift()
        @replProcess.stdin.write(cmd[0]) # send cmd to pipe
        if cmd[0].slice(-@endSequence.length) != @endSequence
          # if not ending with end sequence execute next one
          @processing = false
          @processCmd() #
      else
        @processing = false

    history: (up) ->
      @indiceH = @indiceH + 1 if up and @historique.length - 1 > @indiceH
      @indiceH = @indiceH - 1 if not up and @indiceH >= 0
      if @indiceH == -1
        @retour('', false)
        return
      h = @historique[@indiceH]
      h = h.substring(0, h.length - 1) # trim newline away
      @retour(h, false)

    processOutputData: (data) ->
      @print += "" + data
      @retour(@print, true)
      
      (@print.split '\n').forEach (line) =>
        matches = line.match ansiRegex()
        if (matches? and matches.length > 0 and
             matches[0].endsWith('[24m') and
             line.replace(matches[0], '').startsWith('Error: ') and
             not line.startsWith('Error: '))
          @cmdQueue = []
      @print = ""
      @processCmd()

    processErrorData: (data) ->
      @print += "" + data
      process.stderr.write @print
      @print = ""
      @processCmd()

    closeRepl: (code) ->
      console.log('child process exited with code ' + code)

    writeInRepl: (cmd, write_cmd) ->
      if write_cmd
        cmd = cmd + @endSequence if cmd.slice(-@endSequence.length) != @endSequence
        (cmd.split @endSequence).forEach (line) => 
          @cmdQueue.push [line + @endSequence, write_cmd] if line.trim() != ""
      else
        @historique.unshift cmd
        @cmdQueue.push [cmd, write_cmd]
      @processCmd() unless @processing

    constructor: (r_format, @retour) ->
      @historique = new Array()
      @indiceH = -1
      @processing = true
      @cmd = r_format.cmd
      args = r_format.args
      @prompt = r_format.prompt
      @endSequence = r_format.endSequence
      @print = ""
      @cmdQueue = new Array()
      @replProcess = child_process.spawn(cmd, args)
      @replProcess.stdout.on('data', (data) => @processOutputData data)
      @replProcess.stderr.on('data', (data) => @processErrorData data)
      @replProcess.on('close', () => @closeRepl())
      @retour(@print, true)

'''
sh = new ReplSh()
ocaml = new ReplOcaml()

myrepl = new Repl(ocaml)
myrepl.writeInRepl('let a l = match l with\n')
myrepl.writeInRepl("| _ -> true;;\n")
#myrepl.writeInRepl("let _ = 3*2;;\n")
'''
