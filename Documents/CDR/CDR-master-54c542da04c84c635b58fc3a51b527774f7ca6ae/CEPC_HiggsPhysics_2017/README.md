# Project Name

CEPCHiggsPaper

---

## Instruction

This project documents CEPC Higgs measurement results and the physics interpretations, aiming for a paper to be published in Summer 2017. 
The  paper will demonstrate the physics potential of the CEPC experiment and will be used as a reference for the CEPC CDR.

If you want to modify the paper draft, you need to register at https://github.com/, and send your username to jinwang.cepc@gmail.com.
An invitation email will be send to you and you will get full access rights after you accepted the invitation.

---

## Usage

Below is a very simple instruction on the usage of git only for those who never used git. 
This instruction resembles the svn and ignores some key features of git.

* To download the repository (same as "svn co"), do:

   `git clone https://github.com/ijinwang/CEPCHiggsPaper`

* Once you created a new file or made any changes on existing file "modifiedfile.tex", do (similar as "svn ci -m" but not submit to the server yet):

   `git add modifiedfile.tex`  (In svn you use "svn add" to stage a new file. While in git both new files and new modifications need to be staged with "add")

  `git commit -m "messages about your modifications"`

  You can also use "-am" to do the "add" and "commit" the same time with all the changes you made (but if there are new files/directories, you need to use the full version "git add"):

  `git commit -am "messages about your modifications`

* If you want to push the commits you’ve done back up to the server (this plus previous step will serve as "svn ci -m" and it requests access rights):

  `git push`

* Before uploading your modifications, you should update your local repository first (same as "svn update"):

  `git pull`

* You should be fine with above few lines to edit the note as you want. The following are some addtions.

  "git pull" will fetch the most updated version from the server and will merge it with your local version.
  It won't overwrite your local modification (same as "svn update"). 
  You have to commit your changes first before "git pull", otherwise there will be warnings/errors.

  There will also be warnings if there are conflicts (the same line edited differently by you and others) between the local version and the version on the server, 
  In this case, after "git pull " you can find all the information in the conflicted file. 
  It will be shown as below with a conflict-marked area between `<<<<<<<` and `>>>>>>>`, and the two conflicting blocks divided by a `=======`.

  `<<<<<<<` HEAD (conflict marker begins, "HEAD" points to your repository)

  your modification  (this is your version)

  `=======`

  modification on server (this is the version on server)

  `>>>>>>>` branch-name (conflict marker ends, "branch-name" is the repository on servers)

  You should edit the file and replace the whole conflict area with your preferred solution, and do "git commit -am" and "git push" to upload your solution of the conflicts.
  Note that if conflicts exists you have to fix the conflicts as shown above before moving forward with other actions, otherwise it will be messy.



* The following commands need to be used with extra caution.

  For uncommited modifications, if you want to discard them (make sure you want to do this!!) and restore previous version, use:

  `git checkout -- modifiedfile.tex`

  or discard all modifications:

  `git checkout -- . `

  For committed modifications, if you want to discard them (make sure you want to do this!!), first find the id of all committed modifications:

  `git log`

  and then restore the one you prefer:

  `git reset --hard 5775d213fc5450760a4521fd061ff2c7af2e1552`  (this number is the the SHA-1 hash of the commit which you will find in "git log")

* To delete a file on server (make sure you want to do this!!), do 

  `git rm filetobedeleted.tex`

  `git commit -am "I want to delete this badly"`

  `git push`

---

## More

To make the best use of git, please read:

https://git-scm.com/book/en/v2

You  can also easily find answers on google if you meet any problem or need new operations with git.
