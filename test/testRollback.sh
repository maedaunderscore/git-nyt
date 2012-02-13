#! /bin/sh

setUp()
{
    mkdir testunit_work
    cd testunit_work
    export PATH=../..:$PATH
    git init
    echo a > a.txt
    git add a.txt
    git commit -m 'first commit'
    . git-nyt show > /dev/null
}

tearDown()
{
    cd ..
    rm -rf testunit_work
}



test__run_one_line_with_success()
{
    assertEquals "ok" $(try "echo ok")
    try "echo ok"
    assertEquals "0" "$?"
}

test__run_multiple_lines_with_success()
{
    assertEquals "ok
ok2
ok3" "$(try '
echo ok
echo ok2
echo ok3')"
    try '
echo ok
echo ok2
echo ok3'
    assertEquals "0" "$?"
}

test__run_multiple_lines_with_error()
{
    assertEquals "" "$(try '
echo ok
echooo ok2
echo ok3' | grep ok3)"
    try 'echo ok
echooo ok2
echo ok3'
    assertNotEquals "0" "$?"
}

test_rollback()
{
    try '
echo b > b.txt
git add b.txt && git commit -m "add b.txt"
echooo hoge
'
    assertNotEquals "0" "$?"
    assertEquals 'first commit' "$(git log --pretty=%s -1)"
    assertEquals 1 $(git log --pretty=oneline | wc -l)
}

test__run_with_environment()
{
    echo $b
    assertEquals "a.txt" "$(try '
a=$(ls)
echo $a
echo $b')"
}

test__run_with_eval()
{
    assertEquals "a.txt
hoge" "$(try '
a="echo hoge"
eval ls
eval $a')"
}

. ../shunit2-2.1.6/src/shunit2