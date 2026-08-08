-- [[ Mobile Script Runner (Rayfield UI) ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Script Runner",
    LoadingTitle = "Mobile Utility",
    LoadingSubtitle = "by Unk",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyScriptRunner",
        FileName = "Config"
    }
})

-- ตัวแปรระบบ
local currentScript = ""
local scriptNameInput = "MyScript"
local loopEnabled = false
local HttpService = game:GetService("HttpService")

-- ฟังก์ชันดึงข้อมูล (ไฟล์)
local function getSavedData()
    if isfile and isfile("SavedScripts.json") then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile("SavedScripts.json"))
        end)
        if success then return result end
    end
    return {}
end

-- ฟังก์ชันเซฟข้อมูล (ไฟล์)
local function saveData(data)
    if writefile then
        writefile("SavedScripts.json", HttpService:JSONEncode(data))
    end
end

-- ==================== TABS ====================
local MainTab = Window:CreateTab("หน้าหลัก", "code")
local SavedTab = Window:CreateTab("จัดการสคริปต์", "save")

-- 1. ช่องใส่สคริปต์
MainTab:CreateInput({
    Name = "1. ช่องใส่สคริปต์",
    PlaceholderText = "วางสคริปต์ของคุณที่นี่",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        currentScript = Text
    end,
})

-- 2. ปุ่ม Copy
MainTab:CreateButton({
    Name = "2. คัดลอกสคริปต์ (Copy)",
    Callback = function()
        if setclipboard then
            setclipboard(currentScript)
            Rayfield:Notify({Title = "สำเร็จ", Content = "คัดลอกลง Clipboard แล้ว", Duration = 3})
        end
    end,
})

-- 3. ปุ่ม รัน 1 รอบ
MainTab:CreateButton({
    Name = "3. รันสคริปต์ (Run Once)",
    Callback = function()
        local func, err = loadstring(currentScript)
        if func then func() else warn(err) end
    end,
})

-- 4. บันทึกสคริปต์
MainTab:CreateInput({
    Name = "ตั้งชื่อสคริปต์ (ก่อนบันทึก)",
    PlaceholderText = "ชื่อสคริปต์",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        scriptNameInput = Text
    end,
})

MainTab:CreateButton({
    Name = "4. บันทึกสคริปต์ (Save)",
    Callback = function()
        local data = getSavedData()
        data[scriptNameInput] = currentScript
        saveData(data)
        Rayfield:Notify({Title = "บันทึกสำเร็จ", Content = "บันทึกในชื่อ: " .. scriptNameInput, Duration = 3})
    end,
})

-- 6. Toggle รันรัวๆ
MainTab:CreateToggle({
    Name = "6. เปิด/ปิด รันสคริปต์รัวๆ",
    CurrentValue = false,
    Callback = function(Value)
        loopEnabled = Value
        if loopEnabled then
            task.spawn(function()
                while loopEnabled do
                    local func = loadstring(currentScript)
                    if func then func() end
                    task.wait(0.5) -- หน่วงเวลา 0.5 วินาที
                end
            end)
        end
    end,
})

-- 5. หน้าเปิดดูสคริปต์ (Saved Tab)
local Dropdown = SavedTab:CreateDropdown({
    Name = "5. เลือกสคริปต์ที่บันทึกไว้",
    Options = {},
    Callback = function(Option)
        local data = getSavedData()
        if data[Option] then
            currentScript = data[Option]
            Rayfield:Notify({Title = "โหลดสคริปต์", Content = "โหลด '" .. Option .. "' เข้าช่องหลักแล้ว", Duration = 3})
        end
    end,
})

SavedTab:CreateButton({
    Name = "รีเฟรชรายการ",
    Callback = function()
        local data = getSavedData()
        local keys = {}
        for k in pairs(data) do table.insert(keys, k) end
        Dropdown:Refresh(keys, true)
    end,
})

SavedTab:CreateButton({
    Name = "ลบสคริปต์ที่เลือก",
    Callback = function()
        -- ตรงนี้ใส่ตรรกะลบตามชื่อที่เลือกใน Dropdown
        Rayfield:Notify({Title = "แจ้งเตือน", Content = "กดลบแล้ว (ต้องเขียนโค้ดเพิ่มเพื่อลบรายรายการ)", Duration = 3})
    end,
})
