util.AddNetworkString("ReportSystem_ReportCreated")
util.AddNetworkString("ReportSystem_ReportClosed")



print("Report System Loaded")
print("Created by: Pat && YoWaitAMinute")
print("Version: 1.0")
print("Discord : RB69#2897 && YoWaitAMinute#6897")

function reports_send_admins(ply)
    for k, v in pairs(sam.ranks.get_ranks()) do
        if reports.config.nonadminranks[ply:GetUserGroup()] then
            return false
        end

        return true
    end
end

-- left your code here minute bc i wasnt bothered to try and fix it after taking my sleep meds
util.AddNetworkString("SendReport")
util.AddNetworkString("CreateReportPopUp")
util.AddNetworkString("ReportSystem_ReportCreated")
util.AddNetworkString("ReportSystem_ReportClosed")
util.AddNetworkString("ReportSystem_ViewReports")
util.AddNetworkString("ReportSystem_SyncReports")
util.AddNetworkString("patreport")
util.AddNetworkString("ClaimReport")


function gFValue(r)
    for k,v in pairs(ActiveReports) do
        if k == r then
            return v
        end
    end
end

net.Receive("ClaimReport", function(len, ply)
if not reports_send_admins(ply) then return end
local report = net.ReadInt(32)
local targ = gFValue(report).targ
local rply = gFValue(report).ply

rply:ChatPrint("Your report has been claimed by " .. ply:Nick())

rply.OldPos = rply:GetPos()
targ.OldPos = targ:GetPos()

rply:SetPos(ply:GetPos())
targ:SetPos(ply:GetPos())

ply.Sit = report
end)

function GetTableFromK(info)
    for k,v in pairs(ActiveReports) do
        if k == info then
            return v
        end
    end
end

hook.Add("PlayerDeath", "ReportDeath", function(ply)
    if ply.Sit then
        gFValue(ply.Sit).ply:SetPos(gFValue(ply.Sit).ply.OldPos)
        gFValue(ply.Sit).targ:SetPos(gFValue(ply.Sit).targ.OldPos)
        gFValue(ply.Sit).ply:ChatPrint("Your report has been closed!")
        ActiveReports[ply.Sit] = nil
        SendReportsTableToClient(ply)
        ply.Sit = nil
        SendReportsTableToClient(ply)
    end
end)

hook.Add("PlayerSay", "ReportChat", function(ply, text)
    if text == "/endsit" then
        if not reports_send_admins(ply) then return end
        if not ply.Sit then ply:ChatPrint("You Are Not In A Sit!") return end 
        gFValue(ply.Sit).ply:SetPos(gFValue(ply.Sit).ply.OldPos)
        gFValue(ply.Sit).targ:SetPos(gFValue(ply.Sit).targ.OldPos)
        gFValue(ply.Sit).ply:ChatPrint("Your report has been closed!")
        ActiveReports[ply.Sit] = nil
        SendReportsTableToClient(ply)
        ply.Sit = nil

    end
end)




function ReportNotifier(msg)
    for k, v in pairs(player.GetAll()) do
        v:ChatPrint(msg)
    end
end

ActiveReports = ActiveReports or {}
function SendReportsTableToClient(ply)
    net.Start("ReportSystem_SyncReports")
    net.WriteTable(ActiveReports)
    for k,v in pairs(player.GetAll()) do
        if not reports_send_admins(v) then return end
        if v:GetUserGroup() == "user" or v:GetUserGroup() == "vip" or v:GetUserGroup() == "Server Backer" then return end
        net.Send(v)
    end
end

ActiveReports = ActiveReports or {}

function ReportCreated(ply, reason, info, targ)
    table.insert(ActiveReports, {
        ply = ply,
        reason = reason,
        info = info,
        targ = targ,
        targnick = targ:Nick(),
        plynick = ply:Nick(),
    })

    SendReportsTableToClient(ply)
    for k,v in pairs(player.GetAll()) do
        if reports_send_admins(v) then
            v:ChatPrint(ply:Nick() .. " has reported " .. targ:Nick() .. " for " .. reason .. " with the description: " .. info)
        end 
    end
end

net.Receive("SendReport", function(len, ply)
    local reason = net.ReadString()
    local description = net.ReadString()
    local targ = net.ReadEntity()
    ReportCreated(ply, reason, description, targ)
end)

concommand.Add("patreport", function(ply, t)
    net.Start("patreport")
    net.Send(ply)
end)

hook.Add("PlayerSay", "reportcmd", function(ply, text)
    if text == "/report" then
        ply:ConCommand("patreport")
    end
end)

concommand.Add("testreport", function(ply, t)
    net.Start("CreateReportPopUp")
    net.Send(ply)
end)

hook.Add("PlayerSay", "testrepsortcmd", function(ply, text)
    if text == "/reports" then
        if not reports_send_admins(ply) then return end
        net.Start("ReportSystem_ViewReports")
        net.Send(ply)
    end
end)

concommand.Add("OpenReports", function(ply, t)
    net.Start("ReportSystem_ViewReports")
    net.Send(ply)
end)