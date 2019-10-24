/* formf -- A filter for creating forms */
parse arg template

if .STDIN~chars then call pipe template
else call help
exit

pipe: procedure
  parse arg template
  SIGNAL ON NOTREADY NAME programEnd
  SIGNAL ON ERROR    NAME programEnd
  do forever
    parse pull name type
    if data='' then iterate
    else            call makefield name, type, template
  end
  return

help:
  say 'formf - A filter for creating forms'
  say 'usage: formf [template-name]'
  return

makefield: procedure
  parse arg field, fieldtype, tmpl
  if tmpl='' then do
    say '<div class="form-group">'
    say '  <label for="'field'">'field'</label>'
    say '  <input type="'dbtype2httype(fieldtype)'" id="'field'">'
    say '</div>'
  end
  else say 'merge' tmpl field dbtype2httype(fieldtype)
  return

dbtype2httype: procedure
  arg dbtype
  select
    when abbrev(dbtype, 'INT', 1) then return 'num'
    when abbrev(dbtype, 'DATE', 1) then return 'date'
    when abbrev(dbtype, 'TIME', 1) then return 'time'
    otherwise return 'text'
  end

programEnd:
  exit 0
