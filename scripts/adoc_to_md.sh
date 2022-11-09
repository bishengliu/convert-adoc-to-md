#!/bin/bash

function convert_adoc_to_markdown() {
    local adoc_file=$1
    local filename_without_extension=".$(echo $adoc_file | rev | cut -d'.' -f2 | rev)"

    echo $filename_without_extension

    local md_file="${filename_without_extension}.md"
    local xml_file="${filename_without_extension}.xml"

    echo $md_file
    echo $xml_file

    # remove the md file if exists
    if [[ -f $md_file ]]; then
        rm -rfv $md_file
    fi

    # Convert asciidoc to docbook using asciidoctor
    asciidoctor -b docbook $adoc_file

    # Convert docbook to markdown
    pandoc -f docbook -t gfm $xml_file -o $md_file

    # Unicode symbols were mangled in *.md. Quick workaround:
    iconv -t utf-8 $xml_file | pandoc -f docbook -t gfm | iconv -f utf-8 >$md_file

    # Pandoc inserted hard line breaks at 72 characters. Removed like so:
    pandoc -f docbook -t gfm --wrap=none   # don't wrap lines at all
    pandoc -f docbook -t gfm --columns=120 # extend line breaks to 120

    # clean up xml file
    rm -rfv $xml_file
}

export -f convert_adoc_to_markdown

find . -name '*.adoc' -exec bash -c 'convert_adoc_to_markdown "$0"' {} \;
