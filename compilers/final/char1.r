function lala(c:char, d:ref char) : char is
        if c>d -> return (c)
        | true -> return (d)
        end
end

var     c,d,e:char
var     s:string
var     i:integer

c:='$'
d:='\n'

printc(c)
printc(d)
printc('a')
printc('\\')
printc('\n')

printc(lala('a', d))


s:="12345678"
i:=3
c:=s[i]
d:=s[0]
e:=s[15]

printc(c)
printc(d)
printc(e)

i:=1
printc(s[i])
printc(s[2])

i:=3
c:="coco"[i]
printc(c)
printc("lala"[i])

c:="coco"[1]
printc(c)
printc("coco"[2])

printc(lala("haha"[2], s[1]))


