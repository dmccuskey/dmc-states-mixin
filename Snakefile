# dmc-states-mixin

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "dmc-states-mixin"
	include: "../DMC-Corona-Library/snakemake/Snakefile"

module_config = {
	"name": "dmc-states-mixin",
	"module": {
		"dir": "dmc_corona",
		"files": [
			"dmc_states_mix.lua"
		],
		"requires": [
			"dmc-corona-boot",
			"DMC-Lua-Library"
		]
	},
	"tests": {
		"files": [],
		"requires": []
	}
}

register( "dmc-states-mixin", module_config )

