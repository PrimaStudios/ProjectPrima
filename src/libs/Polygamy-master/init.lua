--[==[--------------------------------------------------------------------------

                       The romantic WTF public license.
                       --------------------------------
                       a.k.a. version "<3" or simply v3
                       
               Dear user,
               
                       Polygamy, Copyright 2010, 
                                    Pierre-Yves Gérardy,   
                                                    | 
                                                  | / --
                                                  / --
                                                / 
                           has been          released
                   under the WTF public  license version "<3".
                  I hereby grant you an irrevocable license to
                     do what the gentle carress you want to
                              with   this   lovely
                                  /framework.
                                /    Love
                           |  /        ,
                           |7L_ 
              
               -- Pierre-Yves.

               P.S.: Even though I poured my heart into this work, 
                     I _cannot_ provide any warranty regarding 
                     it's fitness for _any_ purpose. You
                     aknowledge that I will not be held liable
                     for any damadge it's use could incur.

--]==]--------------------------------------------------------------------------



Polygamy={path=string.sub(...,1,-5)}

require(Polygamy.path.."tools.Tools")

---[==[ --The magic crossed comment trick :-)
Polygamy.debug=Polygamy.Tools.nop
--[[ ]==]
Polygamy.debug=debug_
--]]
local P, Tools, nop, debug_ = Polygamy, Polygamy.Tools, Polygamy.Tools.nop, Polygamy.debug

-- Polygamy.scheduleTransition=nop
-- Polygamy.setCallback = nop 
-- Polygamy.removeCallback=nop


-- love.run --------------------------------------------------------------------
 --========--
 
function love.run()
	local delta
	local running = true
	local setCallback, removeCallback
 
	-- Stubs and backups --
	---------------------------------------------------------	
 
	love.update = love.update or nop
	love.draw = love.draw or nop
	love.graphics = love.graphics or {clear=nop, present=nop}
	love.timer = love.timer or {getDelta=function()return 0 end, sleep=nop, step=nop}
	love.event = love.event or {poll=nop}
 
	P.handlersBackup={} -- used when (de)activating modules. holds [j|k|m]p and 
	                    -- [j|k|m]r callbacks
	                    -- See useInit() and makeLove() in PolyKeyboard for 
	                    -- an example.
	
	---------------------------------------------------------	



	-- The callback machinery... --
	---------------------------------------------------------	
 
	local callbacks={}     -- ordered array, used in the main loop
	local callbackIndex={} -- index of the former. name => position.
	local callbackOrder={"polykeyheld", "polytimer", "update", "clear", "draw"}
	local changeQueue, changeIndex = {}, 1
 	local notListedNumber=0
	-- Public interface:

 	function P.setCallback(name,cb)
	debug_'P.setCB'
		table.insert( changeQueue, {action="set", name=name, cb=cb} )
	end
	
	function P.removeCallback(name)
	debug_'P.removeCB'
		table.insert( changeQueue, {action="remove", name=name} )
	end
	
	function Polygamy.scheduleTransition(func,args)
		debug_'P.schedTrans'
		table.insert( changeQueue, {action = "transition", func=func, args=args} )
	end
	
	local function manageCallbacks() -- called in the main loop
		while changeQueue[changeIndex] do
			debug_("ManageCB",changeIndex)
			debug_(changeQueue[changeIndex].action)
			
			if changeQueue[changeIndex].action == "set" then
				setCallback( changeQueue[changeIndex].name, changeQueue[changeIndex].cb )
			
			elseif changeQueue[changeIndex].action == "remove" then
				removeCallback(changeQueue[changeIndex].name)
				
			elseif changeQueue[changeIndex].action == "transition" then
				changeQueue[changeIndex].func(changeQueue[changeIndex].args())
			
			else 
				error("Bad action requested: "..tostring(changeQueue[changeIndex].action) )
			end
			
			changeQueue[changeIndex] = nil
			changeIndex = changeIndex+1
		end
		changeIndex = 1
	end
	
	
	function setCallback( name, cb )
		debug_("inner SetCB",name)
		if callbackIndex[name] then 
			callbacks[callbackIndex[name]]=cb
			
			for k,v in ipairs(callbacks) do debug_(k,v) end
			for k,v in pairs(callbackIndex) do debug_(k,v) end

			return 	
		end

		local position = 1
		local found = false
		
		for k,v in ipairs(callbackOrder) do
			debug_(v)
			if v==name then found = true; position = position + notListedNumber break end
			
			if callbackIndex[v] then
				position = position + 1
			end
			debug_(position)
		end
		debug_(name, postion, found)
		if not found then 
			position=1
			notListedNumber = notListedNumber + 1
		end
		
		for k,v in pairs(callbackIndex) do
			if v >= position then
				callbackIndex[k] = v+1
			end
		end
		debug_(name, postion, found)		
 
		callbackIndex[name]=position
		table.insert( callbacks, position, cb )
		for k,v in ipairs(callbacks) do debug_(k,v) end
		for k,v in pairs(callbackIndex) do debug_(k,v) end
	end
 
	function removeCallback(name)
		assert(callbackIndex[name], "Trying to remove a non existent callback" )
 
		for k,v in pairs( callbackIndex ) do
			if v > callbackIndex[name] then k=v-1 end
		end
 
		array.remove(callbacks, callbackIndex[name] )
		callbackIndex[name]=nil
	end
 
	---------------------------------------------------------		
 
	setCallback( "update", love.update )
	setCallback( "clear", function() love.graphics.clear() end )
	setCallback( "draw",  function() love.draw() end )
 
 
	-- quit	 --
 
	love.handlers.q=function()
		if love.audio then
			love.audio.stop()
		end
 
		running=false
	end
 
 
	-- at last --
	function patatraf()
		for k,v in pairs(callbackIndex) do debug_(k,v) end
	end

	if love.load then love.load() end
 
 
    ----------------------------------------
    ------    Main loop.   -----------------
    ----------------------------------------
 
    while running do
	
        love.timer.step()
		delta = love.timer.getDelta()
		manageCallbacks()

		-- love.update, love.draw, and more if you want
		for _,cb in ipairs( callbacks ) do
			cb( delta )
		end
 
        -- Process events.
        for e,a,b,c in love.event.poll() do
            love.handlers[e](a,b,c)
        end
 
        love.timer.sleep( 1 )
		love.graphics.present()
    end
 
end -- /love.run ---------------------------------------------------------------





---  Polygamy  -----------------------------------------------------------------
 --========-- 
do
-------------------------------
-- autoload at first access. --
-------------------------------

local moduleIndex = {
	keyboard="PolyKeyboard",
	timer="PolyTimer",
	timeline="PolyTimer",
	state="PolyState"
}

Polygamy.loadedmodules=Tools.Set:new()


setmetatable( P, {
	__index = function(_, module_)
		if moduleIndex[module_] then
			require(Polygamy.path .."modules/" .. moduleIndex[module_] .. ".lua");
			(P[module_].init or Tools.nop)()
			return P[module_]
		else 
			return nil
		end
	end
})

-- and load the state module --

-- local s=P.state ; s=nil

---------------
-- Constants --
---------------
for k, v in pairs( { 
	default   = {}, 
	before    = {}, 
	after     = {} 
} ) do Polygamy[k]=v end



end -- /Polygamy ---------------------------------------------------------------

return function() debug_ "paf" end
