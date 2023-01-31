#!/bin/bash

profile=$1
model=$2
comment=$3

utime=$(date +'%Y-%m-%d %H:%M:%S')

if [ "$profile" == "" ];then
    echo "sh <project> <push/del/update/upset>"
    exit 1
fi

check(){
    if (( $? != 0 ));then
        echo "fail"
    exit 1
    else
    echo "success"
    fi
    
}

if [ "$comment" == "" ];then
    comment="${utime}"
else
    comment="${utime}-${comment}"
fi

pojectPath=/usr/local/git
replace(){
    i=1
    while read key
    do
        str=$(grep -rn "$key" ${pojectPath}/${profile}/.* | awk -F ':' '{print$1}')
        if (( $? != 0 )) || [ "$str" == "" ];then
            continue
        fi
        echo "$i 替换敏感字符 $key"
        sed -i "s|${key}|**************|g" ${str}
        olds=$(echo $str | sed "s|/usr/local|/tmp|g")
        sed -i "s|${key}|**************|g" ${olds}
        check $?
        let i++
    done</usr/local/sbin/.key
}
clean(){
    echo "开始清理缓存"
    rm -rf /tmp/git/*
    check $?
    rm -rf /usr/local/git/*
    check $?
    cp -rp /c/chengkenlee/goland_2020.1.1/resource/src/${profile} /tmp/git
    check $?
    cp -rp /tmp/git/${profile} /usr/local/git
    check $?
    replace
}

diffs(){
    local1=/tmp/git/${profile}
    local2=/usr/local/git/${profile}
    find ${local2}/ | xargs md5sum | egrep -vw 'md5sum|.git|.idea' | awk -F '/' '{print$NF}' > /tmp/aa
    while read line
    do
        if [ "$line" == ".yaml" ];then
            line=/.${profile}.yaml
        fi
        d1=${local1}/${line}
        d2=${local2}/${line}
        num=$(md5sum ${d1} ${d2} | awk '{print$1}' | uniq | wc -l)
        if (( $num != 1 ));then
            echo "检测到【$line】文件发生变化,可能存在被修改过,update只提交更新文件"
            md5sum ${d1} ${d2}
            cp -rp ${d1} ${d2}
        fi
    done</tmp/aa
}

push(){
        clean
        cd ${pojectPath}/${profile}/;
        rm -rf .git;
        git init;
        git add .;
        git commit -m "${comment}";
        git branch -M main
        git remote add origin git@github.com:chengkenlee/${profile}.git;
        git pull --rebase origin main;
        git push -u origin main;
}
upset(){
        clean
        rm -rf ${pojectPath}/${profile} && mkdir -p ${pojectPath}/${profile} && rm -rf  /tmp/git/${profile}/.git
        cd ${pojectPath}/${profile}/
        git init;
        git remote add origin git@github.com:chengkenlee/${profile}.git;
        git pull --rebase origin main
        diffs
        git status -s | awk '{print$NF}' | xargs git add
        git status -s
        git stash -u -k
        git commit -m "${comment}"
        git pull --rebase origin main
        git checkout -b main
        git push --force origin main
        git stash pop
}
del(){
        mkdir -p ${pojectPath}/${profile}/;
        cd ${pojectPath}/${profile}/;
        git init;
        git remote add origin git@github.com:chengkenlee/${profile}.git;
        git pull --rebase origin main;
        git rm -rf --cached .;
        git commit -m 'delete';
        git push -u origin main;
}
update(){
        clean
        cd ${pojectPath}/${profile}/;
        rm -rf .git
        git init;
        git add -A .;
        git commit -m "${comment}";
        git remote add origin git@github.com:chengkenlee/${profile}.git;
        git checkout -b main
        git push --force origin main
}

if [ "$model" == "push" -o "$model" == "" ];then
    push
fi

if [ "$model" == "del" ];then
    del
fi

if [ "$model" == "upset" ];then
    upset
fi

if [ "$model" == "update" ];then
    update
fi


