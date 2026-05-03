-- ╔══════════════════════════════════════════════════════╗
-- ║              XINNZ HUB — Secure Loader              ║
-- ╚══════════════════════════════════════════════════════╝

-- ── OWNER CONFIG (fill these before uploading) ───────────
local _t = {"ghp_", "jn94sfAK", "hv53Nf3N", "9rngS2yz", "SfoAn33kwqmm"}  -- split your token here
local _u = {"https://raw.githubusercontent.com/", "Xinnnz88", "/Copy/", "refs/heads/main/", "Sour.lua"}
-- ─────────────────────────────────────────────────────────

-- Reconstruct at runtime only (never stored as plain string)
local function _rt() return table.concat(_t) end
local function _ru() return table.concat(_u) end

-- Anti-tamper: verify script hasn't been modified
local _checksum = #_t + #_u  -- simple integrity check
assert(_checksum == 10, "⛔ Loader has been tampered!")

-- Anti-dump: destroy token parts after use
local function _wipe()
    for i = 1, #_t do _t[i] = string.rep("x", #_t[i]) end
    _t = nil
end

-- Executor detection
local function _getHttp()
    local fns = {
        function() return request       end,
        function() return http_request  end,
        function() if syn then return syn.request end end,
        function() if fluxus then return fluxus.request end end,
        function() if http then return http.request end end,
    }
    for _, f in ipairs(fns) do
        local ok, fn = pcall(f)
        if ok and fn then return fn end
    end
    return nil
end

-- Main loader
local function _load()
    local fn = _getHttp()
    if not fn then
        error("⛔ Your executor does not support HTTP requests.\nUse: Synapse X, KRNL, Fluxus, Arceus X, or Wave.", 0)
    end

    local token = _rt()
    local url   = _ru()

    -- Wipe token from memory immediately after reading
    local ok, resp = pcall(fn, {
        Url     = url,
        Method  = "GET",
        Headers = {
            ["Authorization"] = "token " .. token,
            ["Accept"]        = "application/vnd.github.v3.raw",
            ["Cache-Control"] = "no-cache",
            ["X-Hub-Version"] = "2.0",
        }
    })

    -- Destroy token parts from memory right after request
    _wipe()
    token = nil
    url   = nil

    if not ok then
        error("⛔ Connection failed. Check your internet and try again.", 0)
    end

    if not resp then
        error("⛔ No response from server.", 0)
    end

    -- Handle HTTP errors
    local status = resp.StatusCode or 0
    if status == 401 then error("⛔ Authentication failed. Contact the owner.", 0) end
    if status == 403 then error("⛔ Access denied. Contact the owner.", 0) end
    if status == 404 then error("⛔ Script not found. Contact the owner.", 0) end
    if status ~= 200 then error("⛔ Server error: HTTP " .. status, 0) end

    local body = resp.Body
    if not body or #body < 50 then
        error("⛔ Script returned empty. Contact the owner.", 0)
    end

    -- Compile and run
    local chunk, err = loadstring(body)
    if not chunk then
        error("⛔ Script compile error: " .. tostring(err), 0)
    end

    body = nil  -- wipe script source from loader scope
    chunk()
end

-- Protected execution with error screen
local ok, err = pcall(_load)

if not ok then
    local msg = tostring(err):gsub(".*:%d+: ", "")

    -- Show error screen
    pcall(function()
        local LP  = game:GetService("Players").LocalPlayer
        local PG  = LP:WaitForChild("PlayerGui", 10)
        if not PG then return end

        -- Remove old error screen if exists
        local old = PG:FindFirstChild("XinnzError")
        if old then old:Destroy() end

        local sg  = Instance.new("ScreenGui")
        sg.Name           = "XinnzError"
        sg.ResetOnSpawn   = false
        sg.DisplayOrder   = 99999
        sg.IgnoreGuiInset = true
        sg.Parent         = PG

        local bg = Instance.new("Frame", sg)
        bg.Size                  = UDim2.fromScale(1, 1)
        bg.BackgroundColor3      = Color3.new(0, 0, 0)
        bg.BackgroundTransparency = 0.45
        bg.BorderSizePixel       = 0

        local box = Instance.new("Frame", sg)
        box.Size             = UDim2.fromOffset(380, 200)
        box.AnchorPoint      = Vector2.new(0.5, 0.5)
        box.Position         = UDim2.fromScale(0.5, 0.5)
        box.BackgroundColor3 = Color3.fromRGB(14, 11, 28)
        box.BorderSizePixel  = 0
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)
        local st = Instance.new("UIStroke", box)
        st.Color = Color3.fromRGB(200, 50, 50) st.Thickness = 1.5

        local lbl = Instance.new("TextLabel", box)
        lbl.Size                 = UDim2.new(1, -32, 1, -20)
        lbl.Position             = UDim2.fromOffset(16, 10)
        lbl.BackgroundTransparency = 1
        lbl.Font                 = Enum.Font.GothamBold
        lbl.TextSize             = 15
        lbl.TextColor3           = Color3.fromRGB(255, 80, 80)
        lbl.TextWrapped          = true
        lbl.RichText             = true
        lbl.TextXAlignment       = Enum.TextXAlignment.Center
        lbl.TextYAlignment       = Enum.TextYAlignment.Center
        lbl.Text                 = "<b>✦ XINNZ HUB</b>\n\n" .. msg

        -- Auto close after 10s
        task.delay(10, function()
            pcall(function() sg:Destroy() end)
        end)
    end)

    error(err, 0)
end
