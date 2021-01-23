#!/bin/bash

function selector {
	local parentPath=$1
	if [[ "$parentPath" == "" ]]; then
		parentPath=$HOME
	fi

    local superParentPath=$(dirname $parentPath)
    local pathArr=$(find $parentPath -maxdepth 1 -type d -not -path '*/\.*')

    pathArr=(${superParentPath} ${pathArr[@]})

    select path in ${pathArr[@]}; do
        if [ -d "$path" ]; then
            cd "$path"

            read -p "Make thumbnails (y/n)?" choice
            if [[ $choice -ge 1 && $choice -lt ${#pathArr[@]} ]]; then
                selector "$path"
            elif [[ "$choice" == "y" ||  "$choice" == "Y" ]]; then
                getThumbnailDir ${path}
            fi

            return
        fi
    done
}

function getThumbnailDir(){
    local path=$1

    read -p "Overwrite thumbnails (y/n)?" choice
    case "$choice" in
        y|Y ) local overwrite="-y";;
        * ) local overwrite="-n";;
    esac

    if [ -d "$path" ]; then
        for f in $(find $path -maxdepth 1 -type f)
        do
            getThumbnailFile $f $overwrite &
        done
    elif [[ -f "$path" ]]; then
        getThumbnailFile $path $overwrite
    fi
}

function getThumbnailFile(){
    local f=$1
    local overwrite=$2

    # if video file
    if  file -i $f | grep -q video  ; then
        # get extension
        local fileExt=${f##*.}
        ffmpeg -loglevel quiet $overwrite -i $f -vf  "thumbnail" -frames:v 1 $(basename "${f%%.${fileExt}}")-thumb.jpg

        echo -e "$(basename "${f%%.${fileExt}}")-thumb.jpg"
    fi
}

selector