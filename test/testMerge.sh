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
}

tearDown()
{
    cd ..
    rm -rf testunit_work
}

test__edit_separate_part()
{
    echo 'a
b
c' > abc.txt
    git add abc.txt
    git nyt commit -m 'make abc'

    echo 'a
b
d' > abc.txt
    git nyt commit -a -m 'c -> d'

    echo 'e
b
d' > abc.txt
    git nyt commit -a -m 'a -> e'

    git nyt list | grep -v 'c -> d' | git nyt fixup-part -m 'a -> e first'

    echo 'e
f
d' > abc.txt
    git nyt commit -a -m 'b -> f'

    git nyt fixup -m 'left'
    assertEquals 'left' "$(git log -1 --format=%s)"
    assertEquals 'a -> e first' "$(git log -2 --format=%s | tail -n 1)"
    assertEquals 'e
f
d' "$(cat abc.txt)"
    git log --pretty=oneline
    assertEquals 3 $(git log --pretty=oneline | wc -l)
}

testConflict()
{
    echo b > a.txt
git diff    
    git nyt commit -a -m 'a -> b'
    echo c > a.txt
git diff    
    git nyt commit -a -m 'b -> c'
    echo d >> a.txt
git diff    
    git nyt commit -a -m 'add d'
    git nyt list | tail -n 1 | git nyt fixup-part -m 'add d'
    assertEquals 'c
d' "$(cat a.txt)"
    
    git nyt list | grep -v 'b -> c' | git nyt fixup-part -m 'a -> c'
    assertNotEquals 0 $?
    assertEquals 'c
d' "$(cat a.txt)"
}

. ../shunit2-2.1.6/src/shunit2