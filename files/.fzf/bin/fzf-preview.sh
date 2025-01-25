#!/usr/bin/env bash
#
# The purpose of this script is to demonstrate how to preview a file or an
# image in the preview window of fzf.
#
# Dependencies:
# - https://github.com/sharkdp/bat
# - https://github.com/hpjansson/chafa
# - https://iterm2.com/utilities/imgcat
__preview_dir() {
    local dir=$1
    [ -f "${dir}/README.md" ] && bat --style=numbers --color=always "${dir}/README.md" && return
    tree --filelimit=25 -t  -r -D --prune -L 2  "$dir"
}

__preview_file() {
    local file=$1
    case "$file" in
        *.tar|*.tar.gz|*.tar.bz2|*.tar.xz|*.tgz|*.zip)
            tar --list --file "$file" ;;
        *.7z)
            7z l "$file" ;;
        *.rar)
            unrar l "$file" ;;
        *.pdf)
            pdftotext -l 10 -nopgbrk -q -- "$file" - | head -n 50 ;;
        *.docx)
            docx2txt.pl "$file" - ;;
        *.xlsx|*.xlsm|*.ods)
            ssconvert "$file" csv:- | head ;;
        *.pptx|*.pptm|*.odp)
            catppt "$file" ;;
        *.epub)
            ebook-meta --get-title "$file" ;;
        *)
            # Sometimes bat is installed as batcat.
            if command -v batcat > /dev/null; then
                batname="batcat"
            elif command -v bat > /dev/null; then
                batname="bat"
            else
                cat "$1"
                exit
            fi

            ${batname} --style="${BAT_STYLE:-numbers}" --color=always --pager=never -- "$file"
            ;;
    esac
}

if [[ $# -ne 1 ]]; then
    >&2 echo "usage: $0 FILENAME"
    exit 1
fi

file=${1/#\~\//$HOME/}
if [ -d "${file}" ] ; then
    __preview_dir "${file}"
    exit
fi

type="$(file --dereference --mime "$file")"
if [[ ! $type =~ image/ ]]; then
    if [[ $type =~ =binary ]]; then
        file "${file}"
        exit
    fi

    __preview_file "${file}"
    exit
fi

dim=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}
if [[ $dim = x ]]; then
    dim=$(stty size < /dev/tty | awk '{print $2 "x" $1}')
elif ! [[ $KITTY_WINDOW_ID ]] && (( FZF_PREVIEW_TOP + FZF_PREVIEW_LINES == $(stty size < /dev/tty | awk '{print $1}') )); then
    # Avoid scrolling issue when the Sixel image touches the bottom of the screen
    # * https://github.com/junegunn/fzf/issues/2544
    dim=${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES - 1))
fi

# 1. Use kitty icat on kitty terminal
if [[ $KITTY_WINDOW_ID ]]; then
    # 1. 'memory' is the fastest option but if you want the image to be scrollable,
    #    you have to use 'stream'.
    #
    # 2. The last line of the output is the ANSI reset code without newline.
    #    This confuses fzf and makes it render scroll offset indicator.
    #    So we remove the last line and append the reset code to its previous line.
    kitty icat --clear --transfer-mode=memory --stdin=no --place="$dim@0x0" "$file" | sed '$d' | sed $'$s/$/\e[m/'

# 2. Use chafa with Sixel output
elif command -v chafa > /dev/null; then
    chafa -f sixel -s "$dim" "$file"
    # Add a new line character so that fzf can display multiple images in the preview window
    echo

# 3. If chafa is not found but imgcat is available, use it on iTerm2
elif command -v imgcat > /dev/null; then
    # NOTE: We should use https://iterm2.com/utilities/it2check to check if the
    # user is running iTerm2. But for the sake of simplicity, we just assume
    # that's the case here.
    imgcat --height "${dim##*x}" "$file"
# 4. Cannot find any suitable method to preview the image
else
    file "$file"
fi
