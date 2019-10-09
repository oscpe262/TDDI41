# TDDI41 - Introduction to System Administration

The full lab series can be found at [https://www.ida.liu.se/~TDDI41/labs/index.en.shtml]. That said, this repo is for learning purposes only. I personally don't give a crap if you hand this stuff in, risk being suspended or what not. That is your problem, not mine. Keep in mind that this is a public repo, and since you could find it, so can your examiner.

However, I do mind if you've passed this course and don't know your shit if we happen to work together at some point. I do know that even for an experienced Linux user, stuff you can't control can make this lab series take way longer than expected to finish. Therefore, this is available.

Here, you will find:
- near complete lab reports (feel free to contribute where incomplete)
- complete idempotent bash scripts for all labs (decently annotated, feel free to improve and contribute) to cover grade 3
- ansible roles and cookbook (yet to be tested though) to set up everything apart from rudimentary parts of NET and SCT7 (SCT7 to be added at some point)

You will not find:
- ansible tests (TBA)
- grade 5 stuff, as I intended to be a guinea pig for the Kerberos lab, but never got around to it.

Other stuff that can be found on my github page in regards to this course:
- A guide to start you up with Ansible (grade 4)
- Ansible roles for installing FreeIPA and joining clients (grade 5), though I haven't focused on getting it to work for Debian, nor are they very well polished.

Other noteworthy stuff:

NIS is horrible. Seriously. There should never again be a NIS server set up in this world if I could have a say. It's insecure, it is horrible to administrate on a larger scale without customized tools, it's insecure, and did I mention it is insecure? That said, if you ever work as a sysadmin in the next ten years, the possibility of you coming across a NIS domain is far higher than 0. Learning how it works, and how to administrate it, isn't a bad thing, but you should never set up a NIS domain again once this course is over. Any old NIS domain you come across should be migrated to LDAP (guess what, LDAP can serve NIS stuff if need be) ASAP.

If you ever plan on doing sysadmin stuff outside this course (and I think you should if you find this course even the slightest amusing), make sure to put some time into getting a grasp on LDAP and Kerberos. It's not hard, and it is used everywhere. Sure, it might go under the name 'Active Directory' and be extended from the standard protocols (as always with Microsoft - "embrace, extend, extinguish" you know (and if you don't, google it)), but it's there, and not many AD technicians know how it actually works behind their GUIs, so when it doesn't work, they spend hours with MS Support or come and ask us Linux admins to help out. Okay, that last thing never really happens, because they don't even have a clue that we know that shit, but they should. :p

And yes, the grading system on this course sucks donkey balls. Configuration management should be grade 3, LDAP+Kerberos should be grade 4, writing shell scripts should be grade 5, because that's how system administrations should be done today. Home-cooked scripts are used, and you need to know how to read them, but you should very rarely write an advanced one, because it has already been done, and it's most likely implemented in, for instance, Ansible. So, do yourself a favour and do this course in Ansible. It doesn't take much extra time, some aspects may even take less time (in particular if you use my roles or roles found on Ansible Galaxy), and then you are doing stuff the right way. Plus, if something goes belly-up, you can reroll it in no-time.

## Examiners
I've made all repos I used during my time at LiU available once the course was done that term. There has been a few occasions where those who run the course has contacted me asking for me to take down the repo or make it private. Just to save you the time of writing a mail to me about it, the answer is always 'no'. There has been one exception due to the nature of the course in question, but this course is not like that one.

Here is the thing ... You as an examiner have the obligation to ensure that each student has aquired the necessary skills/knowledge, and short technical answers to a set of questions that are the same each year does not ensure the proficiency of a student. It only ensures that someone has had the proficiency at one point. Of course, such a set of questions is a great tool for aiding learning, and it should be treated as such. The scripting part of the labs done here is fairly unique and my guess is that you'll rarely see it done this way (as it is major overkill to write a configuration management tool in bash when it won't render you a higher grade).

If someone uses my Ansible roles (be that from this or any of my other repos), it should be encouraged. The golden rules of a sysadmin are after all "don't do something twice" and "don't reinvent the wheel".

## Requirements
This is for the HT2016 edition of the lab series, be observant that the labs are subject to change.

## License

BSD

## Contributors

Issues, feature requests, ideas, suggestions, etc. are appreciated and can be posted in the Issues section. Pull requests are also very welcome. Please create a topic branch for your proposed changes, it's the easiest way to merge back into the project.

- [Oscar Petersson](https://github.com/oscpe262/) (Maintainer)
