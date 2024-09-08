# Summary

This sample simulates a training board such as TK-80.
Now, it only displays seven segments.

To assemble the source file, you need the asm80 command.  
I use [asm80-node](https://github.com/asm80/asm80-node).  


## Useg

Just run rake command.

```
% rake
ruby board.rb
0.000133
 _   _   _   _   _   _   _   _  
| | | | | | | | | | | | | | | | 
|_| |_| |_| |_| |_| |_| |_| |_| 

A:91 F:82 B:4d C:00 D:00 E:00 H:84 L:00 
BC:4d00 DE:0000 HL:8400 PC:0027 SP:fffa
```

It assembles ‘seven_segment.a80’ then generated ‘seven_segment.hex’.  
And load it and then run.  


## Demo

This is a demo running with a simulated NEC training board TK-80.　
I haven't put its program. It is included this book [復活!TK‐80](https://www.amazon.co.jp/復活-TK%E2%80%9080-榊-正憲/dp/4756134017/ref=sr_1_fkmr1_1?crid=7CNL886TOUI7&dib=eyJ2IjoiMSJ9.3wTlBjMJAKD07JSy-RZxBidpuAM_dTvLP7hpY0NPmeBoN0uBqfEYulK7K4aUJEYidREhxmFYKYRoT1I0JacoZM7BgoexTdPQR_OcxSNuo8l8ZK4YHAivXZIINaPzL4Am.c21grxQatW19Ex_NWu53Yr-bt3IedpINKGdsMPW5soc&dib_tag=se&keywords=復活+tk-80&qid=1725758678&sprefix=復活TK%2Caps%2C178&sr=8-1-fkmr1).


[![](https://img.youtube.com/vi/qsoQFyC80Ls/0.jpg)](https://www.youtube.com/watch?v=qsoQFyC80Ls)
