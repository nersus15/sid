#!/usr/bin/env bash
cli_name='mncli'
function create(){
  jenis=$1 name="$2_$jenis.php" isi=$3 
  echo "->creating file $name ..."
  
  file="apps/$jenis/$name"
  echo $isi > $file
  cat $file
  
}
function cek_aksi(){
  value=$1 commands=("controller\thelper\tmodel\tlibrary")
  if [[ "\t${commands[@]}\t" =~ "\t${value}\t" ]]; then
      valid=1
  else
      valid=""
  fi
}

function help_log(){
  [[ -z $2 ]] || echo " $1 $2 not found"
  echo -e "Usage: \n $cli_name [options] argument ...\n"
  echo "$package - attempt to capture frames"
  echo " "
  echo "$package [options] application [arguments]"
  echo " "
  echo -e " options:\n
      -h, --help                show brief help\n
      -c, --action=ACTION       menentukan file yang akan dibuat\n
      -n, --name=NAME           mnentukan nama file\n
      -o, --output-dir=DIR      specify a directory to store output in\n
      -i, --import              import from resource server\n"
  echo -e " actions:\n
      model                     create model file\n
      update                    update project from git (git fetch)\n
      helper                    create helper file\n 
      controller                create controller file\n
      assets                    clone assets from server\n
      library                   create library file"
  exit 0
}
while test $# -gt 0; do
  
  case "$1" in
    -h|--help)
        help_log
      ;;
    -c)
      shift
      if test $# -gt 0; then
        export ACTION=$1
      else
        echo "tidak ada jenis file yang di pilih"
        exit 1
      fi
      shift
      ;;
    --update | -u)
        echo "updating project from origin repo ......"
        git pull apps master
      exit 0
      ;;
       --create*)
      export ACTION=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
      -n)
      shift
      if test $# -gt 0; then
        export NAME=$1
      else
        echo "tidak ada nama file"
        exit 1
      fi
      shift
      ;;
    --name*)
      export PROCESS=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    -i)
      shift
      if test $# -gt 0; then
        export NAME=$1
      else
        echo "pilih jenis yang akan di import"
        exit 1
      fi
      shift
      ;;
    --import*)
      export PROCESS=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    -o)
      shift
      if test $# -gt 0; then
        export OUTPUT=$1
      else
        echo "no output dir specified"
        exit 1
      fi
      shift
      ;;
    --output-dir*)
      export OUTPUT=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    *)
      break
      ;;
  esac
done

cek_aksi $ACTION

if [[ -z $valid ]]
then
  help_log 'action' $ACTION 
fi
if [[ -z $NAME ]]
then
  echo -e "File name can't empty \n
    Usage:\n
    $cli_name -c [ACTIONS] -n <nama file>"
  exit 1
fi

case "$ACTION" in
  model)
    class_name=$NAME"_model"
    isi="<?php class $class_name {}"
    create 'models' "$NAME" "$isi"
  ;;
  helper)
    class_name=$NAME"_helpor"
    isi="<?php function first_func(){}"
    create 'helpers' "$NAME" "$isi"
  ;;
  library)
    class_name=$NAME"_library"
    isi="<?php class $class_name {}"
    create 'library' "$NAME" "$isi"
  ;;
  controller)
    class_name=$NAME
    isi="<?php class $class_name extends controller{}"
    create 'controller' "$NAME" "$isi"
  ;;
esac

