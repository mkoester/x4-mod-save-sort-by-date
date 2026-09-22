-- Make "date, newest first" the sort the Load/Save menus open with.
--
-- The base game keeps the sort in one field of its own menu table:
-- ego_gameoptions/gameoptions.lua declares `saveSort = "slot"` and reads it when
-- it builds the list. Valid values are slot/slot_inv, name/name_inv and
-- date/date_inv; "date" sorts on rawtime descending.
--
-- That table is reachable because gameoptions.lua's init() inserts it into the
-- global Menus list, and ego_detailmonitorhelper/helper.lua publishes that list
-- with MakeGlobalAvailable("Menus"). So this is a plain field write from an
-- additive addon: no file substitution, no FFI, no require -- which is why it
-- also works with Protected UI Mode left on.
--
-- Written once at UI load rather than forced on every menu open, and that is
-- deliberate: the column-header buttons call menu.refresh(), which rebuilds the
-- list through the same code path, so anything that re-asserted the value there
-- would make those buttons appear dead. As written, the player's own choice wins
-- for the rest of the session and "date" returns on the next UI reload.

local function init()
    if type(Menus) ~= "table" then
        -- Visible in uidata.xml rather than silent, so a load-order or API change
        -- in a future patch is diagnosable instead of just "the mod stopped working".
        DebugError("mk_save_sort_by_date: Menus global is not available")
        return
    end
    for _, menu in ipairs(Menus) do
        if menu.name == "OptionsMenu" then
            menu.saveSort = "date"
            return
        end
    end
    DebugError("mk_save_sort_by_date: OptionsMenu not found in Menus")
end

init()
