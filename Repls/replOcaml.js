ansiRegex = require('ansi-regex')

module.exports =
cmd = atom.config.get('ocaml-repl.ocaml')
prompt = ''
promptCont = '  '
args = ['-nopromptcont']
endSequence = ';;\n'
outErrorIntercept = out => {
  const lines = out.trim().split('\n');
  const hasError = lines.some(line => {
    const matches = line.match(ansiRegex());
    return (matches && matches.length > 0 && matches[0].endsWith('[24m') &&
     line.replace(matches[0], '').startsWith('Error:') &&
     !line.startsWith('Error:'));
  });
  if (hasError) return true;
  if (lines.length >= 2) {
    const lastLine = lines[lines.length - 2];
    return lastLine.endsWith('.') && lines.some(line => line.startsWith('Exception:'));
  }
  return false;
}
