---
-- All replicated convars are handled in this file

-- @realm shared
CreateConVar("ttt2_radar_charge_time", "30", CV_FLAGS_SHARED)

-- @realm shared
CreateConVar("ttt_spec_prop_control", "1", CV_FLAGS_SHARED)

---
-- @realm shared
CreateConVar(
    "ttt_bem_allow_change",
    1,
    CV_FLAGS_SHARED_SILENT,
    "Allow clients to change the look of the Traitor/Detective menu"
)

---
-- @realm shared
CreateConVar(
    "ttt_bem_sv_cols",
    4,
    CV_FLAGS_SHARED_SILENT,
    "Sets the number of columns in the Traitor/Detective menu's item list (serverside)"
)

---
-- @realm shared
CreateConVar(
    "ttt_bem_sv_rows",
    5,
    CV_FLAGS_SHARED_SILENT,
    "Sets the number of rows in the Traitor/Detective menu's item list (serverside)"
)

---
-- @realm shared
CreateConVar(
    "ttt_bem_sv_size",
    64,
    CV_FLAGS_SHARED_SILENT,
    "Sets the item size in the Traitor/Detective menu's item list (serverside)"
)
