reports = reports or {}
reports.config = reports.config or {}

reportReasons = {
    "Hacking", 
    "Exploiting", 
    "Harassment", 
    "Other"
}

reports.config.nonadminranks = {"Server Backer", "Vip+", "Vip", "User", "Donator", "Donator+", "vip", "user", "donator", "donator+", "server backer", "vip+", "user", "donator", "donator+"}

reports.config.maxxreports = 3 -- max reprots per player


function player_get_reports(ply)
    if not IsValid(ply) then return 0 end
    if not ply:IsPlayer() then return 0 end
    return ply:GetPData("reports", 0)
end

function player_can_make_report(ply)
    if not IsValid(ply) then return false end
    if not ply:IsPlayer() then return false end
    if not ply:IsAdmin() then return false end
    if player_get_reports(ply) >= reports.config.maxxreports then return false end
    return true
end