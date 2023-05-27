var     a:boolean
var     x,y:integer

x:=10
y:=0
a:=true

do
a ->
        if
        a and (x>=y) ->
                printi(x)
                prints(" ")
                printi(y)
                prints("\n")
                x:=x-1
        |
        true ->
                if
                y<=10 ->
                        x:=10
                        y:=y+1
                |
                true ->
                        a:=false
                end
        end
end


