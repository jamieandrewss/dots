------------------
--- DECORATION ---
------------------

hl.config({
    general = {
   	gaps_in  = 5,
	gaps_out = 20,

	border_size = 2,

	col = {
	    active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
	    inactive_border = "rgba(595959aa)",
	},	

	resize_on_border = false,

	allow_tearing = false,

	layout = "master",
    },

    master = {
        new_status = "slave",
    },

    decoration = {
    	rounding       = 10,
	rounding_power = 2,

	active_opacity   = 1.0,
	inactive_opacity = 1.0,

	shadow = {	
	    enabled      = true,
	    range        = 4,
	    render_power = 3,
	    color        = 0xee1a1a1a,
	},

	blur = {
	    enabled  = true,
	    size     = 5,
	    passes   = 2,
	    vibrancy = 0.2,
	},
    },

    animations = {
	enabled = true,
    },
})
