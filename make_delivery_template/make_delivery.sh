#!/bin/bash

if ! command -v zip &> /dev/null
then
    echo "zip command could not be found"
    exit
fi

if ! command -v jq &> /dev/null
then
    echo "jq command could not be found"
    exit
fi


echo "Building deliverable"
echo "===================="
echo ""
echo "Enter app version: "
read version

ROOT_LIVRABLE="SimpliciteDeliverable"
REPO_DIR="repo"



mkdir $ROOT_LIVRABLE
date > $ROOT_LIVRABLE/generation_date.txt
i=0

declare -a repositories=(
    "https://github.com/Campano/module-designertools.git"
    "https://github.com/simplicitesoftware/module-frontauth.git"
    "https://github.com/simplicitesoftware/module-forms.git"
    "https://github.com/simplicitesoftware/module-ktmcontent.git"
)

# ========= CREATE MODULE ZIPS IN RIGHT ORDER FROM REPO ===========

for r in "${repositories[@]}"
do
    echo "Generate zip for $r"
    git clone "$r" $REPO_DIR
    cd $REPO_DIR
    if test -f "package.json"; then
        INFO="package.json"
    elif test -f "module-info.json"; then
        INFO="module-info.json"
    else 
        echo "No module info file"
        cd -
        rm -rf $REPO_DIR
        rm -rf $ROOT_LIVRABLE
        exit 1
    fi

    MODULE_NAME="$(cat $INFO | jq -r .name)"
    MODULE_VERSION="$(cat $INFO | jq -r .version)"
    let "i+=1"

    zip -q -x\.git -r "../"$ROOT_LIVRABLE"/"$i"_"$MODULE_NAME"_"$MODULE_VERSION".zip" *
    cd -
    rm -rf $REPO_DIR
done

# ========= PROJECT SPECIFICS ===========

# copy last install manual available (sort by date)
# find ../manual/ -name "install_exploit_manual*" | sort -r | head -n 1 | xargs -I '{}' cp '{}' $ROOT_LIVRABLE/

cp KtmConfig* $ROOT_LIVRABLE/

# ========= GENERATE DELIVERABLE ===========

NAME=$ROOT_LIVRABLE"_"$version"_$(date +'%Y-%m-%d').tgz"
echo ""
echo "Generating $NAME"
tar --create --gzip --file $NAME $ROOT_LIVRABLE

rm -rf $ROOT_LIVRABLE

echo " "
echo "Deliverable generated. Please do not commit in this repository."