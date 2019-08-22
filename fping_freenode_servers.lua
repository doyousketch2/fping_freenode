#! /usr/bin/env luajit

local serverlist  = {
    {  'irc.freenode.net',  'load balanced location'  },
    {  'chat.freenode.net',  'load balanced location'  },

    {  'barjavel.freenode.net',  'Paris, FR, EU'  },
    {  'card.freenode.net',  'Washington, DC, US'  },
    {  'hitchcock.freenode.net',  'Sofia, Bulgaria, EU'  },
    {  'livingstone.freenode.net',  'NY, USA' },
    {  'moon.freenode.net',  'Atlanta, GA, US'  },
    {  'orwell.freenode.net',  'Amsterdam, NL'  },
    {  'tolkien.freenode.net',  'Sanford, NC, US'  },
    {  'verne.freenode.net',  'Amsterdam, NL'  },
    {  'weber.freenode.net',  'California, USA'  },
}

local server_responses  = {}

for server = 1, #serverlist do
    local fping  = io.popen(  'sudo fping -e ' ..serverlist[server][1]  )
    local output  = fping :read( '*all' )

    if output :find( 'unreachable' ) then  --  verne.freenode.net is unreachable
        os.execute( 'sleep 2' )  --  wait, then try one more time

        fping  = io.popen(  'sudo fping -e ' ..serverlist[server][1]  )
        output  = fping :read( '*all' )
    end  --  unreachable
    fping :close()

    --  example output:  irc.freenode.net is alive (38.6 ms)
    local response_time  = 999  --  set a high default value to begin with

    local parenthesis  = output :find( '%)' )  --  find trailing parenthesis

    if parenthesis then
        response_time  = tonumber(  output :sub( output :find( '%(' ) +1,  parenthesis -4 )  )
    end  --  parenthesis

    server_responses[server]  = {  response_time,  serverlist[server][1],  serverlist[server][2]  }
    print( output )
end  --  #serverlist

table.sort(  server_responses,  function( a, b ) return a[1] > b[1] end  )

local gap = true  --  mind the gap
for key, value in ipairs( server_responses ) do
    --  skip a line after 999's
    if gap and value[1] ~= 999 then print() ; gap = false end

    if value[1] == 999 then print( value[1], value[2], value[3] )
    else print( value[1] ..' ms', value[2], value[3] )
    end

    --  skip a line before final entry
    if key == #server_responses -1 then print() end
end

--  skip one more line
print()
