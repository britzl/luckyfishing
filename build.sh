#!/bin/bash
title=$(less game.project | grep "title = " | cut -d "=" -f2 | sed -e 's/^[[:space:]]*//')

bob() {
	java -Djava.ext.dirs= -jar bob.jar $@
}

bundle() {
	platform=$1
	echo "Bundling for $platform"
	shift 1
	bob --platform $platform --bundle-output build/$platform $@ bundle
}

archive() {
	platform=$1
	echo "Archiving $platform"
	if [ "$platform" == "armv7-android" ]
		then
			mv "build/$platform/$title/$title.apk" .
	elif [ "$platform" == "armv7-darwin" ]
		then
			mv "build/$platform/$title/$title.ipa" .
	else
		rm -rf $platform.zip
		zip -r -q $platform.zip build/$platform/*
	fi
}

#bob --email bjorn.ritzl@king.com --auth foobar resolve

rm -rf build
bob --archive build
bundle armv7-android --private-key key.pk8 --certificate certificate.pem
#bundle armv7-darwin --identity foobar --mobileprovisioning foobar.mobileprovision
bundle x86-win32
bundle x86-darwin
bundle x86-linux
bundle js-web

archive armv7-android
archive x86-win32
archive x86-darwin
archive x86-linux
archive js-web
