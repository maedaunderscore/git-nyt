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

testSimpleCommit()
{
    echo b > b.txt
    git add b.txt
    git nyt commit -m 'hoge'
    assertEquals $? 0
    assertEquals 'hoge' $(git log -1 --format=%s)
}

testSetBase()
{
    git config nyt.base
    assertEquals 1 $?
    echo b > b.txt
    git add b.txt
    git nyt commit -m 'hoge'
    assertEquals $(git log --format=%H) $(git config nyt.base)
    echo c > b.txt
    git add b.txt
    git nyt commit -m 'hoge'
    assertEquals $(git log --format=%H) $(git config nyt.base)
}

testKeepBase()
{
    echo b > b.txt
    git add b.txt
    git nyt commit -m 'hoge'
    base=$(git config nyt.base)
    assertEquals $(git log -2 --format=%H) $base
    echo c >> b.txt
    git nyt commit -a -m 'fuga'
    assertEquals $base $(git config nyt.base)
}

testClearBase()
{
    echo b > b.txt
    git add b.txt
    git nyt commit -m 'hoge'
    base=$(git config nyt.base)
    assertEquals $(git log -2 --format=%H) $base
    echo c >> b.txt
    git nyt commit -a -m 'fuga'
    assertEquals $base $(git config nyt.base)
    git nyt clear
    git config nyt.base
    assertEquals $? 1
}

testList()
{
    for i in {1..5}; do 
	echo $i > $i.txt
	git add $i.txt
	git nyt commit -m "commit:$i"
    done
    assertEquals 5 $(git nyt list | wc -l)
}

testDiff()
{
    for i in {1..5}; do 
	echo $i > $i.txt
	git add $i.txt
	git nyt commit -m "commit:$i"
    done
    assertEquals "1.txt
2.txt
3.txt
4.txt
5.txt" "$(git nyt diff --name-only)"
}

testFixup()
{
    for i in {1..5}; do 
	echo $i > $i.txt
	git add $i.txt
	git nyt commit -m "commit:$i"
    done
    git nyt fixup -m 'one'
    assertEquals 2 $(git log --pretty=oneline | wc -l)
    assertEquals 'one' $(git log -1 --format=%s)

    for i in {6..10}; do 
	echo $i > $i.txt
	git add $i.txt
	git nyt commit -m "commit:$i"
    done
    git nyt fixup -m 'two'
    assertEquals 3 $(git log --pretty=oneline | wc -l)
    assertEquals 'two' $(git log -1 --format=%s)

}

testFixupPart()
{
    for i in {1..5}; do 
	echo $i > $i.txt
	git add $i.txt
	git nyt commit -m "commit:$i"
    done
    git nyt list | head -n 2 | git nyt fixup-part
}
. ../shunit2-2.1.6/src/shunit2