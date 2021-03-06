#!/bin/bash

. ./progress-bar.sh --source-only

LIB_FILE="../build/lib/libfilter-programs.so"
LIB_FLAG=-filter-programs
BC_FILE=tmp.bc
RBC_FILE=tmp.rbc
LOG_FILE=log.txt

if [ -z ${1+x} ];
then
  echo "usage: $0 <path/to/dir>"
  exit 1
fi

NOW="$(date +"%y-%m-%dT%H:%M:%SZ")"
FILES_DIR="$1"
RESULTS_DIR="../results/$NOW"
mkdir -p $RESULTS_DIR

touch $RESULTS_DIR/$BC_FILE
touch $RESULTS_DIR/$RBC_FILE

classify_nested_loop () {
  clang -emit-llvm -c $1 -o $RESULTS_DIR/$BC_FILE &>> $RESULTS_DIR/$LOG_FILE
  opt -mem2reg $RESULTS_DIR/$BC_FILE -o $RESULTS_DIR/$RBC_FILE &>> $RESULTS_DIR/$LOG_FILE
  RESULT="$(opt -load $LIB_FILE $LIB_FLAG -disable-output $RESULTS_DIR/$RBC_FILE)"
  
  if [ "$RESULT" != "-1" ]
  then
    mkdir -p $RESULTS_DIR/$RESULT
    cp $1 $RESULTS_DIR/$RESULT
  fi
}

count=0
total_files=$(find $FILES_DIR -type f -name "*.c" | wc -l)

for file in $FILES_DIR/*; do
  if [ ${file: -2} == ".c" ]
  then
    classify_nested_loop $file
    count=$(($count+1))
    
    progress_bar $count $total_files
  fi
done

rm $RESULTS_DIR/$BC_FILE
rm $RESULTS_DIR/$RBC_FILE

echo -e "\n$count programs analized"