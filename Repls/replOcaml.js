ansiRegex = require('ansi-regex')

module.exports =
cmd = atom.config.get('Repl.ocaml')
prompt = ''
args = []
endSequence = ';;\n'
outErrorIntercept = out => {
  const lines = out.trim().split('\n');
  if (lines.length >= 2) {
    const lastLine = lines[lines.length - 2];
    const matches = lastLine.match(ansiRegex());
    return (matches && matches.length > 0 && matches[0].endsWith('[24m') &&
     lastLine.replace(matches[0], '').startsWith('Error: ') &&
     !lastLine.startsWith('Error: ')) ||
     (lastLine.startsWith('Exception: ') && lastLine.endsWith('.'))
  }
  return false;
}
