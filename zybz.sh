basedir="content/posts"
create_dir () {
    subpath="$1"
    path="$basedir"/"$1"
    name=`basename "$subpath"`
    identifier=`echo "$subpath" | sed 's#/#.#g'`
    parent_path=`dirname "$subpath"`
    parent=`echo "$parent_path" | sed 's#/#.#g'`

    if [ ! -d "$path" ]; then
        mkdir "$path"
    fi

    cat > ${path}/_index.md <<EOF
---
title: "$name"
menu:
  sidebar:
    name: "$name"
    identifier: "$identifier"
EOF

    if [ "$parent" != "." ]; then
        echo "    parent: $parent" >> ${path}/_index.md 
    fi
    echo "---" >> ${path}/_index.md 
}

create_file () {
    subpath="$1"
    path="$basedir"/"$1"
    suffix=${path##*.}
    name=`basename "$subpath" .$suffix`
    identifier=`echo "$subpath" | sed 's#/#.#g'`
    parent_path=`dirname "$subpath"`
    parent=`echo "$parent_path" | sed 's#/#.#g'`

    cat > ${path} <<EOF
---
title: "$name"
date: `date "+%F"`
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "$name"
    identifier: "$identifier"
EOF
    if [ "$parent" != "." ]; then
        echo "    parent: $parent" >> ${path}
    fi
    echo "---" >> ${path}
}


case "$1" in
    d)
        create_dir "$2"
        ;;
    f)
        create_file "$2"
        ;;
esac