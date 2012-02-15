#! /bin/sh

setUp()
{
    mkdir testunit_work
    cd testunit_work
    export PATH=../..:$PATH
    git init
#    echo a > a.txt
#    git add a.txt
#    git commit -m 'first commit'
}

tearDown()
{
    cd ..
    rm -rf testunit_work
}

test__simple_commit()
{
    echo b > b.txt
    git nyt add b.txt
    assertEquals 0 $?
    assertEquals "" "$(git nyt base)"
    git nyt commit -m 'hoge fuga'
    assertEquals 0 $?
    assertEquals 'hoge fuga' "$(git log -1 --format=%s)"
    assertEquals "" "$(git nyt base)"
}


test__clear_base()
{
    assertEquals "" "$(git config nyt.base)"
    echo b > b.txt
    git add b.txt
    git nyt commit -m 'hoge'
    assertEquals "" "$(git config nyt.base)"
    echo c >> b.txt
    git nyt commit -a -m 'fuga'
    assertEquals "" "$(git config nyt.base)"
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
    git nyt diff --name-only
    assertNotEquals "0" "$?"
}

test__fixup()
{
    for i in $OneToFive; do 
	echo $i > "file $i.txt"
	git add "file $i.txt"
	git nyt commit -m "commit: $i"
    done
    git nyt fixup -m 'commit: one'
    assertEquals "0" "$?"
}

test__fixup_part()
{
    for i in $OneToFive; do 
	echo $i > $i.txt
	git add $i.txt
	git nyt commit -m "commit: $i"
    done
    git nyt list | tail -n 3 | git nyt fixup-part -m 'hoge hoge'
    assertEquals 'commit: 2' "$(git log --pretty=%s -1)"
    assertEquals 'commit: 1' "$(git log --pretty=%s -2| tail -n1)"
    assertEquals 'hoge hoge' "$(git log --pretty=%s -3| tail -n1)"
    assertEquals '3.txt
4.txt
5.txt' "$(git diff HEAD~2 HEAD~3 --name-only)"
}

#test__bleis()
#{
#    echo 1 > 1.txt
#    git add 1.txt
#    git nyt bleis -m 'commit: 1'
#    assertEquals 1 $(git log --pretty=oneline | wc -l)
#    echo 2 > 1.txt
#    git add 1.txt
#    git nyt bleis -m 'commit: 2'
#    assertEquals 2 $(git log --pretty=oneline | wc -l)
#    echo 3 > 2.txt
#    git add 2.txt
#    git nyt bleis -m 'commit: 3'
#    assertEquals 2 $(git log --pretty=oneline | wc -l)
#}

. ../shunit2-2.1.6/src/shunit2