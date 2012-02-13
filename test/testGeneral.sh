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

test__simple_commit()
{
    echo b > b.txt
    git add b.txt
    git nyt commit -m 'hoge fuga'
    assertEquals $? 0
    assertEquals 'hoge fuga' "$(git log -1 --format=%s)"
}

test__set_base()
{
    git config nyt.base
    assertEquals 1 $?
    echo b > b.txt
    git add b.txt
    git nyt commit -m 'hoge fuga'
    assertEquals "$(git log --format=%H -1 HEAD~1)" "$(git config nyt.base)"
    echo c > b.txt
    git add b.txt
    git nyt commit -m 'foo bar'
    assertEquals "$(git log --format=%H -1 HEAD~2)" "$(git config nyt.base)"
}

test__keep_base()
{
    echo b > b.txt
    git add b.txt
    git nyt commit -m 'hoge hoge'
    base=$(git config nyt.base)
    echo c >> b.txt
    git nyt commit -a -m 'fuga fuga'
    assertEquals $base "$(git config nyt.base)"
}

test__clear_base()
{
    echo b > b.txt
    git add b.txt
    git nyt commit -m 'hoge'
    base=$(git config nyt.base)
    echo c >> b.txt
    git nyt commit -a -m 'fuga'
    assertEquals $base $(git config nyt.base)
    git nyt clear
    git config nyt.base
    assertEquals $? 1
}

OneToFive="1 2 3 4 5"
SixToTen="6 7 8 9 10"

test__list()
{
    for i in $OneToFive; do 
	echo $i > $i.txt
	git add $i.txt
	git nyt commit -m "commit: $i"
    done
    assertEquals 5 $(git nyt list | wc -l)
}

test__diff()
{
    for i in $OneToFive; do 
	echo $i > $i.txt
	git add $i.txt
	git nyt commit -m "commit: $i"
    done
    assertEquals "1.txt
2.txt
3.txt
4.txt
5.txt" "$(git nyt diff --name-only)"
}

test__fixup()
{
    for i in $OneToFive; do 
	echo $i > $i.txt
	git add $i.txt
	git nyt commit -m "commit: $i"
    done
    git nyt fixup -m 'commit: one'
    assertEquals 2 $(git log --pretty=oneline | wc -l)
    assertEquals 'commit: one' "$(git log -1 --format=%s)"

    for i in $SixToTen; do 
	echo $i > $i.txt
	git add $i.txt
	git nyt commit -m "commit: $i"
    done
    git nyt fixup -m 'commit: two'
    assertEquals 3 $(git log --pretty=oneline | wc -l)
    assertEquals 'commit: two' "$(git log -1 --format=%s)"

}

test__bleis()
{
    echo 1 > 1.txt
    git add 1.txt
    git nyt bleis -m 'commit: 1'
    assertEquals 1 $(git log --pretty=oneline | wc -l)
    echo 2 > 1.txt
    git add 1.txt
    git nyt bleis -m 'commit: 2'
    assertEquals 2 $(git log --pretty=oneline | wc -l)
    echo 3 > 2.txt
    git add 2.txt
    git nyt bleis -m 'commit: 3'
    assertEquals 2 $(git log --pretty=oneline | wc -l)
}

. ../shunit2-2.1.6/src/shunit2