#!/bin/bash
title=$(less game.project | grep "title = " | cut -d "=" -f2 | sed -e 's/^[[:space:]]*//')
title_no_space=$(echo -e "${title}" | tr -d '[[:space:]]')

echo "Project: ${title}"

if [ ! -f bob.jar ]
	then
		echo "Unable to find bob.jar. Download it from d.defold.com."
		exit 1
fi

bob() {
	java -Djava.ext.dirs= -jar bob.jar $@
}

bundle() {
	platform=$1
	echo "${platform}"
	shift 1
	bob --platform ${platform} --bundle-output build/${platform} $@ bundle
}

archive() {
	platform=$1
	if [ "${platform}" == "armv7-android" ]
		then
			echo "${title_no_space}.apk"
			mv "build/${platform}/${title}/${title}.apk" "${title_no_space}.apk"
	elif [ "${platform}" == "armv7-darwin" ]
		then
			echo "${title_no_space}.ipa"
			mv "build/${platform}/${title}/${title}.ipa" "${title_no_space}.ipa"
	else
		echo "${title_no_space}_${platform}.zip"
		rm -rf "${title_no_space}_${platform}.zip"
		cd build/${platform}
		zip -r -q "../../${title_no_space}_${platform}.zip" *
		cd ../..
	fi
}

#bob --email john.smith@acme.com --auth foobar resolve

# build
echo -e "\n[Building]"
rm -rf build
bob --archive build

# bundle platforms
echo -e "\n[Bundling]"
bundle armv7-android --private-key key.pk8 --certificate certificate.pem
#bundle armv7-darwin --identity foobar --mobileprovisioning foobar.mobileprovision
bundle x86-win32
bundle x86-darwin
bundle x86-linux
bundle js-web

# archive bundled platforms
echo -e "\n[Archiving]"
archive armv7-android
archive x86-win32
archive x86-darwin
archive x86-linux
archive js-web
