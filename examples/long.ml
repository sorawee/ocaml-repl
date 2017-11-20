let rec f : int -> int
  = fun a ->
    if a = 0 then 0
    else f (a - 1);;

f 1000000000
