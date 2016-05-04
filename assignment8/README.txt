To run project:

In terminal:
python [file path here]

How to run CIFAR (Because I don't know how to import files in Python)...

- Go into usr/.../dist-packages/tensorflow/<path-to-cifar10.py/ (or edit the import lines in cifar10_train.py, cifar10_eval.py, cifar10.py, etc. if you know how to import things in Python)

- Add respective inferenceX() methods in cifar10.py
- Change cifar10_train.py and cifar10_eval.py to use inferenceX as appropriate
- Run as usual, $python cifar10_train.py in terminal 1, $cifar10_eval.py in terminal 2
- After a long while, $tensorboard --logdir=/tmp/cifar10_eval/ in termainal 3
- visit 0.0.0.0:6006 in chrome (if you want to see the x axis)
- look at precision @ 1

—————————————————————————————————————————————————————————————————————

 
                       __ __ 
                       (,-^\-\_ 
                      ,'    \ \`-. 
                     '            \             ...mmmmmmm doughnuts...
                    |              : 
                    |        _     | 
                   ,|___   ,' `.   | 
                   ,'   ` |     | /\/\ 
                   |     )\   o // ;-.`                 __ 
                   `._o,'  ;---:_  __/ ____          ,-'  `--. 
                    ,(,`--'      `. \,'_ __`.     ,-'         `. 
                 ,-' (        _,'|---`(  \ \-\   /              `. 
             _,-|  |  \    ,-',-'      \_/_/_/--'._               \ 
            ( \  \-'   `--^--'    '!..             `.              ` 
          ,' `-^-'  ..    .         '`!.             \           _,-\ 
        ,'          `!,   !.          `'    ,.....    \      _,-'_,-`-,---. 
       '|            `'   !.     ...           '``!,   \   ,'   ,'   ,'    \ 
      / :     .           !.   .,'''   ,.!'''           \ /   ,'   ,'      / 
     '   :  ,!'     ....  `'  `'     `''        .  ,.... \   /    /       / 
    '    ; ,!'   ,!'''''      ,-----.           `!  ''''  \ '   ,'.     ,' 
   /   ,'  `!              .-'       `--.       ,!         /  ,'   `. ,' 
  :   ;         ..         |             `.___  `!     .,..\ /       ; 
  :   ;     ..!'''       ,'                   ``-.     `''  \     _,' 
 :   ;     ,''           |     _______            `.         `---'  | 
 :   :         ...       |  ,-'    ,' `-._         |        ,.    | | 
 :    \    ..!''''       |,'     ,'       :-.      |        `!..  | : 
 :     \   `'             \   ,-'         |  \    ,'    ..    `!. | : 
 :      :      ,......     `.'            |   \   |      ``.   `' ; ; 
  :     | ,.       ''''      ._           |    \ /        ;!;    / : 
  :     :  !.                  `-._       | _.--'          ''   /  ; 
   \     \ `!.    ,.!'    ,.....   `------^'        .,..       /  : 
    \     \ `'   ,''       ''''``.                ,!''''      ;   ; 
     \     \    `'                       .!'''                ; ,' 
      \     \          ,.,'            ,!'                   / / 
       `.    \       ,!''    `''`...    '     '!...        ,' / 
         \    \      '            ''     ....   `''   ,---' ,' 
          `.   `.        ,...          .!''''      ,-'    ,' 
            `-.  `--.    `''`'''     __;---.    ,-'    _,' 
               `-.   `-._____,------'       `--'    _,' 
                  `-._                         __,-'                    
                      `---.__            __,--' 
                             `----------' 
