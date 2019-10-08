/* ppm -- utility tool */
parse arg pfx params
APP_HOME='c:\xampp\htdocs'
select
  when pfx='ctl' then call makecontroller params
  when pfx='dep' then call addlib params
  when pfx='h' then call runcmd 'php artisan help' params
  when pfx='hint' then say 'Common usage: new, newdb, mod, migrate'
  when pfx='hosts' then type 'c:\Windows\System32\drivers\etc\hosts'
  when pfx='l' then call runcmd 'php artisan list'
  when pfx='make' then call make params
  when pfx='migrate' then call prompt 'php artisan migrate'
  when pfx='mod' then call makemodel params
  when pfx='new' then call newproject params
  when pfx='newdb' then call newdb params
  when pfx='rollback' then call prompt 'php artisan migrate:rollback'
  when pfx='table' then call maketable params
  when pfx='tablemod' then call changetable params
  when pfx='test' then call prompt 'php artisan make:test' params'Test'
  when pfx='undo' then call prompt 'php artisan migrate:rollback'
  when pfx='v' then call vhost params
  when pfx='view' then call newview params
  when pfx='ver' then say '0.2'
  otherwise call help
end
exit

newproject: procedure expose APP_HOME
  parse arg name db
  if name='' then say 'Please specify: project-name [db-name]'
  else do
    call prompt 'composer create-project laravel/laravel' name
    call vhost name, 'my'translate(left(name,1))||substr(name,2), 80
    if db='' then db=name
    call prompt 'epm' APP_HOME'\'name'\.env' '-CC/DB_DATABASE=laravel/DB_DATABASE='db'/'
  end
  return

vhost: procedure expose APP_HOME
  parse arg app, servername, port
  if port='' then port='80'
  if servername='' then servername=app
  vhosts='c:\xampp\apache\conf\extra\httpd-vhosts.conf'
  select
    when app='' then 'type' vhosts
    when app='EDIT' then if askYN('Load vhosts') then 'epm' vhosts
    otherwise
      tmpl=value('cjp',,'ENVIRONMENT')||'\snips\php-vhost.tmpl'
      if SysFileExists(tmpl) then 'merge' tmpl app servername port
      else do
        CR=d2c(10)
        publicDir=translate(APP_HOME,'/','\')||'/'app'/public'
        say '<VirtualHost *:'port'>'CR'DocumentRoot "'publicDir'"'CR'ServerName' servername||CR'</VirtualHost>'
      end
  end
  return

addlib: procedure
  parse arg name
  if name='' then say 'Please specify library name'
  else            call prompt 'composer require' name
  return

newview: procedure expose APP_HOME
  parse arg name parent
  if name='' then say 'Please specify: view-name [parent-directory]'
  else do
    currdir=directory()
    if abbrev(currdir, APP_HOME) then do
      parse var currdir . 'htdocs\' appdir '\' .
      if parent='' then viewdir=APP_HOME'\'appdir'\resources\views'
      else              viewdir=APP_HOME'\'appdir'\resources\views\'parent
    end
    else viewdir='.'
    viewname=viewdir'\'name'.blade.php'
    tmpl=value('cjp',,'ENVIRONMENT')||'\snips\php-view.tmpl'
    if \SysFileExists(viewdir) then ADDRESS CMD 'mkdir' viewdir
    ADDRESS CMD 'merge' tmpl name '>>' viewname
    if SysFileExists(viewname) then say 'New view created:' viewname
    else                            say 'No view created' viewname
  end
  return

makemodel: procedure
  parse arg name
  if name='' then say 'Please specify model name'
  else call prompt 'php artisan make:model Models/'name '--migration'
  return

makecontroller: procedure
  parse arg name isResource
  if name='' then say 'Please specify: controller-name [isResource]'
  else do
    if isResource='' then option=''
    else                  option='--resource'
    call prompt 'php artisan make:controller' name'Controller' option
  end
  return

maketable: procedure
  parse arg name
  if name='' then say 'Please specify table name'
  else do
    script='create_'name'_table'
    call prompt 'php artisan make:migration' script '--create='name
  end
  return

changetable: procedure
  parse arg name script
  if name='' then say 'Please specify table name'
  else do
    if script='' then script='update_'name'_table'
    call prompt 'php artisan make:migration' script '--table='name
  end
  return

make: procedure
  parse arg name
  if name='' then say 'Please specify package name'
  else            call prompt 'php artisan make:'name
  return

newdb: procedure
  parse arg db user pwd .
  if pwd='' then say 'Please specify database, username, password'
  else do
    say 'CREATE DATABASE' db';'
    say "CREATE USER '"user"'@'localhost' IDENTIFIED BY '"pwd"'; GRANT SELECT,INSERT,UPDATE,DELETE ON" db".* TO '"user"'@'localhost';"
  end
  return

help: procedure
  say 'ppm -- A PHP-Laravel utility tool'
  say 'commands:'
  parse source . . srcfile .
  call showSourceOptions srcfile, 'when pfx'
  return

::requires 'UtilRoutines.rex'