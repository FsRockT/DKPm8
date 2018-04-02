BidData = {}

function DKPm8_OnLoad()
	DKPBidBar_Clear();
	DKPBidBar:Show();
end

function DKPBidBar_Update(highBidValue)
	local line;
	local lineplusoffset;
	local MinBidSize, NextBidValue, MaxPossibleBid;
	FauxScrollFrame_Update(DKPBidBar,40,11,16);
	for line=1,11 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(DKPBidBar);
		if (lineplusoffset <= 40) and (lineplusoffset <= table.getn(BidData)) then
			if (BidData[lineplusoffset][1] ~= "") then
				getglobal("DKPBidBar_PlayerName"..line):SetText(BidData[lineplusoffset][1]); 
				getglobal("DKPBidBar_PlayerName"..line).tooltip=BidData[lineplusoffset][4];
				if (BidData[lineplusoffset][5] == "red") then
					getglobal("DKPBidBar_PlayerName"..line):SetTextColor(1, 0, 0);
				elseif (BidData[lineplusoffset][5] == "orange") then
					getglobal("DKPBidBar_PlayerName"..line):SetTextColor(1, 0.6, 0);
				else
					getglobal("DKPBidBar_PlayerName"..line):SetTextColor(0, 1, 0);
				end;
				getglobal("DKPBidBar_PlayerName"..line):Show();
				
				getglobal("DKPBidBar_PlayerBid"..line):SetText(BidData[lineplusoffset][2]); 
				getglobal("DKPBidBar_PlayerBid"..line).tooltip=BidData[lineplusoffset][4];
				if (BidData[lineplusoffset][5] == "red") then
					getglobal("DKPBidBar_PlayerBid"..line):SetTextColor(1, 0, 0);
				elseif (BidData[lineplusoffset][5] == "orange") then
					getglobal("DKPBidBar_PlayerBid"..line):SetTextColor(1, 0.6, 0);
				else
					getglobal("DKPBidBar_PlayerBid"..line):SetTextColor(0, 1, 0);
				end;
				getglobal("DKPBidBar_PlayerBid"..line):Show();
				
				getglobal("DKPBidBar_PlayerCurrentDKP"..line):SetText(BidData[lineplusoffset][3]);
				getglobal("DKPBidBar_PlayerCurrentDKP"..line).tooltip=BidData[lineplusoffset][4];
				if (BidData[lineplusoffset][5] == "red") then
					getglobal("DKPBidBar_PlayerCurrentDKP"..line):SetTextColor(1, 0, 0);
				elseif (BidData[lineplusoffset][5] == "orange") then
					getglobal("DKPBidBar_PlayerCurrentDKP"..line):SetTextColor(1, 0.6, 0);
				else
					getglobal("DKPBidBar_PlayerCurrentDKP"..line):SetTextColor(0, 1, 0);
				end;
				getglobal("DKPBidBar_PlayerCurrentDKP"..line):Show();
			else
				getglobal("DKPBidBar_PlayerName"..line):Hide();
				getglobal("DKPBidBar_PlayerBid"..line):Hide();
				getglobal("DKPBidBar_PlayerCurrentDKP"..line):Hide();
			end;
		else
			getglobal("DKPBidBar_PlayerName"..line):Hide();
			getglobal("DKPBidBar_PlayerBid"..line):Hide();
			getglobal("DKPBidBar_PlayerCurrentDKP"..line):Hide();
		end;
	end;
	
	if (highBidValue ~= nil) then
		if (highBidValue < 200) then
			MinBidSize = 10;
		elseif (highBidValue < 600) then
			MinBidSize = 50;
		else
			MinBidSize = 100;
		end
		NextBidValue = highBidValue + MinBidSize;	
		MaxPossibleBid = GetDKPPlayer(UnitName("player"));

		if (NextBidValue > MaxPossibleBid) then
			NextBidValue = MaxPossibleBid;
		end
		
		if (NextBidValue < 50) then
			NextBidValue = 50;
		end
		
		BidValue:SetText(NextBidValue);
	end
end

function DKPBidBar_Clear()
	BidData = {};
	for i=1,11 do
		getglobal("DKPBidBar_PlayerName"..i):Hide();
		getglobal("DKPBidBar_PlayerBid"..i):Hide();
		getglobal("DKPBidBar_PlayerCurrentDKP"..i):Hide();
	end;
end;
