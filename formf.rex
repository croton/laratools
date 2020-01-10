/* formf -- A filter for creating forms */
parse arg template

tmpl=.nil
if template<>'' then do
  if SysFileExists(template) then tmpl=.stream~new(template)~arrayin
  else say 'Template not found:' template
end

if .STDIN~chars then call pipe tmpl
else call help
exit

pipe: procedure
  use arg tmplR
  SIGNAL ON NOTREADY NAME programEnd
  SIGNAL ON ERROR    NAME programEnd
  do forever
    parse pull name type
    if data='' then iterate
    else if tmplR=.nil then call makefield name, type
    else                    call mergefield name, type, tmplR
  end
  return

help:
  say 'formf - A filter for creating forms'
  say 'usage: formf [template-name]'
  say 'supported field types: int, date, time, text (default)'
  return

makefield: procedure
  parse arg field, fieldtype
  say '<div class="form-group">'
  say '  <label for="'field'">'field'</label>'
  say '  <input type="'dbtype2httype(fieldtype)'" id="'field'">'
  say '</div>'
  return

mergefield: procedure
  use arg field, fieldtype, tmplR
  newR=merge(tmplR, .array~of(field, dbtype2httype(fieldtype)))
  loop item over newR
    say item
  end
  return

dbtype2httype: procedure
  arg dbtype
  select
    when abbrev(dbtype, 'INT', 1) then return 'num'
    when abbrev(dbtype, 'DATE', 1) then return 'date'
    when abbrev(dbtype, 'TIME', 1) then return 'time'
    otherwise return 'text'
  end

-- Merge replacement values into a collection of text
merge: procedure
  use arg template, newvalues
  merged=.array~new
  do line=1 to template~last
    src=template[line]
    if src~pos('?')>0 then
      do argno=1 to newvalues~last
        src=src~changestr('?'argno, newvalues[argno])
      end argno
    merged~append(src)
  end line
  return merged

programEnd:
  exit 0
