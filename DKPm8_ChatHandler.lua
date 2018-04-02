DKPm8_DkpTable = nil;
DKPm8_ZoneTables = nil;
DKPm8_ChatHandler = {};
DKPm8_ChatHandler.ChatResponseStorageTable = {};
DKPm8_ChatHandler.AnnouncementsStorageTable = {};
DKPm8_ChatHandler.BidResponseStorageTable = {};
DKPm8_ChatHandler.BroadCastStorageTable = {};

SlashCmdList['DKPm8_SLASHCMD'] = function(msg)
     DKPm8_ChatHandler:SlashCMDHandler(msg)
end;
SLASH_DKPm8_SLASHCMD1 = "/dkp";

DKPm8_CurrentItem = {};
DKPm8_BidIsActive = false;
DKPm8_CurrentHighestBid = 0;
DKPm8_InitialBidDuration = 20;
DKPm8_InitialBidDurationExtention = 15;
DKPm8_TimeBidExpires = 0;
DKPm8_ObserveBid = true;
DKPm8_WarningDoneAt3s = false;
DKPm8_WarningDoneAt2s = false;
DKPm8_WarningDoneAt1s = false;

DKPm8_Option_WhisperResponse = true;
DKPm8_Option_BWCBAnnounce = true;
DKPm8_Option_SecondsAnnounce = true;

function DKPm8_ChatHandler:SlashCMDHandler(msg)
	if (msg) then
		cmd = string.lower(msg);
		if (string.starts (msg, "scale")) then
			-- Adjust the GUI scaling --
			local TryScale = tonumber(string.sub(msg, string.len("scale") + 1));
			if (TryScale ~= nil) then
				if TryScale < 0.5 then
					TryScale = 0.5;
				elseif (TryScale > 2) then
					TryScale = 2;
				end;
				DKPm8_Option_GUIScale = TryScale;
			else
				DEFAULT_CHAT_FRAME:AddMessage(string.sub(msg, string.len("scale") + 1).." is not a valid scale value!");
			end;
			DKPm8:SetScale(DKPm8_Option_GUIScale);
			DKPm8:ClearAllPoints();
			DKPm8:SetPoint("CENTER",UIParent,0,0);
			DKPm8:SetUserPlaced(true);
		elseif (string.starts(cmd, "whisper")) then
			-- whisper for failed bids etc. --
			if (cmd == "whisper on") then
				DKPm8_Option_WhisperResponse = true;
				DEFAULT_CHAT_FRAME:AddMessage("Whisper response turned on!");
			elseif (cmd == "whisper off") then
				DKPm8_Option_WhisperResponse = false;
				DEFAULT_CHAT_FRAME:AddMessage("Whisper response turned off!");
			else
				DEFAULT_CHAT_FRAME:AddMessage("'on' or 'off' for switching whispers on/off");
			end;
		elseif (string.starts(cmd, "bwcb")) then
			if (cmd == "bwcb on") then
				DKPm8_Option_BWCBAnnounce = true;
				DEFAULT_CHAT_FRAME:AddMessage("Big Wigs countdown on!");
			elseif (cmd == "bwcb off") then
				DKPm8_Option_BWCBAnnounce = false;
				DEFAULT_CHAT_FRAME:AddMessage("Big Wigs countdown off!");
			else
				DEFAULT_CHAT_FRAME:AddMessage("'on' or 'off' for switching Big Wigs Countdown on/off");
			end;
		elseif (string.starts(cmd, "3sec")) then
			if (cmd == "3sec on") then
				DKPm8_Option_SecondsAnnounce = true;
				DEFAULT_CHAT_FRAME:AddMessage("3sec countdown on!");
			elseif (cmd == "3sec off") then
				DKPm8_Option_SecondsAnnounce = false;
				DEFAULT_CHAT_FRAME:AddMessage("3sec countdown off!");
			else
				DEFAULT_CHAT_FRAME:AddMessage("'on' or 'off' for switching 3sec Countdown on/off");
			end;
		elseif (string.starts(cmd, "start")) then
			local lootmethod, IsMaster = GetLootMethod();
			if UnitInRaid("player") then
				if ((lootmethod == "master") and (IsMaster ~= nil)) or IsRaidLeader() or IsRaidOfficer() then
					BroadCastCurrentDKP();
					DKPm8_CurrentItem = string.sub(cmd, string.len("start") + 1);
					DKPm8_CurrentHighestBid = 0;
					DKPm8_ObserveBid = false;
					DKPm8_BidIsActive = true;
					DKPm8_DKPm8_CurrentItem:SetText(DKPm8_CurrentItem);
					DKPBidBar_Clear();
					DKPBidBar_Update();
					DKPm8:Show();
					DKPm8_TimeBidExpires = GetTime() + DKPm8_InitialBidDuration;
					if (DKPm8_Option_BWCBAnnounce) then
						BWCB(DKPm8_InitialBidDuration, DKPm8_CurrentItem);
					end
					DKPm8_WarningDoneAt3s = false;
					DKPm8_WarningDoneAt2s = false;
					DKPm8_WarningDoneAt1s = false;
					SendChatMessage("-NewBid ".. DKPm8_CurrentItem, "RAID_WARNING", nil, nil);
				else
					message("You are not the Lootmaster nor Raidlead/officer!");
					PlaySound("igQuestFailed", "master");				
				end;
			else
				message("You are in no Raid!");
				PlaySound("igQuestFailed", "master");
			end;
		else
			DEFAULT_CHAT_FRAME:AddMessage("No valid command!");
			DEFAULT_CHAT_FRAME:AddMessage("/dkp start <ItemName> to start a bid! (only if Lootmaster or Raidofficer/Raidlead)");
			DEFAULT_CHAT_FRAME:AddMessage("/dkp scale <scale> to resize the GUI");
			local DKPm8_Option_WhisperResponsetext, DKPm8_Option_BWCBAnnouncetext, DKPm8_Option_SecondsAnnouncetext;
			if(DKPm8_Option_WhisperResponse) then
				DKPm8_Option_WhisperResponsetext = "on";
			else
				DKPm8_Option_WhisperResponsetext = "off";
			end;
			DEFAULT_CHAT_FRAME:AddMessage("/dkp whisper [on/off] "..DKPm8_Option_WhisperResponsetext);
			if(DKPm8_Option_BWCBAnnounce) then
				DKPm8_Option_BWCBAnnouncetext = "on";
			else
				DKPm8_Option_BWCBAnnouncetext = "off";
			end;
			DEFAULT_CHAT_FRAME:AddMessage("/dkp bwcb [on/off] "..DKPm8_Option_BWCBAnnouncetext);
			if(DKPm8_Option_SecondsAnnounce) then
				DKPm8_Option_SecondsAnnouncetext = "on";
			else
				DKPm8_Option_SecondsAnnouncetext = "off";
			end;
			DEFAULT_CHAT_FRAME:AddMessage("/dkp 3sec [on/off] "..DKPm8_Option_SecondsAnnouncetext);	
		end;
	end;
end;

function BroadCastCurrentDKP()
	if(DKPm8_DkpTable == nil) then
		if (not GetDKPTables()) then
			return 0;
		else
			for RaidName, RaidId in pairs(DKPm8_ZoneTables) do
				table.insert(DKPm8_ChatHandler.BroadCastStorageTable, {"DKPm8_UpdateTables", RaidName.."="..RaidId.id});
				for i=1, GetNumRaidMembers() do
					table.insert(DKPm8_ChatHandler.BroadCastStorageTable, {"DKPm8_Update", RaidId.id.."="..UnitName("raid"..i).."="..GetDKPPlayer(UnitName("raid"..i), RaidName)});
				end;
			end;
		end;
	end;
end;

local timer = 0;
local interval = 0.1;
local lastTick = GetTime();
local DKPm8_BroadcastFrame = CreateFrame("FRAME");
DKPm8_BroadcastFrame:SetScript("OnUpdate",function(s,e)
	if (GetTime() - lastTick > interval) then
		lastTick = GetTime();
		if (table.getn(DKPm8_ChatHandler.BroadCastStorageTable) > 0) then
			SendAddonMessage(DKPm8_ChatHandler.BroadCastStorageTable[1][1], DKPm8_ChatHandler.BroadCastStorageTable[1][2], DKPm8_ChatHandler.BroadCastStorageTable[1][3]);
			table.remove(DKPm8_ChatHandler.BroadCastStorageTable, 1);
		else
			if (table.getn(DKPm8_ChatHandler.AnnouncementsStorageTable) > 0) then
				SendChatMessage(DKPm8_ChatHandler.AnnouncementsStorageTable[1][1], DKPm8_ChatHandler.AnnouncementsStorageTable[1][2], nil, DKPm8_ChatHandler.AnnouncementsStorageTable[1][3]);
				table.remove(DKPm8_ChatHandler.AnnouncementsStorageTable, 1);
			else
				if (table.getn(DKPm8_ChatHandler.BidResponseStorageTable) > 0) then
					SendChatMessage(DKPm8_ChatHandler.BidResponseStorageTable[1][1], DKPm8_ChatHandler.BidResponseStorageTable[1][2], nil, DKPm8_ChatHandler.BidResponseStorageTable[1][3]);
					table.remove(DKPm8_ChatHandler.BidResponseStorageTable, 1);
				else
					if (table.getn(DKPm8_ChatHandler.ChatResponseStorageTable) > 0) then
						SendChatMessage(DKPm8_ChatHandler.ChatResponseStorageTable[1][1], DKPm8_ChatHandler.ChatResponseStorageTable[1][2], nil, DKPm8_ChatHandler.ChatResponseStorageTable[1][3]);
						table.remove(DKPm8_ChatHandler.ChatResponseStorageTable, 1);
					end;
				end;
			end;
		end;
	end;
	
	if (DKPm8_TimeBidExpires ~= 0) and (not DKPm8_ObserveBid) then
		if (DKPm8_Option_SecondsAnnounce) then
			if (GetTime() + 3 > DKPm8_TimeBidExpires) and (not DKPm8_WarningDoneAt3s) then
				DKPm8_WarningDoneAt3s = true;
				SendChatMessage("Bid closing in 3 seconds!", "RAID", nil, nil);
			end;
			if (GetTime() + 2 > DKPm8_TimeBidExpires) and (not DKPm8_WarningDoneAt2s)then
				DKPm8_WarningDoneAt2s = true;
				SendChatMessage("Bid closing in 2 seconds!", "RAID", nil, nil);
			end;
			if (GetTime() + 1 > DKPm8_TimeBidExpires) and (not DKPm8_WarningDoneAt1s)then
				DKPm8_WarningDoneAt1s = true;
				SendChatMessage("Bid closing in 1 seconds!", "RAID", nil, nil);
			end;
		end;	
		if (GetTime() > DKPm8_TimeBidExpires) then
			DKPm8_BidIsActive = false;
			DKPm8_TimeBidExpires = 0;
			SendChatMessage("Bid has been closed on ".. DKPm8_CurrentItem, "RAID_WARNING", nil, nil);
		end;
	end;
end);

local DKPm8_WhisperFrame = CreateFrame("FRAME");
DKPm8_WhisperFrame:RegisterEvent("CHAT_MSG_ADDON");

local function WhisperEventHandler()
	local msg = arg1;
	local player = arg2;
	if (msg == "?dkp") then
		table.insert(DKPm8_ChatHandler.ChatResponseStorageTable, {"Your current DKP are: " .. GetDKPPlayer(player), "WHISPER", player});
	else	
		if (string.starts(msg, "?dkp ")) then
			local infoTarget = string.sub(msg, string.len("?dkp ")+ 1);
			table.insert(DKPm8_ChatHandler.ChatResponseStorageTable, {infoTarget.."'s DKP are: " .. GetDKPPlayer(infoTarget), "WHISPER", player});
		end;
	end;
end;
DKPm8_WhisperFrame:SetScript("OnEvent", WhisperEventHandler)

local DKPm8_AddonFrame = CreateFrame("FRAME");
DKPm8_AddonFrame:RegisterEvent("CHAT_MSG_ADDON");
local function AddonEventHandler()
	local prefix = arg1
	local msg = arg2
	local RaidID, PlayerName;
	if (prefix == "DKPm8_Update") then
		local RaidID, PlayerName, DKP;
		local EndRaidID = string.find(msg, "=", 1)
		local EndPlayerName = string.find(msg, "=", EndRaidID + 1)
		
		RaidID = string.sub(msg, 1, EndRaidID - 1);
		PlayerName = string.sub(msg, EndRaidID + 1, EndPlayerName - 1);
		DKP = string.sub(msg, EndPlayerName + 1);
		if (DKPm8_DkpTable == nil) then
			DKPm8_DkpTable ={};
		end;
		DKPm8_DkpTable[PlayerName]["dkp_"..RaidID]= tonumber(DKP);
	end;
	if (prefix == "DKPm8_UpdateTables") then
		local RaidName, RaidID;
		local EndRaidName = string.find(msg, "=")
		
		if (DKPm8_ZoneTables == nil) then
			DKPm8_ZoneTables ={};
		end;
		
		RaidName = string.sub(msg, 1, EndRaidName - 1);
		RaidID = string.sub(msg, EndRaidName + 1);

		DKPm8_ZoneTables[RaidName]["id"] = RaidID;
	end;
end;
DKPm8_AddonFrame:SetScript("OnEvent", AddonEventHandler);

local DKPm8_AddonFrame = CreateFrame("FRAME");
DKPm8_AddonFrame:RegisterEvent("CHAT_MSG_RAID");
DKPm8_AddonFrame:RegisterEvent("CHAT_MSG_RAID_LEADER");
DKPm8_AddonFrame:RegisterEvent("CHAT_MSG_RAID_WARNING");

local function RaidMsgEventHandler()
	local msg = string.lower(arg1);
	local player = arg2;
	if (msg == "?dkp") then
		table.insert(DKPm8_ChatHandler.ChatResponseStorageTable, {"Your current DKP are: " .. GetDKPPlayer(player), "WHISPER", player});
	else	
		if (string.starts(msg, "?dkp ")) then
			local infoTarget = string.sub(msg, string.len("?dkp ")+ 1);
			table.insert(DKPm8_ChatHandler.ChatResponseStorageTable, {infoTarget.."'s DKP are: " .. GetDKPPlayer(infoTarget), "WHISPER", player});
		end;	
	end;
	
	if (string.starts(msg, "Bid has been closed on ") and (DKPm8_ObserveBid)) then
		DKPm8_BidIsActive = false;
	end
	
	if (string.starts(msg, "-NewBid") and (DKPm8_ObserveBid)) then
		DKPm8_CurrentItem = string.sub(msg, string.len("-NewBid ") + 1);
		DKPm8_CurrentHighestBid = 0
		DKPm8_BidIsActive = true;
		DKPm8_DKPm8_CurrentItem:SetText(DKPm8_CurrentItem);
		DKPBidBar_Clear();
		DKPBidBar_Update();
		DKPm8:Show();
	else
		if (not string.starts(msg, "-NewBid")) then
			if (DKPm8_BidIsActive) then
				local bidvalue = tonumber(msg);
				local shard = string.find(msg, "shard");
				local HighlightBid = "green";
				
				if shard ~= nil then
					bidvalue = 0;
				end;				
				if (bidvalue == nil) then
					StartBidValue = string.find(msg, "%d+");
					if (string.find(string.reverse(msg), "%d+") ~= nil) then
						EndBidValue = string.len(msg) - string.find(string.reverse(msg), "%d+");
					end;
					if (StartBidValue ~= nil) and (EndBidValue ~= nil) then
						bidvalue = tonumber(string.sub(msg, StartBidValue, EndBidValue + 1));
					end;
					if (bidvalue ~= nil) then
						HighlightBid = "orange";
					end;
				end;				
				if (bidvalue ~= nil) then
					if ((not DKPm8_ObserveBid) and (DKPm8_TimeBidExpires - GetTime() < DKPm8_InitialBidDurationExtention)) then
						BWCB(DKPm8_InitialBidDurationExtention, DKPm8_CurrentItem);
						DKPm8_TimeBidExpires = GetTime() +  DKPm8_InitialBidDurationExtention;
						DKPm8_WarningDoneAt3s = false;
						DKPm8_WarningDoneAt2s = false;
						DKPm8_WarningDoneAt1s = false;
					end;
					if (bidvalue > GetDKPPlayer(player)) then
						if (not DKPm8_ObserveBid) and (DKPm8_Option_WhisperResponse) then
							table.insert(DKPm8_ChatHandler.BidResponseStorageTable, {"You bid more DKP than you got! Bid counts as ALLIN with: ".. GetDKPPlayer(player), "WHISPER", player});
						end;
						bidvalue = GetDKPPlayer(player);
						HighlightBid = "orange";
					end;
					
					local MinBidSize;
					if (DKPm8_CurrentHighestBid < 200) then
						MinBidSize = 10;
					elseif (DKPm8_CurrentHighestBid < 600) then
						MinBidSize = 50;
					else
						MinBidSize = 100;
					end;
					
					if (bidvalue < DKPm8_CurrentHighestBid + MinBidSize) and (bidvalue ~= GetDKPPlayer(player)) and (bidvalue ~= 0) then
						if (not DKPm8_ObserveBid) and (DKPm8_Option_WhisperResponse) then
							table.insert(DKPm8_ChatHandler.BidResponseStorageTable, {"Someone already bid:  ".. DKPm8_CurrentHighestBid, "WHISPER", player});
						end;
						HighlightBid = "red";
					else
						DKPm8_CurrentHighestBid = bidvalue;
					end;
					
					if (table.getn(BidData) > 0) then
						local isInList = false;
						for i = 1, table.getn(BidData) do
							if (BidData[i][1] == player) then
								isInList = true;
								if (BidData[i][2] < bidvalue) then
									BidData[i][2] = bidvalue;
									BidData[i][4] = msg;
									BidData[i][5] = HighlightBid;
									if(not DKPm8_ObserveBid) and (DKPm8_Option_WhisperResponse) then
										table.insert(DKPm8_ChatHandler.BidResponseStorageTable, {"Bid of ".. bidvalue .. " accepted!", "WHISPER", player});
									end;
								end;
							end;
						end;
						if (not isInList) then
							table.insert(BidData, {player, bidvalue, GetDKPPlayer(player),msg,HighlightBid});
						end;
					else
						table.insert(BidData, {player, bidvalue, GetDKPPlayer(player),msg,HighlightBid});
					end;
					
					if (not DKPm8_ObserveBid) then
						if (bidvalue == 0) and (DKPm8_Option_WhisperResponse) then
							table.insert(DKPm8_ChatHandler.BidResponseStorageTable, {"Shard bid accepted!", "WHISPER", player});
						else
							table.insert(DKPm8_ChatHandler.BidResponseStorageTable, {"Bid of ".. bidvalue .. " accepted!", "WHISPER", player});
						end;
					end;
					table.sort(BidData, function(a,b) return a[2]>b[2] end);
					DKPBidBar_Update(DKPm8_CurrentHighestBid);
				end;
			end;
		end;
	end;
end;

DKPm8_AddonFrame:SetScript("OnEvent", RaidMsgEventHandler)

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start;
end;

function GetDKPTables()
	if(WebDKP_DkpTable ~= nil) then
		DKPm8_DkpTable = WebDKP_DkpTable;
		DKPm8_ZoneTables = WebDKP_Tables;
		DEFAULT_CHAT_FRAME:AddMessage("Copied WebDKP - Tables!");
		return true;
	else
		return false;
	end;
end;

function GetDKPPlayer(player, Raid)

	if (DKPm8_DkpTable == nil) then
		if (not GetDKPTables()) then
			return 0;
		end;
	end;
	
	local KeyZoneName;
	if (Raid == nil) then
		local zone = GetZoneText();
		if (zone == "Temple of Ahn'Qiraj") then
			KeyZoneName = "Ahn Qiraj";
		elseif (zone == "Blackwing Lair") then
			KeyZoneName = "Blackwing Lair";
		elseif (zone == "Onyxia's Lair") then
			KeyZoneName = "Molten Core";
		elseif (zone == "Molten Core") then
			KeyZoneName = "Molten Core";
		end;
	else
		KeyZoneName = Raid;
	end
		
	if (KeyZoneName ~= nil) then
	
		if (DKPm8_DkpTable[player]["dkp_"..DKPm8_ZoneTables[KeyZoneName].id] ~= nil) then
			return DKPm8_DkpTable[player]["dkp_"..DKPm8_ZoneTables[KeyZoneName].id];
		else
			return 0;
		end;
	end;
	return 0;
end;

function string.reverse(String)
	local reverseString = "";
	for i = 1, string.len(String) do
		reverseString = reverseString .. string.sub(String, string.len(String) - i, string.len(String) - i + 1);
	end;
	return reverseString;
end;