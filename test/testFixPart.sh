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
OneToFive="1 2 3 4 5"

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
    assertEquals 'first commit' "$(git log --pretty=%s -4| tail -n1)"
}

alias git-now='git nyt commit -m "[from now] $(date) $(echo $(git diff --pretty=oneline --name-only --cached))"'

test__fixup_by_filename()
{
    for i in $OneToFive; do 
	echo $i > $i.txt
	git add $i.txt
	git-now
    done
    git nyt list | grep -e '3.txt$' | git nyt fixup-part -m 'only 3'
    assertEquals 'only 3' "$(git log --pretty=%s -5| tail -n1)"
    assertEquals '5.txt' "$(git diff HEAD~1 HEAD   --name-only)"
    assertEquals '4.txt' "$(git diff HEAD~2 HEAD~1 --name-only)"
    assertEquals '2.txt' "$(git diff HEAD~3 HEAD~2 --name-only)"
    assertEquals '1.txt' "$(git diff HEAD~4 HEAD~3 --name-only)"
    assertEquals '3.txt' "$(git diff HEAD~5 HEAD~4 --name-only)"
    assertEquals 'first commit' "$(git log --pretty=%s -6| tail -n1)"
}

test__fixup_by_ticket()
{
    echo a >> a.txt
    git add .
    git nyt commit -m 'refs #1'
    echo b >> b.txt
    git add .
    git nyt commit -a -m 'refs #2'
    echo c >> c.txt
    git add .
    git nyt commit -a -m 'refs #2'
    echo d >> d.txt
    git add .
    git nyt commit -a -m 'refs #3'
    echo e >> e.txt
    git add .
    git nyt commit -a -m 'refs #2'
    git nyt list | grep 'refs #2' | git nyt fixup-part -m 'refs #2'
    assertEquals 'refs #2' "$(git log --pretty=%s -3| tail -n1)"
    assertEquals 'd.txt' "$(git diff HEAD~1 HEAD   --name-only)"
    assertEquals 'a.txt' "$(git diff HEAD~2 HEAD~1 --name-only)"
    assertEquals 'b.txt
c.txt
e.txt' "$(git diff HEAD~3 HEAD~2 --name-only)"
    assertEquals 4 $(git log --pretty=oneline | wc -l)
}

test__fixup_stop_when_somthing_is_on_index()
{
    for i in $OneToFive; do 
	echo $i > $i.txt
	git add $i.txt
	git nyt commit -m "commit: $i"
    done
    touch test.txt
    git nyt list | head -n 2 | git nyt fixup-part -m 'hoge'
    assertEquals 6 $(git log --pretty=oneline | wc -l)

    git nyt add test.txt
    git nyt list | head -n 2 | git nyt fixup-part -m 'fuga'
    assertEquals 6 $(git log --pretty=oneline | wc -l)

    git nyt commit -m 'commit: test.txt'
    git nyt list | head -n 5 | git nyt fixup-part -m 'foo'
    assertEquals 3 $(git log --pretty=oneline | wc -l)
}

. ../shunit2-2.1.6/src/shunit2