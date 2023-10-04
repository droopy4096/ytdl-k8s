#!/bin/sh

OUTPUT_FORMAT=${OUTPUT_FORMAT:-"libx264"}

get_codec(){
    local filename=$1
    ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$filename"
}

convert(){
    local in_file=$1
    local out_file=$2
    ffmpeg -i "${in_file}" -c:a copy -c:v ${OUTPUT_FORMAT} "${out_file}"
}

find_file(){
    local _video_dir=$1
    local _video_files=$2
    local _codec=$3
    find $_video_dir -type f -name "${_video_files}" \
        | while read _filename; \
        do \
          echo  "$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "${_filename}"):${_filename}"; \
        done \
        | tee /tmp/file_list \
        | grep -e "^$_codec" \
        | shuf -n 1 | cut -d':' -f '2-'
}

filename=$(find_file "$@")
[ -z "${filename}" ] && exit 0
echo "==> Selecting from:"
cat /tmp/file_list
echo "==> Selected: ${filename}"
filename_name=${filename%.*}
filename_ext=${filename##*.}
if [[ -n "$SUFFIX" ]]; then
    from_file="${filename}"
    to_file="${filename_name}.${SUFFIX}.${filename_ext}"
    origin="${filename}"
else
    from_file="${filename_name}.from.${filename_ext}"
    to_file="${filename}"
    mv "${filename}" "${filename_name}.from.${filename_ext}"
    origin="${from_file}"
fi

convert "$from_file" "$to_file"