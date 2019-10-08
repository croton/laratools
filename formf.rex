/* formf -- A filter for creating forms */
parse arg options
SIGNAL ON NOTREADY NAME programEnd
SIGNAL ON ERROR    NAME programEnd
do forever
  parse pull name type
  if data='' then iterate
  else            call makefield name, type
end
exit

makefield: procedure
  parse arg field, fieldtype
  say '<div class="form-group">'
  say '  <label for="'field'">'field'</label>'
  say '  <input type="'dbtype2httype(fieldtype)'" id="'field'">'
  say '</div>'
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
