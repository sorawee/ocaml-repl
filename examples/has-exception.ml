exception Foo of string

let i_will_fail () =
  raise (Foo "ohnoooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooes sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss!");;
i_will_fail ();;
"should not evaluate this";;
