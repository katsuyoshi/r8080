# Summary

This sample simulates a training board such as TK-80.
Now, it only displays seven segments.

To assemble the source file, you need the asm80 command.  
I use [asm80-node](https://github.com/asm80/asm80-node).  


# Useg

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
