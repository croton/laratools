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
  when pfx='grant' then call granter params
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

doinsert: procedure expose cb
  parse arg name cols
  if cols='' then cols='id name'
  val='1'
  vals=copies(val', ', words(cols)-1)||val
  dcmd='insert into' name '('||space(cols,1,',')||') values ('enquote(cols)');'
  say dcmd
  cb~copy(dcmd)
  return

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

granter: procedure
  parse arg options
  /* if db='' then db=pickAItem(cmdout('echo show databases |mysql -u root --skip-column-names'))
  if db='' then return
  */
  say 'Grant ALL privileges to a database user:'
  usr=pickAItem(cmdout("echo select db, user from db where host like 'localhost' |mysql -u root mysql --skip-column-names"))
  if usr='' then say 'Ok'
  else do
    parse var usr db user
    dbcmd='GRANT ALL ON' db".* TO '"user"'@'localhost'"
    -- dbcmd2='mysql -u root mysql -e "select database(), user(), curdate();"'
    -- call prompt dbcmd2
    if askYN('Run command as root?' dbcmd) then ADDRESS CMD 'mysql -u root mysql -e "'dbcmd'"'
    else say 'Ok'
  end
  return

/* --------------------------- Private functions ---------------------------- */
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

picktableByDB: procedure
  parse arg db
  if db='' then db='mysql'
  choices=cmdout('echo show tables |mysql -u root' db '--skip-column-names')
  return pickAItem(choices)

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

help: procedure
  say 'dbu -- A utility tool, version' 0.2
  say 'commands:'
  parse source . . srcfile .
  call showSourceOptions srcfile, 'when pfx'
  return

::requires 'UtilRoutines.rex'
::requires 'winSystm.cls'
