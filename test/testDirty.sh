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
    . git-nyt > /dev/null
}

tearDown()
{
    cd ..
    rm -rf testunit_work
}


test__is_dirty()
{
    assertNotEquals "0" "$(is_dirty)"
    echo b > b.txt
    assertEquals "0" "$(is_dirty)"
    git add b.txt
    assertEquals "0" "$(is_dirty)"
    git commit -m 'commit'
    assertNotEquals "0" "$(is_dirty)"
}


. ../shunit2-2.1.6/src/shunit2