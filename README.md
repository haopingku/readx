# readx

Readx is an reverse engineering tool that charts instruction flows.

(It's neccessary to have Ruby interpreter.)

If you have an executable file, say, `./a` on you local machine. Simply using
```bash
ruby readx ./a
```
then file `readx_a.html` is created. You can see data and instruction flows by open it with your browser.

In another scenario, if the executable is not compatible on you local machine, for example, Linux ELF on Windows. Please first send the file to a Linux machine and get dumped files. Readx now supports

* `objdump`'s `-d` (disassemble) and `-s` (full contents)
* `readelf`'s `-h` (file header)

Getting dumped files by command like `objdump -sd ./a >objdump_sd`, then send it back to your local machine and type

```bash
ruby readx --dumpfile readelf_h objdump_sd
```
and the HTML file created.

Also, you can add
```bash
source /<dir_to_this_repo>/etc/complete.bash
```
to your `~/bshrc` for auto command completing.

Screenshots of readx
![](https://raw.githubusercontent.com/haopingku/readx/master/test/example-summary.jpg)
![](https://raw.githubusercontent.com/haopingku/readx/master/test/example-content.jpg)
![](https://raw.githubusercontent.com/haopingku/readx/master/test/example-flow.jpg)