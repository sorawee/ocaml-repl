#MyREPLView = require './Repl-view'
REPLView = require './Repl-View/ReplView'
REPLManager = require './ReplManager'
$ = require 'jquery'
{CompositeDisposable} = require 'atom'

REPL_NAME = 'REPL: OCaml'
delay = (ms, func) -> setTimeout func, ms

module.exports = MyREPL =

config:
    ocaml:
      type: 'string'
      title: 'Ocaml'
      default: 'ocaml'
      description: 'path to ocaml'
    splitRight:
      type: 'boolean'
      title: 'Open Repl in the rightmost pane'
      default: true
      description: 'Whether to open Repl editor in rightmost pane'

  #myREPLView: null
  #modalPanel: null
  subscriptions: null

  activate: (state) ->
    console.log("activate Repl")
    @map = new Array()
    @replManager = new REPLManager()
    #@myREPLView = new MyREPLView(state.myREPLViewState)
    #@modalPanel = atom.workspace.addRightPanel(item: @myREPLView.getElement(), visible: false)

     #Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

     # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'Repl:Repl Python2': => @create("Python Console2")
    @subscriptions.add atom.commands.add 'atom-workspace', 'Repl:Repl Python3': => @create("Python Console3")
    @subscriptions.add atom.commands.add 'atom-workspace', 'Repl:Repl Coffee': => @create("CoffeeScript")
    @subscriptions.add atom.commands.add 'atom-workspace', 'Repl:Repl Bash': => @create('Shell Session')
    @subscriptions.add atom.commands.add 'atom-workspace', 'Repl:Repl Ocaml': => @create('OCaml')
    @subscriptions.add atom.commands.add 'atom-workspace', 'Repl:Repl Octave': => @create('Octave')
    @subscriptions.add atom.commands.add 'atom-workspace', 'Repl:Repl R': => @create('R')
    @subscriptions.add atom.commands.add 'atom-workspace', 'Repl:Repl Node': => @create('Node')
    @subscriptions.add atom.commands.add 'atom-workspace', 'Repl:Repl Gdb': => @create('C')
    @subscriptions.add atom.commands.add 'atom-workspace', 'Repl:Repl Swift': => @create('Swift')

    @subscriptions.add atom.commands.add 'atom-workspace', 'Repl:create': => @create()
    @subscriptions.add atom.commands.add 'atom-workspace', 'Repl:interpreteSelect': => @interpreteSelect()
    @subscriptions.add atom.commands.add 'atom-workspace', 'Repl:interpreteFile': => @interpreteFile()
    #@subscriptions.add atom.commands.add 'REPL', 'Repl:up': => @up()

  deactivate: ->
    #@modalPanel.destroy()
    @subscriptions.clear()
    @subscriptions.dispose()
    #@myREPLView.destroy()

  serialize: ->
    #myREPLViewState: @myREPLView.serialize()

  create: (grammarName) ->
    atom.workspace
      .getTextEditors()
      .filter (editor) -> editor.getTitle() == REPL_NAME
      .forEach (editor) -> editor.destroy()
      
    if(!grammarName?)
      if atom.workspace.getActiveTextEditor()?
        grammarName = atom.workspace.getActiveTextEditor().getGrammar().name
      else
        console.log("erreur1")
        grammarName = 'Shell Session'

    @replManager.createRepl(grammarName)
    #@map.push([txtEditor,new REPLView(txtEditor)])

  interpreteSelect: ->
    txtEditor = atom.workspace.getActiveTextEditor()
    if txtEditor?
      grammarName = txtEditor.getGrammar().name
      #@replManager.createRepl(grammarName)
      @replManager.interprete(txtEditor.getSelectedText(), grammarName)
    else
      console.log("error interpreteSelect")

  interpreteFile: ->
    editors = atom.workspace.getTextEditors()
    return if editors.length is 1 and atom.workspace.getActiveTextEditor().getTitle == REPL_NAME
    
    editors
      .filter (editor) -> editor.getTitle() == REPL_NAME
      .forEach (editor) -> editor.destroy()
    
    txtEditor = atom.workspace.getActiveTextEditor()
    if txtEditor?
      grammarName = txtEditor.getGrammar().name
      @replManager.createRepl grammarName
      delay 100, =>
        @replManager.interprete(txtEditor.getText(), grammarName)
        pane = atom.workspace.paneForItem txtEditor
        pane.activate()
    else
      console.log("error interpreteFile")
