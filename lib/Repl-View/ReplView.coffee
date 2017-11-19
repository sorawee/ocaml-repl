fs = require 'fs'
REPL  = require '../Repl/ReplClass'
REPLPython  = require '../Repl/ReplClassPython'
REPLFormat = require '../Repl/ReplFormat'
ansiRegex = require 'ansi-regex'
{CompositeDisposable} = require 'event-kit'
clone = require 'clone'


module.exports =
class REPLView
  dealWithInsert: (event) =>
    buf = @replTextEditor.getSelectedBufferRange().start
    if @lastBuf.row > buf.row or (@lastBuf.row == buf.row and @lastBuf.column > buf.column)
      event.cancel()

  interprete: (select) =>
    @repl.writeInRepl select, true

  remove: =>
    @subscribe.clear()
    @repl.remove()

  dealWithBackspace: (event) =>
    buf = @replTextEditor.getSelectedBufferRange().start
    if @lastBuf.row > buf.row or (@lastBuf.row == buf.row and @lastBuf.column >= buf.column)
      event.stopImmediatePropagation()

  dealWithDelete: (event) =>
    '''Gerer suppression text Selection'''
    buf = @replTextEditor.getSelectedBufferRange().start
    if @lastBuf.row > buf.row or (@lastBuf.row == buf.row and @lastBuf.column > buf.column)
      event.stopImmediatePropagation()

  dealWithEnter: =>
    @replTextEditor.moveToBottom()
    @replTextEditor.moveToEndOfLine()
    buf = @replTextEditor.getCursorBufferPosition()
    @repl.writeInRepl(@replTextEditor.getTextInBufferRange([@lastBuf, buf]) + '\n', false)
    @lastBuf = buf


  setGrammar: =>
    grammars = atom.grammars.getGrammars()
    gName = if @grammarName == 'Node' then 'JavaScript' else @grammarName
    for grammar in grammars
      if grammar.name == gName
        # change the scopeName so that other packages (namely the atom-linter package [https://atom.io/packages/linter]) stop making invalid actions;
        # see https://github.com/steelbrain/linter/issues/1207
        grammarToUse = clone.clonePrototype grammar
        grammarToUse.scopeName = 'repl.' + grammarToUse.scopeName;
        @replTextEditor.setGrammar grammarToUse
        return

  dealWithUp: (e) =>
    e.stopImmediatePropagation()
    @replTextEditor.moveToEndOfLine()
    @repl.history true

  dealWithDown: =>
    @replTextEditor.moveToEndOfLine()
    @repl.history false

  setTextEditor: (textEditor) =>
    @replTextEditor = textEditor
    #@replTextEditor.onDidChangeCursorPosition(@dealWithBuffer)
    #@replTextEditor.onWillInsertText(@dealWithEnter)
    @subscribe.add @replTextEditor.onWillInsertText(@dealWithInsert)
    @subscribe.add textEditorElement = atom.views.getView @replTextEditor
    @subscribe.add atom.commands.add textEditorElement, 'editor:newline': => @dealWithEnter()
    @subscribe.add atom.commands.add textEditorElement, 'core:move-up': @dealWithUp
    @subscribe.add atom.commands.add textEditorElement, 'core:move-down': => @dealWithDown()
    @subscribe.add atom.commands.add textEditorElement, 'core:backspace': @dealWithBackspace
    @subscribe.add atom.commands.add textEditorElement, 'core:delete': @dealWithDelete
    @setGrammar()

  setRepl: (repl) => @repl = repl

  dealWithRetour: (data, append) =>
    if append
      newData = "" + data
      matches = newData.match ansiRegex()
      underlined = false

      if matches?
        matches.forEach (match) =>
          if match.endsWith '[4m'
            newData = newData.replace match, '❰❰❰❰❰'
            underlined = true
          else if underlined and match.endsWith '[24m'
            newData = newData.replace match, '❱❱❱❱❱'
            underlined = false
          else
            newData = newData.replace match, ''

      @replTextEditor.insertText newData
      @lastBuf = @replTextEditor.getCursorBufferPosition()
    else
      '''
      à amélioré , (saut de ligne et string vide etc...)
      '''
      @replTextEditor.moveToBottom()
      @replTextEditor.moveToEndOfLine()
      buf = @replTextEditor.getCursorBufferPosition()
      @replTextEditor.setTextInBufferRange([@lastBuf,buf],(""+data),select = true)
      #@replTextEditor.moveBottom(1)
      #@replTextEditor.selectToBeginningOfLine()
      #console.log(@replTextEditor.getSelectedText())
      #@replTextEditor.moveToEndOfLine()
      #@lastBuf = @replTextEditor.getCursorBufferPosition()

  constructor: (@grammarName, file, callBackCreate) ->
    @subscribe = new CompositeDisposable
    format = new REPLFormat("../../Repls/" + file)
    @lastBuf = 0
    uri = "REPL: " + @grammarName
    opts = split: 'right' if atom.config.get 'Repl.splitRight'
    atom.workspace.open(uri, opts).done (textEditor) =>
      pane = atom.workspace.getActivePane()
      @setTextEditor textEditor
      if @grammarName == "Python Console3" or @grammarName == "Python Console2" or @grammarName == "Python"
        @grammarName = "Python Console"
        @setRepl(new REPLPython(format, @dealWithRetour))
      else
        @setRepl(new REPL(format, @dealWithRetour))
      callBackCreate this, pane
