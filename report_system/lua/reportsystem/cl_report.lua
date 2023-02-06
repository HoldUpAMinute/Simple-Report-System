surface.CreateFont("reportmenu1", {
    font = "Roboto Medium",
    size = 20,
    weight = 100,
})

PIXEL.RegisterFont("reportmenu13", "Roboto Medium", 20, 100)
PIXEL.RegisterFont("reportmenu12", "Roboto Medium", 20, 100)

function OpenReportMenu()
    local report_panel = vgui.Create("PIXEL.Frame")
    report_panel:SetSize(500, 350)
    report_panel:Center()
    report_panel:SetTitle("Report a player")
    report_panel:MakePopup()
    local player_input = vgui.Create("PIXEL.ComboBox", report_panel)
    player_input:SetValue("Player")
    player_input:SetPos(ScrW() * 0.005, ScrH() * 0.04)
    player_input:SetWide(ScrW() * 0.25)
    player_input:SetSizeToText(false)
    player_input:SetFont("reportmenu1")

    for k, ply in pairs(player.GetAll()) do
        player_input:AddChoice(ply:Nick())
    end

    local reason_dropdown = vgui.Create("PIXEL.ComboBox", report_panel)
    reason_dropdown:SetValue("Reason")
    reason_dropdown:SetPos(ScrW() * 0.005, ScrH() * 0.075)
    reason_dropdown:SetWide(ScrW() * 0.25)
    reason_dropdown:SetSizeToText(false)

    for i, reason in ipairs(reportReasons) do
        reason_dropdown:AddChoice(reason)
    end

    local description_entry = vgui.Create("PIXEL.TextEntry", report_panel)
    description_entry:SetPos(ScrW() * 0.005, ScrH() * 0.115)
    description_entry:SetValue("Description")
    description_entry:SetSize(480, 160)
    description_entry:SetMultiline(true)
    local submit_button = vgui.Create("PIXEL.TextButton", report_panel)
    submit_button:SetPos(ScrW() * 0.00, ScrH() * 0.2965)
    submit_button:SetWide(ScrW() * 0.265)
    submit_button:SetText("Submit Report")
    submit_button.HoverCol = Color(0, 255, 63, 255)

    submit_button.DoClick = function()
        local reason = reason_dropdown:GetSelected()
        local description = description_entry:GetValue()
        local playerreported = player_input:GetSelected()

        if playerreported == nil then
            LocalPlayer():ChatPrint("Please select a player.", "NOTIFY_GENERIC", 5)

            return
        end

        if reason == nil then
            LocalPlayer():ChatPrint("Please select a reason.", "NOTIFY_GENERIC", 5)

            return
        end

        if description == "Description" or string.find(description, "Description") or string.find(description, "Descriptio") or string.find(description, "Descripti") or string.find(description, "Descript") or string.find(description, "Descript") or string.find(description, "Descrip") or string.find(description, "Descri") or string.find(description, "Descr") or string.find(description, "Des") then
            LocalPlayer():ChatPrint("Please enter a description.", "NOTIFY_GENERIC", 5)

            return
        end

        net.Start("SendReport")
        net.WriteString(reason)
        net.WriteString(description)

        for k, v in pairs(player.GetAll()) do
            if v:Nick() == playerreported then
                net.WriteEntity(v)
            end
        end

        net.WriteString(playerreported)
        net.SendToServer()
        report_panel:Close()
    end
end

concommand.Add("patreport", function(ply, cmd, args)
    OpenReportMenu()
end)

ActiveReports = ActiveReports or {}

net.Receive("ReportSystem_SyncReports", function()
    ActiveReports = net.ReadTable()
end)

net.Receive("CreateReportPopUp", function()
    if IsValid(report_panel) then
        report_panel:Remove()

        return
    end

    for k, v in pairs(ActiveReports) do
        if IsValid(report_panel) then
            report_panel:Remove()
        end

        report_panel = vgui.Create("DFrame")
        -- report_panel.CloseButton = false
        report_panel:SetSize(ScrW() * 1, ScrH() * 0.02)
        report_panel:SetPos(ScrW() * 0.0, ScrH() * 0.0)
        report_panel:ShowCloseButton(false)
        report_panel:SetTitle("")

        report_panel.Paint = function(self, w, h)
            PIXEL.DrawRoundedBox(0, 0, 0, w, h, Color(22, 22, 22))
            PIXEL.DrawSimpleText("Do /reports to check if there are any reports!", "reportmenu13", w * 0.4, h * 0.5, Color(255, 255, 255), nil, TEXT_ALIGN_CENTER)
        end
    end
end)

net.Receive("ReportSystem_ViewReports", function()
    if IsValid(reports_panel) then
        reports_panel:Remove()
    end

    local self = LocalPlayer()
    local reports_panel = vgui.Create("PIXEL.Frame")
    reports_panel:SetSize(ScrW() * 0.5, ScrH() * 0.5)
    reports_panel:Center()
    reports_panel:SetTitle("Reports")
    reports_panel:MakePopup()
    self.reports_scroll = vgui.Create("PIXEL.ScrollPanel", reports_panel)
    self.reports_scroll:Dock(FILL)

    for k, v in pairs(ActiveReports) do
        local reports_list = self.reports_scroll:Add("PIXEL.Frame")
        reports_list:SetSize(ScrW() * 0.495, ScrH() * 0.1)
        reports_list:SetTitle("")

        reports_list.Paint = function(self, w, h)
            PIXEL.DrawRoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
            PIXEL.DrawSimpleText(v.plynick .. " Reported " .. v.targnick .. " For " .. v.reason, "reportmenu13", w * 0.3, h * 0.5, Color(255, 255, 255), nil, TEXT_ALIGN_CENTER)
        end

        local claim_button = vgui.Create("PIXEL.TextButton", reports_list)
        claim_button:Dock(BOTTOM)
        claim_button:SetText("Claim")
        claim_button.HoverCol = Color(0, 255, 63, 255)

        claim_button.DoClick = function()
            net.Start("ClaimReport")
            net.WriteInt(k, 32)
            net.SendToServer()
            reports_panel:Close()
        end
    end
end)