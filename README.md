## dmc-states-mixin ##

Add State Machine capability to your Lua Objects in Corona SDK

This module can add State Machine capability to any of your objects. It can be used either as a mixin class or by "monkey-patching" your object. It has been integrated in [dmc-objects](https://github.com/dmccuskey/dmc-objects) as a mixin. (This module is really just a loader for [lua-states-mixin](https://github.com/dmccuskey/lua-states-mixin).


### Features ###

* state methods

  getState(), setState(), gotoState()
  
  getPreviousState(), gotoPreviousState()
  
  pushStateStack(), popStateStack()
  
  resetStates(), setDebug()


### Examples ###

#### Mixin Class ####

This module can be used as a mixin project [dmc-objects](https://github.com/dmccuskey/dmc-objects) contains the `ObjectBase` sub-class which shows how to use this module as a mixin with multiple inheritance.

Here it is in a nutshell:

```lua
-- import the events mixin module (adjust path for your project)
local StatesMixModule = require 'dmc_corona.dmc_states_mix'

-- create ref to mixin (optional)
local StatesMix = StatesMixModule.StatesMix

-- do multiple inheritance !
NetStream = newClass( { ObjectBase, StatesMix } )

-- Then call init method (example using dmc-objects)
self:superCall( ObjectBase, '__init__', params )
self:superCall( StatesMix, '__init__', params )


-- When destroying, you can call __undoInit__
self:superCall( ObjectBase, '__undoInit__' )
self:superCall( StatesMix, '__undoInit__' )

```


#### Monkey Patching ####


```lua
--== Import module

local StatesMixModule = require 'dmc_corona.dmc_states_mix'


--== Patch an object ==--

-- create one for yourself (eg, with OOP library)

local obj = {}  -- empty or create one from your OOP library
obj = StatesMixModule.patch( obj ) -- returns object

-- or have patch() create one for you

local obj = StatesMixModule.patch()  -- returns a new object

```

