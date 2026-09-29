--====================================================================--
-- tests/dmc_states_mix_spec.lua
--
-- Unit tests for dmc-states-mixin, using Luna Test.
-- Run with tests/run_unit.sh
--
-- lua-states-mixin has the full specs; these check the wrapper, and
-- that lua-states-mixin's fixes come through it
--====================================================================--


module(..., package.seeall)



--====================================================================--
--== Setup


local StatesMixModule, LuaStatesMix

function suite_setup()
	StatesMixModule = require 'dmc_corona.dmc_states_mix'
	LuaStatesMix = require 'lib.dmc_lua.lua_states_mix'
end

-- the Quick Start's door: closed <-> open, closed <-> locked
local function newDoor()
	local door = StatesMixModule.patch()
	door.refused = {}
	local moves = {
		closed={ open=true, locked=true },
		open={ closed=true },
		locked={ closed=true },
	}
	for state, allowed in pairs( moves ) do
		door[ state ] = function( self, next_state )
			if allowed[ next_state ] then
				self:setState( next_state )
			else
				table.insert( self.refused, state .. '>' .. next_state )
			end
		end
	end
	door:setState( 'closed' )
	return door
end



--====================================================================--
--== Tests


function test_module()
	assert_equal( 'table', type( StatesMixModule ) )
	assert_equal( 'string', type( StatesMixModule.VERSION ) )
	assert_equal( 'function', type( StatesMixModule.patch ) )
	assert_equal( 'table', type( StatesMixModule.StatesMix ) )
end

function test_shared_module_untouched()
	assert_not_equal( LuaStatesMix, StatesMixModule )
	assert_nil( LuaStatesMix.VERSION )
	assert_equal( LuaStatesMix.StatesMix, StatesMixModule.StatesMix )
end

function test_no_global_extend()
	assert_nil( rawget( _G, '_extend' ) )
end

function test_quick_start_door()
	local door = newDoor()
	door:gotoState( 'open' )
	assert_equal( 'open', door:getState() )
	door:gotoState( 'locked' )
	assert_equal( 'open', door:getState() )
	assert_equal( 'open>locked', door.refused[1] )
	door:gotoState( 'closed' )
	door:gotoState( 'locked' )
	assert_equal( 'locked', door:getState() )
	assert_equal( 'closed', door:getPreviousState() )
	door:gotoPreviousState()
	assert_equal( 'closed', door:getState() )
end

-- a refused move used to push the current state anyway (lua-states-mixin 1.4.0)
function test_refused_move_keeps_stack()
	local door = newDoor()
	door:gotoState( 'open' )
	local size = door:_stateStackSize()
	door:gotoState( 'locked' )
	assert_equal( size, door:_stateStackSize() )
	assert_equal( 'closed', door:getPreviousState() )
end

-- the Quick Start's traffic lights: the mixin as a parent class
function test_quick_start_class()
	local StatesMix = StatesMixModule.StatesMix
	local Light = setmetatable( {}, { __index=StatesMix } )
	Light.__index = Light
	function Light:red( next_state ) self:setState( next_state ) end
	function Light:green( next_state ) self:setState( next_state ) end

	local function newLight()
		local light = setmetatable( {}, Light )
		StatesMix.__init__( light )
		light:setState( 'red' )
		return light
	end

	local a, b = newLight(), newLight()
	a:gotoState( 'green' )
	assert_equal( 'green', a:getState() )
	assert_equal( 'red', b:getState() )
end
