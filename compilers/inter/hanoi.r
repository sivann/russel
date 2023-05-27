	{ lala coco }

function hanoi (rings:integer, source:string, target : string , auxiliary :
string) is

	function move ( source : string, target:string) is
		prints ( "Moving from " )
		prints( source )
		prints ( " to " )
		prints (    
		target 
		)
		prints(".\n")
	end

	if rings >= 1 ->
		hanoi ( rings-1, source, auxiliary, target ) move ( source, target)
		hanoi (rings  - 1, auxiliary, target, source )
	end
end

var	NumberOfRings : 
integer

prints("Rings: ")
NumberOfRings := readi()
hanoi(NumberOfRings, "left","right","midlle")


