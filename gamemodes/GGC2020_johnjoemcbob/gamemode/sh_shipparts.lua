--
-- GGC2020_johnjoemcbob
-- 12/06/20
--
-- Shared Ship Parts Table
--

-- Convert from 1 to 3 = models/cerus/modbridge/core/spartan/cv-11-31.mdl
local CORRWIDTH = 8
SHIPENDCAP = "models/cerus/modbridge/plate/flat/s11.mdl"
SHIPPARTS = {
	["x-111"] = {
		"models/cerus/modbridge/core/x-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			AddRotatableSegment( x, y, 2, 1, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 3, w, h, self.Rotation )
			AddRotatableSegment( x, y, 1, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 3, 2, w, h, self.Rotation )
		end,
		AttachPoints = {
			{ Vector( 1, 0 ), 90 },
			{ Vector( -1, 0 ), 90 },
			{ Vector( 0, 1 ), 0 },
			{ Vector( 0, -1 ), 0 },
		},
	},
	["c-111"] = {
		"models/cerus/modbridge/core/c-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			AddRotatableSegment( x, y, 1, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 3, w, h, self.Rotation )
		end,
		AttachPoints = {
			{ Vector( -1, 0 ), 90 },
			{ Vector( 0, 1 ), 0 },
		},
	},
	["s-111"] = {
		"models/cerus/modbridge/core/s-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			AddRotatableSegment( x, y, 1, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 3, 2, w, h, self.Rotation )
		end,
		AttachPoints = {
			{ Vector( 1, 0 ), 90 },
			{ Vector( -1, 0 ), 90 },
		},
	},
	["t-111"] = {
		"models/cerus/modbridge/core/t-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			AddRotatableSegment( x, y, 1, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 3, w, h, self.Rotation )
			AddRotatableSegment( x, y, 3, 2, w, h, self.Rotation )
		end,
		AttachPoints = {
			{ Vector( 1, 0 ), 90 },
			{ Vector( -1, 0 ), 90 },
			{ Vector( 0, 1 ), 0 },
		},
	},
	["sc-111"] = {
		"models/cerus/modbridge/core/sc-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			AddRotatableSegment( x, y, 3, 2, w, h, self.Rotation )
		end,
		AttachPoints = {
			{ Vector( 1, 0 ), 90 },
		},
	},
	["sc-g-111"] = {
		"models/cerus/modbridge/core/sc-111g.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			AddRotatableSegment( x, y, 3, 2, w, h, self.Rotation )
			surface.SetDrawColor( COLOUR_GLASS )
			AddRotatableSegment( x, y, 2, 2, w, h, self.Rotation )
		end,
		AttachPoints = {
			{ Vector( 1, 0 ), 90 },
		},
	},
	["s-311"] = {
		"models/cerus/modbridge/core/s-311.mdl",
		Vector( 3, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			local segs = 3
			for segx = 1, segs do
				AddRotatableSegment( x, y, 1, 2, w, h, self.Rotation, segx )
				AddRotatableSegment( x, y, 2, 2, w, h, self.Rotation, segx )
				AddRotatableSegment( x, y, 3, 2, w, h, self.Rotation, segx )
			end
		end,
		AttachPoints = {
			{ Vector( 4, 0 ), 90 },
			{ Vector( -1, 0 ), 90 },
		},
	},
	["x-221"] = {
		"models/cerus/modbridge/core/x-221.mdl",
		Vector( 2, 2, 1 ),
		Vector( -0.5, 0.5, 0 ),
		function( self, x, y, w, h )
			for segx = 1, 2 do
				for segy = 1, 2 do
					for cx = 1, 3 do
						for cy = 1, 3 do
							AddRotatableSegment( x, y, cx, cy, w / 2, h / 2, self.Rotation, segx, segy )
						end
					end
				end
			end
		end,
		AttachPoints = {
			{ Vector( 1, 0 ), 90, Vector( 3, 0 ), },
			{ Vector( 1, 1 ), 90, Vector( 3, 2 ), },
			{ Vector( -1, 0 ), 90 },
			{ Vector( -1, 1 ), 90, Vector( -1, 2 ), },
			{ Vector( 0, 1 ), 0, Vector( 0, 3 ), },
			{ Vector( 1, 1 ), 0, Vector( 2, 3 ), },
			{ Vector( 0, -1 ), 0 },
			{ Vector( 1, -1 ), 0, Vector( 2, -1 ), },
		},
	},
}
