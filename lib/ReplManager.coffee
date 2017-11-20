REPLView = require './Repl-View/ReplView'
dico = require "./ReplList.js"


module.exports =
class ReplManager

  constructor: () ->
    @map = {}
    Object.keys(dico).forEach (k) => @map[k] = null;

  interprete : (select, grammarName) =>
    replView = @map[grammarName]
    if replView?
      replView.interprete select
    else
      console.log("error interprete")

  grammarNameSupport : (grammarName) ->
      return dico[grammarName]?

  callBackCreate: (replView, pane) =>
    @map[replView.grammarName] = replView

    # pane.onDidActivate(=>
    #   if pane.getActiveItem() == replView.replTextEditor
    #     @map[replView.grammarName] = replView
    #
    #   )
    replView.replTextEditor.onDidDestroy(=>
      if @map[replView.grammarName] == replView
        @map[replView.grammarName] = null
        replView.remove()
      )

  createRepl: (grammarName) =>
    if @grammarNameSupport(grammarName)
      @map[grammarName] = new REPLView(grammarName, dico[grammarName], @callBackCreate)
    else
      console.log("grammar error")
