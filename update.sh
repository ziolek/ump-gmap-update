#!/bin/bash

function echo_green {
	echo $'\e[92m'$1$'\e[0m'
}


FID=122
VER="pe"

SRC_DIR="map_$VER"
GMAP_DIR="$VER.gmap"
PRODUCT_DIR=$GMAP_DIR"/Product1"
GMT="./gmt"

RSYNC_BASE_URL="rsync://rsync.ump.waw.pl/ump"
LATEST_FILE="latest-$VER.txt"

echo -n "Looking for last release for '$VER' version... "
rsync -a --compress --times $RSYNC_BASE_URL/$LATEST_FILE ./
LATEST_RELEASE=`cat $LATEST_FILE`
echo_green $LATEST_RELEASE

rsync -va --compress --times --human-readable --recursive --progress rsync://rsync.ump.waw.pl/ump/$LATEST_RELEASE/* $SRC_DIR


for IMG_FILE in $SRC_DIR/*.img
do
	IMG_BASENAME=`basename $IMG_FILE`
	if [[ $IMG_FILE = *mdr* ]] ; then
		IMG_DIR=$GMAP_DIR/${IMG_BASENAME%.img}
	else
		IMG_DIR=$PRODUCT_DIR/${IMG_BASENAME%.img}
	fi
	rm -rf $IMG_DIR
	mkdir -p $IMG_DIR
	$GMT -g -o $IMG_DIR $IMG_FILE
done

cp $SRC_DIR/*.tdb $PRODUCT_DIR
cp $SRC_DIR/*.mdx $GMAP_DIR

echo_green "Conversion finished."


exit 0
declare gmapdir="gmap/"
declare productdir=$gmapdir"Product1/"
declare sourcedir="./map/"

for imgfile in $sourcedir*.img
do
	bname=`basename $imgfile`
	if [[ $imgfile = *mdr* ]] ; then
		dir=$gmapdir${bname%.img}
	else
		dir=$productdir${bname%.img}
	fi
	rm -rf $dir
	mkdir -p $dir
	./gmt -g -o $dir $imgfile
done
cp $sourcedir/*.tdb $productdir
cp $sourcedir/*.mdx $gmapdir

echo "Aktualizacja zakończona."
