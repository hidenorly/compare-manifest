# What's this?

This script can enumerate git path diff listed in .repo/manifest.xml

```
$ ./comp-manifest.rb --help
Usage: [operation(default:"2 - 1")] <origin home dir(1)> <target home dir(2)> [<..>]
./comp-manifest.rb "2 - 1" ~/work/s ~/work/master
```

If you want to list up new gits introduced by Android S from Android R
```
$ ./comp-manifest.rb ~/work/s ~/work/r
```

Note that you need to do ```repo init``` before executing the above.
(But you may not need to do ```repo sync``` if you want to list up only).

If you want to list up new gits introduced by Android R from Android S and you'd like to filter out only in master
```
$ ./comp-manifest.rb "2 - 1 & 3" ~/work/s ~/work/r ~/work/master
```
