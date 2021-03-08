print( string.gsub( "Hello banana", "banana", "Corona user" ) ) 
print( string.gsub( "banana", "a", "A", 2 ) )             -- Limit substitutions made to 2
print( string.gsub( "banana", "(an)", "%1-" ) )           -- Capture any occurances of 'an' and replace
print( string.gsub( "banana", "a(n)", "a(%1)" ) )         -- Brackets around n's which follow a's
print( string.gsub( "banana", "(a)(n)", "%2%1" ) )        -- Reverse any 'an's
print( string.gsub( "Hello Lua user", "(%w+)", function(w) return string.len(w) end ) )  -- Replace with lengths
print( string.gsub( "banana", "(a)", string.upper ) )                                    -- Make all 'a's found uppercase
print( string.gsub( "banana", "(a)(n)", function(a,b) return b..a end ) )                -- Reverse any 'an's
print( string.gsub( "The big {brown} fox jumped {over} the lazy {dog}.", "{(.-)}", function(a) print(a) end ) )
print( string.gsub( "The big {brown} fox jumped {over} the lazy {dog}.", "{(.*)}", function(a) print(a) end ) )
