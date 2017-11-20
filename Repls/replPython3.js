module.exports =
cmd = atom.config.get('ocaml-repl.python3')
prompt = ""
args = ["-i"]
endSequence = '\n'
outErrorIntercept = out => {
  return false;
}
