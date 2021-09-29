#!/bin/bash
DEPENDENCY_DIR="./dependencies"
BASH_DIR="./bash_scripts"
PYTHON_DIR="./python_scripts"

#Check if the executor is root. If not, refuse to run
if [ "$(id -u)" -ne 0 ]; then
  echo 'This script must be run by root' >&2
  exit 1
fi
#Download Dependencies
(
mkdir ${DEPENDENCY_DIR}
cd "${DEPENDENCY_DIR}" || return
if ! test -f "./ddx1.26.jar"; then
  curl https://sourceforge.net/projects/dedexer/rss?path=/dedexer/1.26 | grep "<link>.*</link>" | sed 's|<link>||;s|</link>||' | while read url; do url=`echo $url | sed 's|/download$||'`; wget $url ; done
fi
rm ./*.zip
rm ./*.html
)

#Enumerate Scripts
SCRIPTS_LOCAL=$()
SCRIPTS_LOCAL_STRING=""
SCRIPTS_INST=$()
SCRIPTS_INST_STRING=""
BASH_SCRIPTS=$()
PYTHON_SCRIPTS=$()
DEPENDENCIES=$()


#
#Parse Batch Scripts
#
cd ${BASH_DIR} || return

shopt -s nullglob
read -r -a BASH_SCRIPTS <<< "$(echo *)"
shopt -u nullglob

for b in "${BASH_SCRIPTS[@]}"
do
  SCRIPTS_LOCAL_STRING+=$(realpath "./${b} ")

  SCRIPTS_INST_STRING+="/usr/local/bin/${b} "
done


cd ..

#
#Parse Python Scripts
#
cd ${PYTHON_DIR} || return

shopt -s nullglob
read -r -a PYTHON_SCRIPTS <<< "$(echo *)"
shopt -u nullglob

for b in "${PYTHON_SCRIPTS[@]}"
do
  SCRIPTS_LOCAL_STRING+=$(realpath "./${b} ")

  SCRIPTS_INST_STRING+="/usr/local/bin/${b} "
done
cd ..

#
#Parse Dependencies
#
cd ${DEPENDENCY_DIR} || return

shopt -s nullglob
read -r -a DEPENDENCIES <<< "$(echo *)"
shopt -u nullglob

for b in "${DEPENDENCIES[@]}"
do
  SCRIPTS_LOCAL_STRING+=$(realpath "./${b} ")

  SCRIPTS_INST_STRING+="/usr/local/bin/${b} "
done
cd ..

read -r -a SCRIPTS_LOCAL <<< "${SCRIPTS_LOCAL_STRING}"
read -r -a SCRIPTS_INST <<< "${SCRIPTS_INST_STRING}"

#
#Install the scripts
#

for i in "${!SCRIPTS_LOCAL[@]}"; do
  cp "${SCRIPTS_LOCAL[i]}" "${SCRIPTS_INST[i]}"
  chmod a+x "${SCRIPTS_INST[i]}"
done