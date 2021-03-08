# *Vim* Cheat Sheet
*Vim* is an advanced CLI based text editor. Many key combinations used in *Vim* are easily associated with a memorable phrase. One effective way to use *Vim* is to associate phrases with *Operators*, *Text Objects* and *Motions*. Then compose a phrase for what you want to do. Start with an *Operator* followed by a *Text Object* or *Motion*. Prefix an *Operator*, *Command* or *Motion* with a number/count to extend it.

##### Table of Contents
- [Modes](#modes)
- [Operators](#operators)
- [Motions](#motions)
  - [Left-Right Line Motions](#left-right-line-motions)
  - [Up-Down Motions](#up-down-motions)
  - [Word Motions](#word-motions)
  - [Text Object Motions](#text-object-motions)
  - [Jump Motions](#jump-motions)
- [Text Objects](#text-objects)
- [Command-Lines](#command-lines)
  - [Buffers](#buffers)
  - [Windows](#windows)
  - [Tabs](#tabs)
  - [Multi-File Command-Lines](#multi-file-command-lines)
- [Commands](#commands)
- [Insert Mode](#insert-mode)
- [Terminology](#terminology)
- [Caveats](#caveats)
- [Useful Plugins](#useful-plugins)
- [Additional Information](#additional-information)
- [References](#references)

### Modes
Essentially a *Mode* sets the available keyboard interactions. The default *Mode* is *Normal* when *Vim* is started.

**`Esc`** - *[Normal]()* –– *Commands*, *Operators*, *Motions*, *Text Objects* and navigation  
**`i`** - *[Insert]()* –– *Insert* text, word and line completion  
**`:`** - *[Command-Line]()* –– *Vim* internal *Command-Lines*, *Operators* and external *Shell Commands*  
**`v`** - *[Visual]()* –– *Visual* selecting  
**[TOC](#table-of-contents)**  

### Operators
Operators are generally used to delete or change text. A *Motion* or *Text Object* may be used after an *Operator*.

**`y`** - *[Yank]()* –– copy text  
**`d`** - *[Delete]()* –– cut text  
**`c`** - *[Change]()* –– cut and enter *Insert* Mode  
**`>`** - *[Indent]()* –– shift text right  
**`<`** - *[Unindent]()* –– shift text left  
**`gU`** - *[Uppercase]()* –– make text uppercase  
**`gu`** - *[Lowercase]()* –– make text lowercase  
**`~`** - *[Toggle Case]()* –– toggle case of character(s)  
**`!`** - *[Shell Command]()* –– External Filter  
**`=`** - *[Format]()* automatically  
**[TOC](#table-of-contents)**  

### Motions
*Motions* move the cursor and may be used after an *Operator* to define a text range in which to operate.
##### Left-Right Line Motions
**`h`** - *[Left]()* –– cursor left one character  
**`l`** - *[Right]()* –– cursor right one character  
**`0`** - *[First]()* –– cursor to first character of line  
**`^`** - *[First]()* –– cursor to first non-blank character of line  
**`$`** - *[End]()* –– cursor to last character of line  
**`g_`** - *[Go]()* to last –– cursor to last non-blank character of line  
**`f<character>`** - *[Find]()* the next character after the cursor  
**`F<character>`** - *[Find]()* the next character before the cursor  
**`t<character>`** - *[Till]()* the next character after the cursor  
**`T<character>`** - *[Till]()* the next character before the cursor  
**[TOC](#table-of-contents)**  

##### Up-Down Motions
**`k`** - *[Up]()* –– cursor up one character  
**`j`** - *[Down]()* –– cursor down character  
**[TOC](#table-of-contents)**  

##### Word Motions
**`w`** - *[Word]()* –– cursor to start of word  
**`W`** - *[Word]()* –– cursor to start of word (non-blank characters separated by whitespace)  
**`e`** - *[End]()* –– cursor to end of word  
**`E`** - *[End]()* –– cursor to end of word (non-blank characters separated by whitespace)  
**`b`** - *[Back]()* –– to begining of word before cursor  
**`B`** - *[Back]()* –– to begining of word before cursor (non-blank characters separated by whitespace)  
**`ge`** - *[Go End]()* –– to end of word before cursor  
**`gE`** - *[Go End]()* –– to end of word before cursor (non-blank characters separated by whitespace)  
**[TOC](#table-of-contents)**  

##### Text Object Motions
**`)`** - *[Sentence]()* –– cusor forward a sentence  
**[TOC](#table-of-contents)**  

##### Jump Motions
**`Ctrl`**+**`f`** - *[Forward]()* –– cursor page down  
**`Ctrl`**+**`b`** - *[Back]()* –– cursor page up  
**`H`** - *[Home]()* top line of window  
**`M`** - *[Middle]()* line of window  
**`L`** - *[Last]()* line of window  
**`gg`** - *[Go]()* to top of file  
**`G`** - *[Go]()* to end of file  
**`#gt`** - *[Go To]()* tab number #  
**[TOC](#table-of-contents)**  

### Text Objects
*Text Objects* may be used after an *Operator* to define a text range in which to operate.

**`w`** - *[Word]()*  
**`s`** - *[Sentence]()*  
**`p`** - *[Paragraph]()*  
**`t`** - *[Tag]()*  
**`i`** - *[Inside]()*  
**`iw`** - *[Inner Word]()*  
**`it`** - *[Inner Tag]()*  
**`ip`** - *[Inner Paragraph]()*  
**`as`** - *[A Sentence]()*  
**[TOC](#table-of-contents)**  

### Command-Lines
A *Vim* *Command-Line* should not be confused with a *Command* in *Normal* Mode or a *Shell Command*. Complete a *Command-Line* by **`Enter`** or **`Return`** key.

**`:h`** - *[Help]()* open help view  
**`:q`** - *[Quit]()* quit current view. quits vim if no views are open  
**`:q!`** - *[Quit]()* quit and ignore any modifications  
**`:w`** - *[Write]()* buffer to file (save)  
**`:wq`** - *[Write]()* and *[Quit]()* (save, exit)  
**`/`** - *[Search]()* after cursor for match –– *Jump Motion*  
**`?`** - *[Search]()* before cursor for match –– *Jump Motion*  
**`:edit!`** - *[Reload]()* reload current file ignoring any buffer modifications  
**`:#,#m#`** - *[Move Lines]()* move line number range #,# to line number #  
**`:noh`** - *[No Highlights]()* clear search highlights  
**`:set paste`** - *[Paste]()* enable *Insert Paste* sub-mode which does not format pasted text  
**`:set nopaste`** - *[No Paste]()* disable *Insert Paste* sub-mode  
**`:!<shell-command>`** - *[Interpret]()* *Shell Command*  
**`:%w !pbcopy`** - *[Copy]()* whole buffer to clipboard –– OS X specific  
**`:%w !xclip -i -sel c`** - *[Copy]()* whole buffer to clipboard –– GNU/Linux Distribution specific  
**`:%w !xsel -i -b`** - *[Copy]()* whole buffer to clipboard –– GNU/Linux Distribution specific  
**`:%s/old/new/gc`** - *[Substitute]()* all *old* occurences with *new* throughout file with confirmations. similar to **`sed`**  
**`:%s/\%Vold/new/gc`** - *[Substitute Selection]()* substitute in last visual selection all *old* occurences with *new* throughout file with confirmations.  
**[TOC](#table-of-contents)**  

##### Buffers
**`:ls`** - *[List]()* numbered buffers (loaded files)  
**`:ls!`** - *[List]()* numbered buffers including hidden ones  
**`:#bw`** - *[Buffer Wipeout]()* –– wipeout buffer by # number  
**`:b#`** - *[Buffer Show]()* –– show buffer by # number in current view  
**[TOC](#table-of-contents)**  

##### Windows
*ToDo*
**[TOC](#table-of-contents)**  

##### Tabs
**`:tabnew <file>`** - *[New Tab]()* –– open file in a new tab  
**`:tabnew +b#`** - *[New Tab]()* –– open existing buffer by number # in a new tab  
**`:tabm #`** - *[Tab Move]()* –– move tab to position number #  
**`:tab ball`** - *[Tab All]()* –– open all existing buffers in tabs  
**[TOC](#table-of-contents)**  

##### Multi-File Command-Lines
*ToDo*
**[TOC](#table-of-contents)**  

### Commands
*Normal* Mode *Commands* which may or may not enter *Insert* Mode.

**`A`** - *[Append]()* to end of line  
**`a`** - *[Append]()* after cursor  
**`o`** - *[Open]()* new blank line below  
**`O`** - *[Open]()* new blank line above  
**`D`** - *[Delete]()* (cut) to end of line  
**`C`** - *[Change]()* to end of line (delete, enter insert mode)  
**`Y`** - *[Yank]()* (copy) whole line  
**`p`** - *[Paste]()* after cursor  
**`P`** - *[Paste]()* before cursor  
**`Ctrl`**+**`r`** - *[Redo]()*  
**`.`** - *[Repeat]()* last command  
**`u`** - *[Undo]()*  
**[TOC](#table-of-contents)**  

### Insert Mode
**`Ctrl`**+**`n`** - *[Next]()* match –– *Word* completion  
**`Ctrl`**+**`p`** - *[Previous]()* match –– *Word* completion  
**`Ctrl`**+**`x`** **`Ctrl`**+**`l`** - *[Line]()* completion  
**[TOC](#table-of-contents)**  

### Terminology
**`Filter`** - A program or *Shell Command* that accepts text at standard input, changes it in some
way, and sends it to standard output.  

**`Shell Command`** - Any external (outside of *Vim*) executable providing a command-line interface (CLI).  
**[TOC](#table-of-contents)**  

### Caveats
Substitution search pattern **`\n`** matches a line-feed character whereas **`\n`** does NOT insert a line-feed in the replacement (**`:%s/\n/\n/`**). Try using **`\r`** instead (**`:%s/\n/\r/`**).  
**[TOC](#table-of-contents)**  

### Useful Plugins
*[Tabulous](https://github.com/webdevel/tabulous)* - Enhanced tabline  
*[Pathogen](https://github.com/tpope/vim-pathogen)* - Runtime path manager  
*[NERDTree](https://github.com/scrooloose/nerdtree)* - File tree explorer  
*[CtrlP](https://github.com/ctrlpvim/ctrlp.vim)* - Fuzzy file finder  
*[Repeat](https://github.com/tpope/vim-repeat)* - Repeat plugin maps  
*[Surround](https://github.com/tpope/vim-surround)* - Surrond text with characters  
*[Commentary](https://github.com/tpope/vim-commentary)* - Add code comments  
*[Fugitive](https://github.com/tpope/vim-fugitive)* - Git wrapper  
**[TOC](#table-of-contents)**  

### Additional Information
[Vim.Org](http://www.vim.org/)  
[VimDoc](http://vimdoc.sourceforge.net/)  
[VimGitHub](https://github.com/vim/vim)  
[VimAwesome](http://vimawesome.com/)  
[VimAdventures](http://vim-adventures.com/)  
**`$ vimtutor`**  
**[TOC](#table-of-contents)**  

### References
*[ViEmu.Com](http://www.viemu.com/vi-vim-cheat-sheet.gif)* –– Vim cheat sheet  
*[Vim.Rtorr.Com](http://vim.rtorr.com/)* –– Vim cheat sheet  
*[TuxRadar.Com](http://tuxradar.com/content/vim-master-basics)* –– *Vim* modes  
**[TOC](#table-of-contents)**  

