function prime (n: integer) : boolean is
	var i: integer

	if n < 0 ->
		return (prime(-n))
	| n < 2 ->
		return (false)
	| n = 2 ->
		return (true)
	| true ->
		i:=3
		do i <= n div 2 ->
			if n mod i = 0 ->
				return (false)
			end
			i := i+2
		end
		return (true)
	end
end

var limit, number, counter : integer

prints("Limit: ")
limit := readi()
prints("Primes:\n")
counter := 0
if limit >= 2 ->
	counter := counter + 1
	printi(2)
	prints("\n")
end
if limit >= 3 ->
	counter := counter + 1
	printi(3)
	prints("\n")
end
number := 6
do number <= limit ->
	if prime(number-1) ->
		counter := counter + 1
		printi(number-1)
		prints("\n")
	end
	if (number <> limit) and prime(number+1) ->
		counter := counter + 1
		printi(number+1)
		prints("\n")
	end
	number:=number+6
end
prints("\nTotal: ")
printi(counter)
prints("\n")


