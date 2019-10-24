/* dbu -- utility tool */
parse arg pfx params
DB_NAME=value('CJP_DB',,'ENVIRONMENT')
basedir=value('userprofile',,'ENVIRONMENT')'\data'
cb=.WindowsClipboard~new
select
  when pfx='t' then call tableinfo params
  when pfx='tn' then call tablename params
  when pfx='i' then call doinsert params
  when pfx='new' then call newrow params
  when pfx='x' then call doXmac params
  when pfx='users' then call info 'users', params
  when pfx='bit' then call convertBit params
  otherwise call help
end
exit

tableinfo: procedure expose basedir cb DB_NAME
  parse arg name options
  t=picktableFromList(name)
  if t='' then say 'No table selected from table list'
  else call info t, options
  return

tablename: procedure expose basedir cb DB_NAME
  parse arg name
  t=picktableFromList(name)
  if t='' then say 'No table selected from table list'
  else do
    say t; cb~copy(t)
  end
  return

/* Show info on a given table - structure, content, or count */
info: procedure expose cb DB_NAME
  parse arg table, options, type
  opts=translate(options)
  select
    when abbrev('COL', opts) then dcmd='desc' table';'
    when abbrev('SELECT', opts, 1) then dcmd='select * from' table 'limit 5;'
    -- Show Vertical
    when abbrev('SV', opts, 1) then dcmd='select * from' table 'limit 5 \G'
    otherwise dcmd="select count(*) as '"table"_rows' from" table';'
  end
  if opts='C' then prog='mysql -u root' DB_NAME '|wordf'
  else             prog='mysql -u root' DB_NAME '-t'
  call runcmd 'echo' dcmd'|'prog
  cb~copy(dcmd)
  return

picktableFromList: procedure expose basedir
  parse arg name
  tablelist=.Stream~new(basedir'\tables-list.xfn')
  if tablelist=.nil then return ''
  tables=tablelist~arrayin
  if name<>'' then do
    sub=.Array~new
    loop t over tables
      if abbrev(t, name) then sub~append(t)
    end
    if sub~items>0 then tables=sub
  end
  return pickAItem(tables)

newrow: procedure expose cb
  parse arg db
  if db='' then do
    say 'Please specify a database'
    return
  end
  say 'Select a table:'
  table=picktableByDB(db)
  if table='' then return
  columns=cmdout('echo desc' table'|mysql -u root' db '--skip-column-names|wordf')
  columnlist=join(columns)
  dcmd='insert into' table '('||space(columnlist, 1, ',')||') values ('enquote(columnlist)');'
  say dcmd
  cb~copy(dcmd)
  return

picktableByDB: procedure
  parse arg db
  if db='' then db='mysql'
  choices=cmdout('echo show tables |mysql -u root' db '--skip-column-names')
  return pickAItem(choices)

doinsert: procedure expose cb
  parse arg name cols
  if cols='' then cols='id name'
  val='1'
  vals=copies(val', ', words(cols)-1)||val
  dcmd='insert into' name '('||space(cols,1,',')||') values ('enquote(cols)');'
  say dcmd
  cb~copy(dcmd)
  return

enquote: procedure
  parse arg items
  list=''
  limit=words(items)-1
  do w=1 to limit
    list=list "'"word(items,w)"',"
  end w
  list=list "'"word(items,w)"'"
  return strip(list)

join: procedure
  use arg collection
  list=''
  loop item over collection
    list=list item
  end
  return strip(list)

doXmac: procedure expose cb
  parse arg name cols
  if cols='' then cols='id name'
  xcmd="'macro chooser" cols '--t' name "--multi'"
  say xcmd; cb~copy(xcmd)
  return

convertBit: procedure expose cb
  parse arg name title
  coldef='convert('name',UNSIGNED INTEGER) AS' title
  say name '->' coldef
  cb~copy(coldef)
  return

help: procedure
  say 'dbu -- A utility tool, version' 0.2
  say 'commands:'
  parse source . . srcfile .
  call showSourceOptions srcfile, 'when pfx'
  return

::requires 'UtilRoutines.rex'
::requires 'winSystm.cls'
