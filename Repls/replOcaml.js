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
    // assumption: all runtime error ends with
    // dot on the last line
    const lastLine = lines[lines.length - 2];
    // from https://caml.inria.fr/pub/docs/manual-ocaml/comp.html#s%3Acomp-errors
    return lastLine.endsWith('.') && lines.some(line => ['Cannot find file', 'Corrupted compiled interface', 'Reference to undefined global', 'The external function', 'Exception:'].some(err => line.startsWith(err)));
  }
  return false;
}
