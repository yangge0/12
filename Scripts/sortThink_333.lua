print("sortThink_333~~~~~~~~~~~~~~~~~")
local sortThink_333 = GameMain:GetMod("sortThink_333")

function sortThink_333:OnInit()
	local tbEventMod = GameMain:GetMod("_Event")
	tbEventMod:RegisterEvent(g_emEvent.WindowEvent, self.OnWindowEvent, self)
end

function sortThink_333:OnWindowEvent(pThing, pObjs)
    -- public delegate void EventHandler(Thing sender, object[] obs);
    -- 窗口事件 窗口对象,行为(1开启 2关闭

	local pWnd = pObjs[0]
    -- 窗口的事件类型
	local iArg = pObjs[1]
	if (pWnd == CS.Wnd_A2HCreateAgg.Instance and iArg == 1) then
        -- 保证打开了一个思绪窗口
        --捕获窗口时对所有 动物的思绪列表都排序了
		local listAllNpc = Map.Things:GetPlayerActiveNpcs(g_emNpcRaceType.Animal)

        -- local sortcount = 0

		for _, Npc in pairs(listAllNpc) do
			if(Npc.A2H ~= nil) then
                -- sortcount = sortcount + 1
                -- print("sortcount ", sortcount)
				if(Npc.A2H.thinkFrags ~= nil) then
					Npc.A2H.thinkFrags = sortThink_333:Sort(Npc.A2H.thinkFrags)
				end
				--记忆
				if(Npc.A2H.thinkFragCaches ~= nil) then
					Npc.A2H.thinkFragCaches = sortThink_333:Sort(Npc.A2H.thinkFragCaches)
				end
			end
		end
	end
end

function sortThink_333:Sort(list)
    local len = list.Count
    local thinkList = sortThink_333:GetThinkList()

    local indexMap = {} -- 哈希映射，存储键值对应的索引列表

    -- 建立哈希映射
    for i = 0, len - 1 do
        local fragName = tostring(list[i].frags[0])
        if not indexMap[fragName] then
            indexMap[fragName] = {} -- 初始化索引列表
        end
        table.insert(indexMap[fragName], i) -- 添加索引到列表中
    end

    -- 对索引进行排序
    local indices = {}
    for fragName, indexList in pairs(indexMap) do
        table.insert(indices, { fragName = fragName, indexList = indexList })
    end
    table.sort(indices, function(a, b)
        local xSize = thinkList:IndexOf(a.fragName)
        local ySize = thinkList:IndexOf(b.fragName)
        return xSize < ySize
    end)

    -- 根据排序后的索引创建新列表
    local sortedList = CS.System.Collections.Generic.List(CS.XiaWorld.HumanoidEvolutionMgr.ThinkFrag)()
    for _, entry in ipairs(indices) do
        for _, index in ipairs(entry.indexList) do
            sortedList:Add(list[index])
        end
    end

    return sortedList
end


function sortThink_333:GetThinkList()
    if sortThink_333.thinkList == nil then
        local hem = CS.XiaWorld.HumanoidEvolutionMgr.Instance.Fragments
        local initThink = CS.System.Collections.Generic.List(CS.System.String)()

        for localKey, localValue in pairs(hem.ForEachKey) do
            initThink:Add(tostring(localValue.Name))
        end

        sortThink_333.thinkList = initThink
        print("sortThink_333初始化成功")
    end

    return sortThink_333.thinkList
end
