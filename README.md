# dmc-states-mixin

Turn any object in a Solar2D (formerly Corona SDK) app into a state machine: each state is a method of the object, and the current state decides where the object can go next.

dmc-states-mixin is [lua-states-mixin](https://github.com/dmccuskey/lua-states-mixin) packaged like the other DMC Solar2D libraries. Add it to an object in one call, or mix it into a class:

```lua
local StatesMixModule = require 'dmc_corona.dmc_states_mix'

local door = StatesMixModule.patch()
function door:closed( next_state ) self:setState( next_state ) end
function door:open( next_state ) self:setState( next_state ) end

door:setState( 'closed' )
door:gotoState( 'open' )
print( door:getState() )  --> open
```

## Features

- States are plain methods; the current one accepts or refuses each move
- A stack of past states, to go back to the previous one
- Patch an existing object, or use the mixin as a parent class ([dmc-objects](https://github.com/dmccuskey/dmc-objects), or a plain metatable)
- The same module the DMC network libraries run their connections with (dmc-websockets, dmc-netstream)
- Pure Lua, no plugins needed; MIT licensed

## Quick Start

The following code will get you up and running in about 10 minutes in the Solar2D Simulator on macOS or Windows. It makes a door that opens, closes and locks, and refuses to lock while open, then a class of traffic lights that change on a timer.

Prerequisites: the [Solar2D](https://solar2d.com/) Simulator and a copy of this repository (`git clone https://github.com/dmccuskey/dmc-states-mixin.git`, or download the ZIP from GitHub).

### 1. Copy the Library into Your Project

Copy these from this repository into the root of your project folder:

```text
dmc_corona_boot.lua     loader for the DMC libraries
dmc_corona.cfg          configuration
dmc_corona/             dmc-states-mixin and the modules it needs
```

**Going further:** keep the libraries in a subfolder, or combine several DMC libraries ([dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md)).

### 2. Make a Door

Create `main.lua` in the project folder:

```lua
local StatesMixModule = require 'dmc_corona.dmc_states_mix'

local door = StatesMixModule.patch()

-- each state is a method named after it: it gets the requested state
-- and decides whether to go there, by calling setState()

function door:closed( next_state )
	if next_state == 'open' or next_state == 'locked' then
		self:setState( next_state )
	else
		print( "can't go from closed to " .. next_state )
	end
end

function door:open( next_state )
	if next_state == 'closed' then
		self:setState( next_state )
	else
		print( "can't go from open to " .. next_state )
	end
end

function door:locked( next_state )
	if next_state == 'closed' then
		self:setState( next_state )
	else
		print( "can't go from locked to " .. next_state )
	end
end

door:setState( 'closed' )    -- the starting state
door:gotoState( 'open' )
print( door:getState() )
door:gotoState( 'locked' )
door:gotoState( 'closed' )
door:gotoState( 'locked' )
print( door:getState(), door:getPreviousState() )
door:gotoPreviousState()
print( door:getState() )
```

Open the project in the Simulator. The screen stays black; the console shows:

```text
open
can't go from open to locked
locked	closed
closed
```

If the console shows `module 'dmc_corona.dmc_states_mix' not found` instead, `dmc_corona/` is missing from the root of the project folder.

`patch()` adds the state methods to a new table (or to the object you pass it). `setState()` sets the starting state. `gotoState( 'open' )` doesn't change the state itself: it asks the current state, by calling `door:closed( 'open' )`, and that method moves on with `setState()` or refuses. `gotoPreviousState()` asks to go back to the state before, which the door remembers on a stack.

**Going further:** how a move works, and why the DMC libraries do the work of a move in a `do_<state>()` method ([How States Work](https://github.com/dmccuskey/lua-states-mixin#how-states-work)).

### 3. Make a Class of Traffic Lights

Add this to the end of `main.lua`:

```lua
local StatesMix = StatesMixModule.StatesMix

local Light = setmetatable( {}, { __index=StatesMix } )
Light.__index = Light

function Light.new( name )
	local light = setmetatable( { name=name }, Light )
	StatesMix.__init__( light )  -- give it its own state and stack
	light:setState( 'red' )
	return light
end

function Light:red( next_state ) self:setState( next_state ) end
function Light:green( next_state ) self:setState( next_state ) end

local lights = { Light.new( 'north' ), Light.new( 'east' ) }

lights[1]:gotoState( 'green' )  -- one light goes green, the other waits

timer.performWithDelay( 1000, function()
	for _, light in ipairs( lights ) do
		light:gotoState( light:getState() == 'red' and 'green' or 'red' )
		print( light.name, light:getState() )
	end
end, 3 )
```

The Simulator restarts the app when the file is saved. After the door's lines, the console shows a pair of lines each second, three times:

```text
north	red
east	green
north	green
east	red
north	red
east	green
```

`StatesMix` is the mixin: a table of the state methods. `Light` inherits them through its metatable, and each light calls `StatesMix.__init__()` to get a state and a stack of its own. With [dmc-objects](https://github.com/dmccuskey/dmc-objects), mix it in with multiple inheritance instead ([As a Mixin](https://github.com/dmccuskey/lua-states-mixin#as-a-mixin)).

To update, copy `dmc_corona_boot.lua` and `dmc_corona/` again from the newer version. Keep your own `dmc_corona.cfg` if you have changed it.

## Documentation

`require 'dmc_corona.dmc_states_mix'` returns lua-states-mixin's module, so its documentation applies as written:

- [Reference](https://github.com/dmccuskey/lua-states-mixin#reference): `patch()`, `StatesMix`, and every method
- [How States Work](https://github.com/dmccuskey/lua-states-mixin#how-states-work): moves, refusals, and the stack
- [Known Issues](https://github.com/dmccuskey/lua-states-mixin#known-issues) of the state machine

## Configuration

dmc-states-mixin has no settings: `dmc_corona.cfg` needs no section for it, only the `[DMC_CORONA]` section that tells the loader where the libraries are. See [dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md). (The `DEBUG_ACTIVE` setting of the old `[DMC_STATES]` section was never read; call `setDebug( true )` on an object instead.)

## Known Issues

The bugs of the state machine itself are in lua-states-mixin's [Known Issues](https://github.com/dmccuskey/lua-states-mixin#known-issues). In `dmc_states_mix.lua`:

- It sets the global `_extend` (its copy of `Utils.extend()` declares the inner function without `local`).
- Its version (`0.1.0`) isn't available to code.

## Development

Only `dmc_corona/dmc_states_mix.lua` is written in this repository. It loads the DMC boot loader and returns lua-states-mixin's module from `lib.dmc_lua.lua_states_mix`. Everything else is a generated copy; fix it in its own repository, then rebuild:

| file | owner |
|---|---|
| every file in `dmc_corona/lib/dmc_lua/` | [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library), which copies them from the `lua-*` repositories ([lua-states-mixin](https://github.com/dmccuskey/lua-states-mixin), ...) |
| `dmc_corona_boot.lua` | [dmc-corona-boot](https://github.com/dmccuskey/dmc-corona-boot) |

The copies are made by Snakemake from sibling checkouts of the repositories above (`../DMC-Lua-Library`, `../dmc-corona-boot`, `../DMC-Corona-Library` for the shared rules). From this repository's root folder:

```sh
snakemake --cores 1 build_all
```

dmc-states-mixin has no tests of its own; lua-states-mixin's are in its `spec/`. The Quick Start is the check that the package loads in Solar2D.

## License

dmc-states-mixin is released under the [MIT License](LICENSE).
