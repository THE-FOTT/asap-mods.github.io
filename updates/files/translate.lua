local lanes = require('lanes').configure()
local imgui = require 'mimgui'
local encoding = require "encoding"
local ffi = require 'ffi'
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local renderWindow = new.bool()
encoding.default = 'CP1251'
u8 = encoding.UTF8
local menu_items = { 'Fasttranslator', 'Lingvolive' } 
script_version '6'
local dlstatus = require "moonloader".download_status

local itemsList = {u8"Синяя", u8"Красная", u8'Оранжевая', u8'Зеленая', u8'Серая', u8"Арсений Плов", u8'Бабская'}
local current = new.int(0)
local items = new['const char*'][#itemsList](itemsList)
local buffer_text = new.char[256](u8('Привет'))
local buffer_lang = new.char[256]('ru-en')

local sizeX, sizeY = getScreenResolution()
count = 0

imgui.OnInitialize(function()
end)


local selected_label = new.int(1)
local selector_pos = new.int(0)
local menu = {
    u8'Fasttranslator',
    u8'Lingvolive',
    u8'Config',
}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--// Ассинхронный запрос
function sequent_async_http_request(method, url, args, resolve, reject)
    if not _G['lanes.async_http'] then
        local linda = lanes.linda()
        local lane_gen = lanes.gen('*', {package = {path = package.path, cpath = package.cpath}}, function()
            local requests = require 'requests'
            while true do
                local key, val = linda:receive(50 / 1000, 'request')
                if key == 'request' then
                    local ok, result = pcall(requests.request, val.method, val.url, val.args)
                    if ok then
                        result.json, result.xml = nil, nil
                        linda:send('response', result)
                    else
                        linda:send('error', result)
                    end
                end
            end
        end)
        _G['lanes.async_http'] = {lane = lane_gen(), linda = linda}
    end
    local lanes_http = _G['lanes.async_http']
    lanes_http.linda:send('request', {method = method, url = url, args = args})
    lua_thread.create(function(linda)
        while true do
            local key, val = linda:receive(0, 'response', 'error')
            if key == 'response' then
                return resolve(val)
            elseif key == 'error' then
                return reject(val)
            end
            wait(0)
        end
    end, lanes_http.linda)
end --// Ассинхронный запрос

local function urlencode(url)
  if url == nil then
    return
  end
  url = url:gsub("\n", "\r\n")
  url = url:gsub(" ", "+")
  return url
end


--/Функа перевода
function translate(text, lang)
    if text ~= nil and lang ~= nil then -- проверям аргументы на пустоту
        text = u8(urlencode(text)) -- Кодируем параметр в URL формат, а так же юзаем u8 дабы передавать русский текст, эта хуяка крашила при вызове с либы, схуяли
        sequent_async_http_request('GET', 'https://fasttranslator.herokuapp.com/api/v1/text/to/text', {params = {source = text, lang = lang}}, -- отправляем GET запрос, работает многопоточно аче
        function(response) -- вызовется при  получении ответа
            if response.status:find('HTTP/1.1 200 OK') then --костыль, зато скрипт не крашнет, если все норм то
                result = decodeJson(response.text) -- декодируем джсон в таблицу
                result = u8:decode(result.data) -- вытягиваем то что нам надо и декодируем его в буковки, а не каракули
            elseif response.status:find('HTTP/1.1 429 Too Many Requests') then -- если сайт сказал что на этот чат с запросами все
                result = 'Ошибка, слишком много запросов' -- пишем в переменную что до связи, приходите через час
            else -- если какая то другая ошибка 
                result = 'Ошибка' -- просто пишем ошибка
            end
        end,
        function(err) -- вызовется при ошибке, err - текст ошибки. эта функция нахуй не надо не мне не вам, но зато есть обработчик ошибки хули!
            print(err) -- вывод ошибки да
        end)
    end
end--/Функа перевода


local narko = new.bool()
function main()
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand('tra', function(arg)
        renderWindow[0] = not renderWindow[0]
    end)
    while true do
        wait(0)
        if narko[0] then 
            r, g, b, a = rainbow(1, 255, 1 / 50)
        end
    end
end



local newFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin("Fott translator", renderWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize ) 
        imgui.Selector(menu, imgui.ImVec2(130, 40), selected_label, selector_pos, 10)
        imgui.SetCursorPos(imgui.ImVec2(150, 40))
        imgui.BeginChild('main', imgui.ImVec2(410, 120), false)
        if selected_label[0] == 1 then
        imgui.PushItemWidth(200)
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.0, 1.0, 2.06, 0.24))
        imgui.InputText(u8"##1", buffer_text, sizeof(buffer_text))
        imgui.PopStyleColor()
        imgui.SameLine()
        imgui.PushItemWidth(186)
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.48, 0.16, 0.16, 0.54))
        imgui.InputText(u8"##2", buffer_lang, sizeof(buffer_lang))
        imgui.PopStyleColor()
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.0, 1.0, 2.06, 0.24))
        if imgui.Button(u8'Первевести') then
            if buffer_text and buffer_lang then
                result = 'Обработка запроса'
                resultText = true
                translate(u8:decode(str(buffer_text)), str(buffer_lang))
                count = count + 1
            end
        end
        imgui.PopStyleColor()
        imgui.SameLine()
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.0, 1.0, 2.06, 0.24))
        if imgui.Button(u8'Скопировать') then
            if result then
                setClipboardText(result)
                print(result)
                sampAddChatMessage('Скопировано', -1)
            else
                sampAddChatMessage('Результат пустой!', -1)
            end
        end
        imgui.PopStyleColor()
        imgui.SameLine()
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.0, 1.0, 2.06, 0.24))
        if imgui.Button(u8'Очистить строку##1') then
            buffer_text = new.char[256]('')
        end
        imgui.PopStyleColor()
        imgui.SameLine()
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.48, 0.16, 0.16, 0.54))
        if imgui.Button(u8('Очистить строку##2')) then
            buffer_lang = new.char[256]('')
        end
        imgui.PopStyleColor()
        if resultText then
            if result ~= nil then
                if result:len() >= 100 then
                    m1, m2 = result:sub(1, #result/2), result:sub(#result/2, #result)
                    imgui.Text(u8'Результат перевода:\n '..u8(m1)..'- \n-'..u8(m2))
                else
                    imgui.Text(u8'Результат перевода:\n '..u8(result))
                end
            end
        end
        imgui.Text('Count: '..count)
        end
        if selected_label[0] == 2 then
            imgui.Text(u8'В разработке')
        end
        if selected_label[0] == 3 then
            imgui.Combo(u8"Тема", current, items, #itemsList)
            imgui.Checkbox('RGB', narko)
            if imgui.Button(u8'Проверить обнову') then
                lua_thread.create(function()
                    autoupdate("https://asapmods.github.io/updates/check_updates/translate", '['..string.upper(thisScript().name)..']: ', "vk.com/asapmods")
                end)
            end
            if imgui.Button(u8'Список изменений') then
                sampShowDialog(12345, 'Log', '{ff66ff}v5 {ffffff}- Тех. обновление.\n{ff66ff}v6 {ffffff}- Добавление списка изменений', 'Ладно', 'Я лох', 0)
            end
        end
        imgui.EndChild()
        apply_custom_style()
        imgui.End()
    end
)



function imgui.Selector(labels, size, selected, pos, speed)
    local rBool = false
    if not speed then speed = 10 end
    if (pos[0] < (selected[0] * size.y)) then
        pos[0] = pos[0] + speed
    elseif (pos[0] > (selected[0] * size.y)) then
        pos[0] = pos[0] - speed
    end
    imgui.SetCursorPos(imgui.ImVec2(0.00, pos[0]))
    local draw_list = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    local radius = size.y * 0.50
    if narko[0] then draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/2, p.y), imgui.ImVec2(p.x + radius + 1 * (size.x - radius * 2.0), p.y + radius*2), join_argb(a, r, g, b)) else draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/2, p.y), imgui.ImVec2(p.x + radius + 1 * (size.x - radius * 2.0), p.y + radius*2), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ButtonActive])) end
    if narko[0] then draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/2, p.y), imgui.ImVec2(p.x + 5, p.y + size.y), join_argb(a, r, g, b), 0) else draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/2, p.y), imgui.ImVec2(p.x + 5, p.y + size.y), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Button]), 0) end
    if narko[0] then draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + 1 * (size.x - radius * 2.0), p.y + radius), radius, join_argb(a, r, g, b), radius/10*12) else draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + 1 * (size.x - radius * 2.0), p.y + radius), radius, imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ButtonActive]), radius/10*12) end
    for i = 1, #labels do
        imgui.SetCursorPos(imgui.ImVec2(0, (i * size.y)))
        local p = imgui.GetCursorScreenPos()
        if imgui.InvisibleButton(labels[i], size) then selected[0] = i rBool = true end
        if imgui.IsItemHovered() then
            if narko[0] then draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/2, p.y), imgui.ImVec2(p.x + size.x, p.y + size.y), join_argb(a+50, r, g, b), radius/10*12) else draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/2, p.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Button]), radius/10*12) end
        end
        imgui.SetCursorPos(imgui.ImVec2(20, (i * size.y + (size.y-imgui.CalcTextSize(labels[i]).y)/2)))
        imgui.Text(labels[i])
    end
    return rBool
end

function join_argb(a, r, g, b) -- by FYP
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function rainbow(speed, alpha, offset) -- by rraggerr
    local clock = os.clock() + offset
    local r = math.floor(math.sin(clock * speed) * 127 + 128)
    local g = math.floor(math.sin(clock * speed + 2) * 127 + 128)
    local b = math.floor(math.sin(clock * speed + 4) * 127 + 128)
    return r,g,b,alpha
end

----------
function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((prefix..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')
                      sampAddChatMessage((prefix..'Обновление завершено!'), color)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              sampAddChatMessage('v'..thisScript().version..': Обновление не требуется.', -1)
            end
          end
        else
          sampAddChatMessage('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url, -1)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end




--//стили епта хули, модно
function apply_custom_style()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    if u8:decode(itemsList[current[0] + 1]) == 'Синяя' then
        colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
        colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
        colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
        colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
        colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
        colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
        colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
        colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
        colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
        colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
        colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
        --  colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        --colors[clr.ComboBg]                = colors[clr.PopupBg]
        colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        -- colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
        -- colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
        -- colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        -- colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
    elseif u8:decode(itemsList[current[0] + 1]) == 'Красная' then
        colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
        colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
        colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
        colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
        colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
        colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
        colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
        colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
        colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
        colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
        colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
        colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
        --colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        --colors[clr.ComboBg]                = colors[clr.PopupBg]
        colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        --colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
        --colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
        --colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        --colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
    elseif u8:decode(itemsList[current[0] + 1]) == 'Оранжевая' then
        colors[clr.FrameBg]                = ImVec4(0.48, 0.23, 0.16, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.43, 0.26, 0.40)
        colors[clr.FrameBgActive]          = ImVec4(0.98, 0.43, 0.26, 0.67)
        colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.48, 0.23, 0.16, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.CheckMark]              = ImVec4(0.98, 0.43, 0.26, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.88, 0.39, 0.24, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.43, 0.26, 1.00)
        colors[clr.Button]                 = ImVec4(0.98, 0.43, 0.26, 0.40)
        colors[clr.ButtonHovered]          = ImVec4(0.98, 0.43, 0.26, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.98, 0.28, 0.06, 1.00)
        colors[clr.Header]                 = ImVec4(0.98, 0.43, 0.26, 0.31)
        colors[clr.HeaderHovered]          = ImVec4(0.98, 0.43, 0.26, 0.80)
        colors[clr.HeaderActive]           = ImVec4(0.98, 0.43, 0.26, 1.00)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.25, 0.10, 0.78)
        colors[clr.SeparatorActive]        = ImVec4(0.75, 0.25, 0.10, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.98, 0.43, 0.26, 0.25)
        colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.43, 0.26, 0.67)
        colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.43, 0.26, 0.95)
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.50, 0.35, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.43, 0.26, 0.35)
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
        --colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        --colors[clr.ComboBg]                = colors[clr.PopupBg]
        colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        --colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
        --colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
        --colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
       -- colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
    elseif u8:decode(itemsList[current[0] + 1]) == 'Зеленая' then  
        colors[clr.FrameBg]                = ImVec4(0.16, 0.48, 0.42, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.98, 0.85, 0.40)
        colors[clr.FrameBgActive]          = ImVec4(0.26, 0.98, 0.85, 0.67)
        colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.40)
        colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 1.00)
        colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
        colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
        colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]       = ImVec4(0.10, 0.75, 0.63, 0.78)
        colors[clr.SeparatorActive]        = ImVec4(0.10, 0.75, 0.63, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.26, 0.98, 0.85, 0.25)
        colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.85, 0.67)
        colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.85, 0.95)
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.85, 0.35)
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
       -- colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
       -- colors[clr.ComboBg]                = colors[clr.PopupBg]
        colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
       -- colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
        --colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
        --colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
      --  colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
    elseif u8:decode(itemsList[current[0] + 1]) == 'Серая' then 
        colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
        colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
        --colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
        colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
        colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
        colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        --colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
        colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
       -- colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
        --colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
        --colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
        colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
        --colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
    elseif u8:decode(itemsList[current[0] + 1]) == 'Арсений Плов' then 
        colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 0.78)
        colors[clr.TextDisabled]         = ImVec4(0.36, 0.42, 0.47, 1.00)
        colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
        --colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
        colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.FrameBg]              = ImVec4(0.25, 0.29, 0.20, 1.00)
        colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
        colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
        colors[clr.TitleBg]              = ImVec4(0.09, 0.12, 0.14, 0.65)
        colors[clr.TitleBgActive]        = ImVec4(0.35, 0.58, 0.06, 1.00)
        colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
        colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
        colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
        colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
        colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
        --colors[clr.ComboBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
        colors[clr.CheckMark]            = ImVec4(0.72, 1.00, 0.28, 1.00)
        colors[clr.SliderGrab]           = ImVec4(0.43, 0.57, 0.05, 1.00)
        colors[clr.SliderGrabActive]     = ImVec4(0.55, 0.67, 0.15, 1.00)
        colors[clr.Button]               = ImVec4(0.40, 0.57, 0.01, 1.00)
        colors[clr.ButtonHovered]        = ImVec4(0.45, 0.69, 0.07, 1.00)
        colors[clr.ButtonActive]         = ImVec4(0.27, 0.50, 0.00, 1.00)
        colors[clr.Header]               = ImVec4(0.20, 0.25, 0.29, 0.55)
        colors[clr.HeaderHovered]        = ImVec4(0.72, 0.98, 0.26, 0.80)
        colors[clr.HeaderActive]         = ImVec4(0.74, 0.98, 0.26, 1.00)
        colors[clr.Separator]            = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[clr.SeparatorHovered]     = ImVec4(0.60, 0.60, 0.70, 1.00)
        colors[clr.SeparatorActive]      = ImVec4(0.70, 0.70, 0.90, 1.00)
        colors[clr.ResizeGrip]           = ImVec4(0.68, 0.98, 0.26, 0.25)
        colors[clr.ResizeGripHovered]    = ImVec4(0.72, 0.98, 0.26, 0.67)
        colors[clr.ResizeGripActive]     = ImVec4(0.06, 0.05, 0.07, 1.00)
        -- colors[clr.CloseButton]          = ImVec4(0.40, 0.39, 0.38, 0.16)
        -- colors[clr.CloseButtonHovered]   = ImVec4(0.40, 0.39, 0.38, 0.39)
        --colors[clr.CloseButtonActive]    = ImVec4(0.40, 0.39, 0.38, 1.00)
        colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
        colors[clr.TextSelectedBg]       = ImVec4(0.25, 1.00, 0.00, 0.43)
        -- colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
    elseif u8:decode(itemsList[current[0] + 1]) == 'Бабская' then 
        colors[clr.Text]                 = ImVec4(0.00, 0.00, 0.00, 1.00)
        colors[clr.TextDisabled]         = ImVec4(0.22, 0.22, 0.22, 1.00)
        colors[clr.WindowBg]             = ImVec4(1.00, 1.00, 1.00, 0.71)
        --colors[clr.ChildWindowBg]        = ImVec4(0.92, 0.92, 0.92, 0.00)
        colors[clr.PopupBg]              = ImVec4(1.00, 1.00, 1.00, 0.94)
        colors[clr.Border]               = ImVec4(1.00, 1.00, 1.00, 0.50)
        colors[clr.BorderShadow]         = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[clr.FrameBg]              = ImVec4(0.77, 0.49, 0.66, 0.54)
        colors[clr.FrameBgHovered]       = ImVec4(1.00, 1.00, 1.00, 0.40)
        colors[clr.FrameBgActive]        = ImVec4(1.00, 1.00, 1.00, 0.67)
        colors[clr.TitleBg]              = ImVec4(0.76, 0.51, 0.66, 0.71)
        colors[clr.TitleBgActive]        = ImVec4(0.97, 0.74, 0.88, 0.74)
        colors[clr.TitleBgCollapsed]     = ImVec4(1.00, 1.00, 1.00, 0.67)
        colors[clr.MenuBarBg]            = ImVec4(1.00, 1.00, 1.00, 0.54)
        colors[clr.ScrollbarBg]          = ImVec4(0.81, 0.81, 0.81, 0.54)
        colors[clr.ScrollbarGrab]        = ImVec4(0.78, 0.28, 0.58, 0.13)
        colors[clr.ScrollbarGrabHovered] = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
        --colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
        colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.SliderGrab]           = ImVec4(0.71, 0.39, 0.39, 1.00)
        colors[clr.SliderGrabActive]     = ImVec4(0.76, 0.51, 0.66, 0.46)
        colors[clr.Button]               = ImVec4(0.78, 0.28, 0.58, 0.54)
        colors[clr.ButtonHovered]        = ImVec4(0.77, 0.52, 0.67, 0.54)
        colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.50)
        colors[clr.Header]               = ImVec4(0.78, 0.28, 0.58, 0.54)
        colors[clr.HeaderHovered]        = ImVec4(0.78, 0.28, 0.58, 0.25)
        colors[clr.HeaderActive]         = ImVec4(0.79, 0.04, 0.48, 0.63)
        colors[clr.Separator]            = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[clr.SeparatorHovered]     = ImVec4(0.79, 0.44, 0.65, 0.64)
        colors[clr.SeparatorActive]      = ImVec4(0.79, 0.17, 0.54, 0.77)
        colors[clr.ResizeGrip]           = ImVec4(0.87, 0.36, 0.66, 0.54)
        colors[clr.ResizeGripHovered]    = ImVec4(0.76, 0.51, 0.66, 0.46)
        colors[clr.ResizeGripActive]     = ImVec4(0.76, 0.51, 0.66, 0.46)
        --colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
        --colors[clr.CloseButtonHovered]   = ImVec4(0.76, 0.46, 0.64, 0.71)
        --colors[clr.CloseButtonActive]    = ImVec4(0.78, 0.28, 0.58, 0.79)
        colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]     = ImVec4(0.92, 0.92, 0.92, 1.00)
        colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
        colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
        --colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
    end
end