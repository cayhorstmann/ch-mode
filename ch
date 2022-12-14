#!/bin/bash

if [ -z $JAVA_HOME ] ; then
  export JAVA_HOME=/opt/jdk-11
fi

if [ -z $SCALA_HOME ] ; then
  export SCALA_HOME=/opt/scala
fi

CLASSPATH=`readlink -f $0`.jar # ch.jar

if [[ "$1" = "-f" ]] ; then
    FORCE=t
    shift
fi  

for IN in $@ ; do

    if [ -z "$IN" ] ; then
	echo "Usage: `basename $0` inputfile"
    fi

    if [[ "$IN" = *".ch" ]] ; then
	OUT=${IN/.ch/.html}
	if [ -z "$FORCE" ] && [ $OUT -nt $IN ] ; then 
            echo "Error: $OUT is newer than $IN"
	else
	    if [[  $# -gt 1 ]] ; then echo $IN ; fi
            echo "$IN -> $OUT"
            $SCALA_HOME/bin/scala -classpath $CLASSPATH convert < $IN > $OUT
	fi
    fi

    if [[ "$IN" = *".chx" ]] ; then
	OUT=${IN/.chx/.xml}
	if [ -z "$FORCE" ] && [ $OUT -nt $IN ] ; then 
            echo "Error: $OUT is newer than $IN"
	else
	    if [[  $# -gt 1 ]] ; then echo $IN ; fi
            echo "$IN -> $OUT"
            $SCALA_HOME/bin/scala -classpath $CLASSPATH convert -x< $IN > $OUT
	fi
    fi

    if [[ "$IN" = *".html" ]] ; then
	OUT=${IN/.html/.ch}

	if [ -z "$FORCE" ] && [ $OUT -nt $IN ]; then 
            echo "$OUT is newer than $IN"
	else
            echo "$IN -> $OUT"
            $SCALA_HOME/bin/scala -classpath $CLASSPATH unconvert < $IN > $OUT
	fi
    fi

    if [[ "$IN" = *".xhtml" ]] ; then
	OUT=${IN/.xhtml/.ch}
	if [ -z "$FORCE" ] && [ $OUT -nt $IN ]; then 
            echo "$OUT is newer than $IN"
	else
            echo "$IN -> $OUT"
            $SCALA_HOME/bin/scala -classpath $CLASSPATH unconvert < $IN > $OUT
	fi
    fi

    if [[ "$IN" = *".xml" ]] ; then
	OUT=${IN/.xml/.chx}
	if [ $OUT -nt $IN ]; then 
            echo "$OUT is newer than $IN"
	else
            echo "$IN -> $OUT"
            $SCALA_HOME/bin/scala -classpath $CLASSPATH unconvert < $IN > $OUT
	fi
    fi

    if [[ "$IN" = *".svg" ]] ; then
	OUT=${IN/.svg/.ch}

	if [ -z "$FORCE" ] && [ $OUT -nt $IN ]; then 
            echo "$OUT is newer than $IN"
	else
            echo "$IN -> $OUT"
            $SCALA_HOME/bin/scala -classpath $CLASSPATH unconvert < $IN > $OUT
	fi
    fi
    
done

