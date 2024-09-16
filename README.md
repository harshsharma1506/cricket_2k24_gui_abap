# :cricket_game: cricket_2k24_gui_abap

This is an ABAP version of an offline game that kids play in India, it's often called 'Hand Cricket', it revolves around the odd 
and even numbers for decision making. 

For more info, go through [ this article ](https://www.instructables.com/How-to-Play-Hand-Cricket/)

```
Rules of the game

1. User chooses their toss ,i.e. ODD or EVEN number
2. Then both the user and the bot take out a random number
3. The sum of both the number is done and then, if the sum is odd the one who took odd wins and
   gets to choose whether to bat or bowl, or vice versa.
4. There are 10 wickets and 2 innings
5. When batting the score gets calculated on the basis of the sum of your inputs
6. If the number that the batting person and balling person choose is the same, the wicket is counted.
```


## Controls 

```
In the ALV grid, after the input
Refresh
Ctrl + S
Refresh
```

## ABAP version 
7.4 

## Suggestions to optimize the current code 

So, at few places I wasn't able to use the ABAP magic which comes in 7.5. 
Hence, there is one loop in the code to calculate the target match that could be done via a select from itab as well 

```abap
"instead of below
LOOP AT g_it_final INTO ls_final_ba_wick.     " in 7.4 +, you can use select sum ( ) from itab
            lv_target_match1 = lv_target_match1 + ls_final_ba_wick-individual_score
ENDLOOP.

"we could have it via
SELECT SINGLE SUM( individual_score ) FROM @g_it_final as itab
      WHERE action = 'Batting'.
```

For , summing as well, new sum operator can be use for incremental sum.

## Selection Screen 

![image](https://github.com/user-attachments/assets/43ac711c-3169-46ec-9d19-be42f40420f5)

## Toss Outcome 

Either you lose 😞
![image](https://github.com/user-attachments/assets/53c52ca1-6a2f-4a3a-8363-107d9c78965e)

Or you win 😉
![image](https://github.com/user-attachments/assets/964cae4d-8b25-44a6-b2fa-1ba1d72220bd)

## Result  

![image](https://github.com/user-attachments/assets/7a196aa8-f6d7-4036-8ccb-23003b6cceeb)


