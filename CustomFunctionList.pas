
unit CustomFunctionList;

{
```pascal
```
}
{ General Notes
  If the code says it expects 'end;' but finds 'end of file' check that 'if' statements are followed by 'then' and 'for' statement are followed by 'do'
}

// Settings and Default values
const
	defaultOutputPlugin = 'Automated Leveled List Addition.esp';
	defaultGenerateEnchantedVersions = True;
	defaultReplaceInLeveledList = True;
	defaultAllowDisenchanting = True;
	defaultBreakdownEnchanted	= True;
	defaultBreakdownDaedric = True;
	defaultBreakdownDLC = True;
	defaultGenerateRecipes = True;	
	defaultChanceBoolean = True;
	defaultAutoDetect = True;
	defaultBreakdown = True;
	defaultOutfitSet = False;
	defaultCrafting = True;
	defaultTemper = True;	
	defaultChanceMultiplier = 10;
	defaultEnchMultiplier = 100;
	defaultItemTier01 = 1;
	defaultItemTier02 = 10;
	defaultItemTier03 = 20;
	defaultItemTier04 = 30;
	defaultItemTier05 = 35;
	defaultItemTier06 = 40;
	defaultTemperLight = 1;
	defaultTemperHeavy = 2;
	ProcessTime = True;
	Constant = True;

var 
	slGlobal, slProcessTime: TStringList;
	selectedRecord: IInterface;

// Find loaded plugin by name
function FileByName(aPluginName: String): IInterface;
var
	debugMsg: Boolean;
  i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[FileByName] FileByName( '+aPluginName+' );');
  for i := 0 to Pred(FileCount) do begin
    Result := FileByIndex(i);
		{Debug} if debugMsg then msg('FileByIndex(i) := '+GetFileName(Result));
    if (GetFileName(Result) = aPluginName) then begin
			{Debug} if debugMsg then msg('Result := '+GetFileName(Result));;
			Exit; 
		end;
  end;
  Result := nil;
	
	debugMsg := False;
// End debugMsg section
end;

// Find if a file is loaded is xEdit
function DoesFileExist(aPluginName: String): Boolean;
var
	debugMsg: Boolean;
  i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Function
  Result := True;
  for i := 0 to Pred(FileCount) do begin
		// {Debug} if debugMsg then msg('[DoesFileExist] GetFileName(aPluginName) := '+aPluginName);
		{Debug} if debugMsg then msg('[DoesFileExist] if ( '+aPluginName+' = '+GetFileName(FileByIndex(i))+' ) then begin');
		if (aPluginName = GetFileName(FileByIndex(i))) then begin
			{Debug} if debugMsg then msg('[DoesFileExist] Result := '+GetFileName(FileByIndex(i)));
			Exit;
		end;
	end;
  Result := False;
	
	debugMsg := FALSE
// End debugMsg Section
end;

// Find if a file contains an EditorID in a specific group
function DoesFileContain(aPlugin: IInterface; aGroupName: String; aRecord: IInterface): String;
var
  i: Integer;
begin
  if HasGroup(aPlugin, aGroupName) then begin
    Result := 'True';
	for i := 0 to Pred(ec(gbs(aPlugin, aGroupName))) do if GetLoadOrderFormID(ebi(gbs(aPlugin, aGroupName), i)) = GetLoadOrderFormID(aRecord) then Exit;
    Result := 'False';
  end else Exit;
end;

// Find where the selected record is referenced in leveled lists and make a 'Copy as Override' into a specified file.  Then replace all instances of inputRecord with replaceRecord in the override
Procedure ReplaceInLeveledListAuto(inputRecord, replaceRecord, aPlugin: IInterface);
var
  LLrecord, LLcopy, masterRecord: IInterface;
	debugMsg, tempBoolean: Boolean;
	tempString: String;
  i, x: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[ReplaceInLeveledListAuto] ReplaceInLeveledListAuto( '+EditorID(inputRecord)+', '+EditorID(replaceRecord)+', '+GetFileName(aPlugin)+' );');
	masterRecord := MasterOrSelf(inputRecord);
	for i := 0 to Pred(rbc(masterRecord)) do begin
		LLrecord := rbi(masterRecord, i);
		if StrWithinStr(EditorID(LLrecord), '++') or not IsHighestOverride(rbi(masterRecord, i), GetLoadOrder(aPlugin)) or (GetLoadOrder(GetFile(LLrecord)) > GetLoadOrder(aPlugin)) or (Length(EditorID(LLrecord)) = 0) then Continue;
		// Restricts the output to a single file (for 'Patch' function)				
		tempBoolean := False;
		if slContains(slGlobal, 'Patch') then begin
			if (OverrideCount(LLrecord) > 0) then begin			
				for x := 0 to Pred(OverrideCount(LLrecord)) do
					if (GetFileName(GetFile(OverrideByIndex(LLrecord, x))) = GetFileName(ote(GetObject('Patch', slGlobal)))) then
						tempBoolean := True;
			end else begin
				if (GetFileName(GetFile(LLrecord)) = GetFileName(ote(GetObject('Patch', slGlobal)))) then
					tempBoolean := True;		
			end;
			if not tempBoolean then Continue;
		end;
		// Filter Invalid Entries
		if StrWithinStr(EditorID(LLrecord), '++') or not (Length(EditorID(LLrecord)) > 0) or not IsHighestOverride(LLrecord, GetLoadOrder(aPlugin)) or not (sig(LLrecord) = 'LVLI') or FlagCheck(LLrecord, 'Use All') or FlagCheck(LLrecord, 'Special Loot') or StrWithinStr(EditorID(LLrecord), '++') then Continue;
		if slContains(slGlobal, EditorID(LLrecord)) then 
			if (EditorID(masterRecord) = EditorID(ote(slGlobal.Objects[slGlobal.IndexOf(EditorID(LLrecord))]))) then 
				Continue;		
		if not IsWinningOverride(LLrecord) and (GetLoadOrder(GetFile(WinningOverride(LLrecord))) <> GetLoadOrder(aPlugin)) then begin
			msg('	');
			msg('[WARNING] Edits to the '+EditorID(LLrecord)+' leveled list are made in '+GetFileName(GetFile(WinningOverride(LLrecord)))+' which is loaded after '+GetFileName(aPlugin)+' ('+IntToStr(GetLoadOrder(GetFile(WinningOverride(LLrecord))))+' > '+IntToStr(GetLoadOrder(GetFile(LLrecord)))+')');
			msg('[WARNING] In order for '+EditorID(replaceRecord)+' to show up in game you will need to find the plugin '+GetFileName(aPlugin)+' in the left pane, open ''Leveled Item'', and find '+EditorID(LLrecord));
			msg('[WARNING] Find the '+GetFileName(aPlugin)+' column in the right pane and drag the highlighted '+EditorID(replaceRecord)+' changes to the furthest right column, '+GetFileName(GetFile(WinningOverride(LLrecord))));
			msg('[WARNING] Note: If '+GetFileName(GetFile(WinningOverride(LLrecord)))+' is a Bashed/Smash patch, iActivate patch, etc. you simply need to run the patcher again');
			msg('	');
		end;
		// {Debug} if debugMsg then msg('[ReplaceInLeveledListAuto] if not ( '+IntToStr(GetLoadOrder(aPlugin))+' > '+IntToStr(GetLoadOrder(GetFile(LLrecord)))+' ) then Continue;');
		{Debug} if debugMsg then msg('[ReplaceInLeveledListAuto] if ( '+sig(LLrecord)+' = LVLI ) and ( '+EditorID(LLrecord)+' <> '+EditorID(replaceRecord)+' ) then begin');
		if (sig(LLrecord) = 'LVLI') then begin
			{Debug} if debugMsg then msg('[ReplaceInLeveledListAuto] if ( '+sig(LLrecord)+' = LVLI) and ( '+EditorID(LLrecord)+' <> '+EditorID(replaceRecord)+' ) then begin');
			if LLcontains(LLrecord, masterRecord) then begin
				AddMastersAuto(LLrecord, aPlugin);
				LLcopy := ebEDID(gbs(aPlugin, 'LVLI'), EditorID(LLrecord));
				if not Assigned(LLcopy) then
					LLcopy := CopyRecordToFile(LLrecord, aPlugin, False, True);
				{Debug} if debugMsg then msg('[ReplaceInLeveledListAuto] LLcopy := '+EditorID(LLcopy));
				if Assigned(LLcopy) then begin
					{Debug} if debugMsg then msg('[ReplaceInLeveledListAuto] LLreplace( '+EditorID(LLcopy)+', '+EditorID(masterRecord)+', '+EditorID(replaceRecord)+' );');
					LLreplace(LLcopy, masterRecord, replaceRecord);
				end;
			end;
		end;
	end;

	debugMsg := False;
// End debugMsg section
end;

// Find where the selected record is referenced in leveled lists and make a 'Copy as Override' into a specified file.  Then replace all instances of inputRecord with replaceRecord in the override
Procedure ReplaceInLeveledListByList(aList, bList: TStringList; aPlugin: IInterface);
var
  LLrecord, LLcopy, tempRecord, tempElement, inputRecord: IInterface;
	i, x, y, tempInteger, LoadOrder: Integer;
	debugMsg, tempBoolean, Patch: Boolean;
	startTime, stopTime: TDateTime;
	slTemp, slLL: TStringList;
	tempString: String;
begin
	// Initialize
	debugMsg := False;
	startTime := Time;
	slTemp := TStringList.Create;
	slLL := TStringList.Create;
	
	{Debug} if debugMsg then msg('[ReplaceInLeveledListByList] AddToLeveledListByList( aList, bList, '+GetFileName(aPlugin)+' );');
	{Debug} if debugMsg then msgList('[ReplaceInLeveledListByList] aList := ', aList, ' );');
	{Debug} if debugMsg then msg(' ');
	{Debug} if debugMsg then msgList('[ReplaceInLeveledListByList] bList := ', bList, ' );');
	{Debug} if debugMsg then msg(' ');
	Patch := slContains(slGlobal, 'Patch');	
	LoadOrder := GetLoadOrder(aPlugin);
	for i := 0 to aList.Count-1 do begin
		tempRecord := ote(aList.Objects[i]);
		for x := 0 to Pred(rbc(tempRecord)) do begin
			LLrecord := rbi(tempRecord, x);
			// Filter Invalid Entries
			{Debug} if debugMsg then msg('[ReplaceInLeveledListByList] LLrecord := '+EditorID(LLrecord));
			if StrWithinStr(EditorID(LLrecord), '++') or not (Length(EditorID(LLrecord)) > 0) or not IsHighestOverride(LLrecord, GetLoadOrder(aPlugin)) or not (sig(LLrecord) = 'LVLI') or FlagCheck(LLrecord, 'Use All') or FlagCheck(LLrecord, 'Special Loot') or StrWithinStr(EditorID(LLrecord), '++') then Continue;
			if slContains(slGlobal, EditorID(LLrecord)) then 
				if not (EditorID(tempRecord) = EditorID(ote(slGlobal.Objects[slGlobal.IndexOf(EditorID(LLrecord))]))) then 
					Continue;
			if not (LoadOrder >= GetLoadOrder(GetFile(LLrecord))) then begin
				if PreviousOverrideExists(LLrecord, LoadOrder) then begin
					msg('	');
					msg('[WARNING] Edits to the '+EditorID(LLrecord)+' leveled list are made in '+GetFileName(GetFile(WinningOverride(LLrecord)))+' which is loaded after '+GetFileName(aPlugin)+' ('+IntToStr(GetLoadOrder(GetFile(WinningOverride(LLrecord))))+' > '+IntToStr(GetLoadOrder(GetFile(LLrecord)))+')');
					msg('[WARNING] In order for '+EditorID(replaceRecord)+' to show up in game you will need to find the plugin '+GetFileName(aPlugin)+' in the left pane, open ''Leveled Item'', and find '+EditorID(LLrecord));
					msg('[WARNING] Find the '+GetFileName(aPlugin)+' column in the right pane and drag the highlighted '+EditorID(replaceRecord)+' changes to the furthest right column, '+GetFileName(GetFile(WinningOverride(LLrecord))));
					msg('[WARNING] Note: If '+GetFileName(GetFile(WinningOverride(LLrecord)))+' is a Bashed/Smash/iActive patch you simply need to run the Bashed/Smash/iActivate patcher again');
					msg('	');
					LLrecord := GetPreviousOverride(LLrecord, LoadOrder);
				end else
					Continue;
			end else if debugMsg then msg('[ReplaceInLeveledListByList] '+EditorID(LLrecord)+' := '+IntToStr(LoadOrder)+' >= '+IntToStr(GetLoadOrder(GetFile(LLrecord))));
			// Restricts the valid leveled lists to a single file (for 'Patch' function)
			// {Debug} if debugMsg then msg('[ReplaceInLeveledListByList] Restricts the valid leveled lists to a single file (for Patch function)');
			if Patch then begin
				tempString := GetFileName(ote(GetObject('Patch', slGlobal)));
				tempBoolean := False;
				// {Debug} if debugMsg then msg('[ReplaceInLeveledListByList] for x := 0 to '+IntToStr(Pred(OverrideCount(LLrecord)))+' do begin');
				if (OverrideCount(LLrecord) > 0) then begin
					for y := 0 to Pred(OverrideCount(LLrecord)) do begin
						{Debug} if debugMsg then msg('[ReplaceInLeveledListByList] if (GetFileName(GetFile(OverrideByIndex( '+EditorID(LLrecord)+', '+IntToStr(x)+'))) = '+tempString+') then begin');
						if (GetFileName(GetFile(OverrideByIndex(LLrecord, y))) = tempString) then begin
							tempBoolean := True;
							Break;
						end;
					end;
				end else
					if (GetFileName(GetFile(LLrecord)) = tempString) then
						tempBoolean := True;
				if not tempBoolean then Continue;
			end;
			// Add Copy to List
			if not slContains(slLL, EditorID(LLrecord)) then
				slLL.AddObject(EditorID(LLrecord), TObject(LLrecord));			
		end;	
	end;
	AddMastersList(slLL, aPlugin);
	{Debug} if debugMsg then msgList('[ReplaceInLeveledListByList] slLL := ', slLL, ' );');
	{Debug} if debugMsg then msg(' ');	
	for i := 0 to slLL.Count-1 do begin
		slTemp.Clear;		
		LLrecord := ote(slLL.Objects[i]);
		{Debug} if debugMsg then msg('[ReplaceInLeveledListByList] LLrecord := '+EditorID(LLrecord));
		if not (Length(EditorID(LLrecord)) > 0) then Continue
		tempElement := ebn(LLrecord, 'Leveled List Entries');
		for x := 0 to Pred(LLec(LLrecord)) do begin
			tempRecord := ebi(tempElement, x);
			slTemp.AddObject(StrPosCopy(geev(tempRecord, 'LVLO\Reference'), ' ', True), TObject(genv(tempRecord, 'LVLO\Level'))); 		
		end; {Debug} if debugMsg then msgList('[ReplaceInLeveledListByList] slTemp := ', slTemp, ' );');
		for x := 0 to bList.Count-1 do begin
			if slContains(slTemp, bList[x]) then begin
				for y := 0 to slTemp.Count-1 do begin
					if (slTemp[y] = bList[x]) then begin {Debug} if debugMsg then msg('[ReplaceInLeveledListByList] if ('+slTemp[y]+' = '+bList[x]+') then begin');						
						tempRecord := ote(bList.Objects[x]);
						if not slContains(slTemp, EditorID(tempRecord)) then begin
							// Detect Pre-Existing List or Create Override
							if not (LoadOrder = GetLoadOrder(GetFile(LLrecord))) then begin								
								LLcopy := CopyRecordToFile(LLrecord, aPlugin, False, True);
							end else
								LLcopy := LLrecord;
							// Replace 
							tempInteger := 0;
							tempInteger := Integer(slTemp.Objects[y]);
							if not (tempInteger > 0) then begin
								LLreplace(LLcopy, ote(aList.Objects[aList.IndexOf(bList[x])]), tempRecord);
							end else
								LLreplace(LLcopy, ote(aList.Objects[aList.IndexOf(bList[x])]), tempRecord);
							slTemp.AddObject(EditorID(LLrecord), TObject(tempInteger));
							// msg(slTemp[y]+' replaced with '+EditorID(tempRecord)+' in '+EditorID(LLcopy));
						end;
					end;
				end;
			end;
		end;
  end;

	// Finalize
	stopTime := Time;
	if ProcessTime then addProcessTime('ReplaceInLeveledListByList', TimeBtwn(startTime, stopTime));
	slTemp.Free;
	slLL.Free;
end;

// Find where the selected record is referenced in leveled lists and make a 'Copy as Override' into a specified file.  Then replace all instances of templateRecord with inputRecord in the override
function AddToLeveledListAuto(templateRecord: IInterface; inputRecord: IInterface; aPlugin: IInterface): String;
var
  LLrecord, LLcopy, masterRecord, inputEntry, tempRecord, tempElement: IInterface;
  debugMsg, tempBoolean, AddToEnchanted, Patch: Boolean;
	slRecords: TStringList;
  i, x, y, tempInteger: Integer;
	tempString: String;
begin
// Begin debugMsg Section
	debugMsg := False;
	
	// Initialize
	slRecords := TStringList.Create;
	
	{Debug} if debugMsg then msg('[AddToLeveledListAuto] AddToLeveledListAuto( '+EditorID(templateRecord)+', '+EditorID(inputRecord)+', '+GetFileName(aPlugin)+' );');
	Patch := slContains(slGlobal, 'Patch');
	masterRecord := WinningOverride(templateRecord);	{Debug} if debugMsg then msg('[AddToLeveledListAuto] masterRecord := '+full(masterRecord)); 
	// This pulls the item out of chanceLeveledList in order to keep the msg statements consistent
  {Debug} if debugMsg then msg('[AddToLeveledListAuto] if '+sig(inputRecord)+' = ''LVLI'' then begin');
  if (sig(inputRecord) = 'LVLI') then begin {Debug} if debugMsg then msg('[AddToLeveledListAuto] Pred(LLec(inputRecord)) := '+IntToStr(Pred(LLec(inputRecord))));
    for i := 0 to Pred(LLec(inputRecord)) do begin {Debug} if debugMsg then msg('[AddToLeveledListAuto] inputEntry := '+full(LLebi(inputRecord, i)));
			inputEntry := LLebi(inputRecord, i); {Debug} if debugMsg then msg('[AddToLeveledListAuto] if not (sig(inputEntry) := '+sig(inputEntry)+' = ''LVLI'') then Break; ');
			if not (sig(inputEntry) = 'LVLI') then Break; 
		end;
  end else begin 
		inputEntry := templateRecord; 
		{Debug} if debugMsg then msg('[AddToLeveledListAuto] full(inputEntry) := '+full(inputEntry)+' EditorID(inputEntry := '+EditorID(inputEntry)); 
	end;	
	// msg('['+full(inputEntry)+'] Processing '+IntToStr(rbc(masterRecord))+' '+EditorID(inputEntry)+' References (This May Take A While)');
	{Debug} if debugMsg then msg('[AddToLeveledListAuto] Pred(rbc(masterRecord)) := '+IntToStr(Pred(rbc(masterRecord))));
	// Begins analyzing records that reference masterRecord
	for i := 0 to Pred(rbc(masterRecord)) do begin
		LLrecord := rbi(masterRecord, i);
		// Filter Invalid Entries
		if StrWithinStr(EditorID(LLrecord), '++') or not (Length(EditorID(LLrecord)) > 0) or not IsHighestOverride(LLrecord, GetLoadOrder(aPlugin)) or not (sig(LLrecord) = 'LVLI') or FlagCheck(LLrecord, 'Use All') or FlagCheck(LLrecord, 'Special Loot') then Continue;
		if slContains(slGlobal, EditorID(LLrecord)) then 
			if (EditorID(inputRecord) = EditorID(ote(slGlobal.Objects[slGlobal.IndexOf(EditorID(LLrecord))]))) then 
				Continue;
		// Restricts the valid leveled lists to a single file (for 'Patch' function)
		// {Debug} if debugMsg then msg('[AddToLeveledListAuto] Restricts the valid leveled lists to a single file (for Patch function)');
		if Patch then begin
			tempString := GetFileName(ote(GetObject('Patch', slGlobal)));
			tempBoolean := False;
			// {Debug} if debugMsg then msg('[AddToLeveledListAuto] for x := 0 to '+IntToStr(Pred(OverrideCount(LLrecord)))+' do begin');
			if (OverrideCount(LLrecord) > 0) then begin
				for x := 0 to Pred(OverrideCount(LLrecord)) do begin
					{Debug} if debugMsg then msg('[AddToLeveledListAuto] if (GetFileName(GetFile(OverrideByIndex( '+EditorID(LLrecord)+', '+IntToStr(x)+'))) = '+tempString+') then begin');
					if (GetFileName(GetFile(OverrideByIndex(LLrecord, x))) = tempString) then
						tempBoolean := True;
				end;
			end else
				if (GetFileName(GetFile(LLrecord)) = tempString) then
					tempBoolean := True;
			if not tempBoolean then Continue;
		end;
		slRecords.AddObject(EditorID(LLrecord), TObject(LLrecord));
	end;
	// Add Masters
	AddMastersList(slRecords, aPlugin);
	for i := 0 to slRecords.Count-1 do begin
		LLrecord := ote(slRecords.Objects[i]);
		// Detect Pre-Existing List
		{Debug} if debugMsg then msg('[AddToLeveledListAuto] LLcopy := ebEDID( gbs(aPlugin, ''LVLI''), '+EditorID(LLrecord)+' );');
		LLcopy := ebEDID(gbs(aPlugin, 'LVLI'), EditorID(LLrecord));
		// Create override if not already present
		if not Assigned(LLcopy) then
			LLcopy := CopyRecordToFile(LLrecord, aPlugin, False, True);
		RemoveInvalidEntries(LLcopy);
		{Debug} if debugMsg then msg('[AddToLeveledListAuto] LLrecord := '+EditorID(rbi(masterRecord, i)));
		if not LLcontains(LLrecord, inputRecord) then begin
			tempElement := ebn(LLrecord, 'Leveled List Entries');
			for x := 0 to Pred(LLec(LLrecord)) do begin {Debug} if debugMsg then msg('[AddToLeveledListAuto] LLebi(LLrecord, x) := '+EditorID(LLebi(LLrecord, x)));
				{Debug} if debugMsg then msg('[AddToLeveledListAuto] if (GetLoadOrderFormID(masterRecord) := '+IntToStr(GetLoadOrderFormID(masterRecord))+') = (GetLoadOrderFormID(LLebi(LLrecord, x)) := '+IntToStr(GetLoadOrderFormID(LLebi(LLrecord, x)))+') then begin');
				tempRecord := ebi(tempElement, x);
				if geev(tempRecord, 'LVLO\Reference') = Name(masterRecord)) then begin										
					tempInteger := 0;
					tempInteger := GetElementNativeValues(tempRecord, 'LVLO\Level');
					if not (tempInteger > 0) then begin
						addToLeveledList(LLcopy, inputRecord, 1);
					end else
						addToLeveledList(LLcopy, inputRecord, tempInteger);
					msg(EditorID(inputRecord)+' added to '+EditorID(LLrecord));
					Break;
				end;
			end;
		end;
  end;
	
	debugMsg := False;
// End debugMsg section
end;

// Find where the selected record is referenced in leveled lists and make a 'Copy as Override' into a specified file.  Then replace all instances of templateRecord with inputRecord in the override
Procedure AddToLeveledListByList(aList, bList: TStringList; aPlugin: IInterface);
var
  LLrecord, LLcopy, masterRecord, tempRecord, tempElement: IInterface;
	i, x, y, tempInteger, LoadOrder: Integer;
  debugMsg, tempBoolean, Patch: Boolean;
	slLL, slTemp, slMessage: TStringList;
  startTime, stopTime: TDateTime;
	tempString: String;
begin
	// Initialize
	debugMsg := False;
	startTime := Time;
	slMessage := TStringList.Create;
	slTemp := TStringList.Create;
	slTemp.Sorted := True;
	slTemp.Duplicates := dupIgnore;
	slLL := TStringList.Create;
	
	{Debug} if debugMsg then msg('[AddToLeveledListByList] AddToLeveledListByList( aList, bList, '+GetFileName(aPlugin)+' );');
	{Debug} if debugMsg then msg(' ');
	{Debug} if debugMsg then msgList('[AddToLeveledListByList] slGlobal := ', slGlobal, '');
	{Debug} if debugMsg then msg(' ');
	{Debug} if debugMsg then msgList('[AddToLeveledListByList] aList := ', aList, '');
	{Debug} if debugMsg then msg(' ');
	{Debug} if debugMsg then msgList('[AddToLeveledListByList] bList := ', bList, '');
	{Debug} if debugMsg then msg(' ');
	{Debug} if debugMsg then for i := 0 to slGlobal.Count-1 do if StrWithinStr(slGlobal[i], '-//-') then msg('[AddToLeveledListByList] '+slGlobal[i]+' := '+EditorID(ote(slGlobal.Objects[i])));
	{Debug} if debugMsg then for i := 0 to slGlobal.Count-1 do if StrWithinStr(slGlobal[i], '-/Level/-') then msg('[AddToLeveledListByList] '+slGlobal[i]+' := '+IntToStr(Integer(slGlobal.Objects[i])));
	Patch := slContains(slGlobal, 'Patch');	
	LoadOrder := GetLoadOrder(aPlugin);
	// Add Masters
	 {Debug} if debugMsg then msg('[AddToLeveledListByList] Adding Masters');
	AddMastersList(aList, aPlugin);
	for i := 0 to aList.Count-1 do begin
		masterRecord := ote(GetObject(aList[i]+'Template', slGlobal));
		for x := 0 to Pred(rbc(masterRecord)) do begin
			LLrecord := rbi(masterRecord, x);
			// Filter Invalid Entries
			if StrWithinStr(EditorID(LLrecord), '++') or not (Length(EditorID(LLrecord)) > 0) or not IsHighestOverride(LLrecord, GetLoadOrder(aPlugin)) or not (sig(LLrecord) = 'LVLI') or FlagCheck(LLrecord, 'Use All') or FlagCheck(LLrecord, 'Special Loot')or StrWithinStr(EditorID(LLrecord), '++') then Continue;
			if slContains(slGlobal, EditorID(LLrecord)) then 
				if (EditorID(masterRecord) = EditorID(ote(slGlobal.Objects[slGlobal.IndexOf(EditorID(LLrecord))]))) then 
					Continue;
			if not (LoadOrder >= GetLoadOrder(GetFile(LLrecord))) then begin
				if PreviousOverrideExists(LLrecord, LoadOrder) then begin
					LLrecord := GetPreviousOverride(LLrecord, LoadOrder);
				end else
					Continue;
			end else if debugMsg then msg('[AddToLeveledListByList] '+EditorID(LLrecord)+' := '+IntToStr(LoadOrder)+' >= '+IntToStr(GetLoadOrder(GetFile(LLrecord))));				
			// Restricts the valid leveled lists to a single file (for 'Patch' function)
			// {Debug} if debugMsg then msg('[AddToLeveledListByList] Restricts the valid leveled lists to a single file (for Patch function)');
			if Patch then begin
				tempString := GetFileName(ote(GetObject('Patch', slGlobal)));
				tempBoolean := False;
				// {Debug} if debugMsg then msg('[AddToLeveledListByList] for x := 0 to '+IntToStr(Pred(OverrideCount(LLrecord)))+' do begin');
				if (OverrideCount(LLrecord) > 0) then begin
					for y := 0 to Pred(OverrideCount(LLrecord)) do begin
						{Debug} if debugMsg then msg('[AddToLeveledListByList] if (GetFileName(GetFile(OverrideByIndex( '+EditorID(LLrecord)+', '+IntToStr(x)+'))) = '+tempString+') then begin');
						if (GetFileName(GetFile(OverrideByIndex(LLrecord, y))) = tempString) then begin
							tempBoolean := True;
							Break;
						end;
					end;
				end else
					if (GetFileName(GetFile(LLrecord)) = tempString) then
						tempBoolean := True;
				if not tempBoolean then Continue;
			end;
			// Add Copy to List
			if not slContains(slLL, EditorID(LLrecord)) then
				slLL.AddObject(EditorID(LLrecord), TObject(LLrecord));
		end;
		// Custom Leveled List Input
		tempString := '-//-'+EditorID(ote(aList.Objects[i]));  {Debug} if debugMsg then msg('[AddToLeveledListByList] tempString := '+tempString);
		for x := 0 to slGlobal.Count-1 do begin	
			// {Debug} if debugMsg then msg('[AddToLeveledListByList] if StrWithinStr( '+slGlobal[x]+', '+tempString+' ) then begin');
			if StrWithinStr(slGlobal[x], tempString) then begin
				{Debug} if debugMsg then msg('[AddToLeveledListByList] slGlobal.Objects[x] := '+EditorID(ote(slGlobal.Objects[x])));
				if not slContains(slLL, StrPosCopy(slGlobal[x], '-//-', True)) then
					slLL.AddObject(StrPosCopy(slGlobal[x], '-//-', True), slGlobal.Objects[x]);
			end;
		end;
	end;
	{Debug} if debugMsg then msgList('[AddToLeveledListByList] slLL := ', slLL, ' );');
	// Add Masters
	msg('Adding Leveled List Masters (This may take a while)');
	AddMastersList(slLL, aPlugin);	
	for i := 0 to slLL.Count-1 do begin
		slMessage.Clear;
		slTemp.Clear;
		LLrecord := ote(slLL.Objects[i]);
		{Debug} if debugMsg then msg('[AddToLeveledListByList] LLrecord := '+EditorID(LLrecord));
		if not (Length(EditorID(LLrecord)) > 0) then Continue
		tempElement := ebn(LLrecord, 'Leveled List Entries');
		for x := 0 to Pred(LLec(LLrecord)) do begin
			tempRecord := ebi(tempElement, x);
			slTemp.AddObject(StrPosCopy(geev(tempRecord, 'LVLO\Reference'), ' ', True), StrToInt(geev(tempRecord, 'LVLO\Level'))); {Debug} if debugMsg then msg('[AddToLeveledListByList] slTemp.AddObject( '+StrPosCopy(geev(tempRecord, 'LVLO\Reference'), ' ', True)+', '+IntToStr(StrToInt(geev(tempRecord, 'LVLO\Level')))+' )');
		end; {Debug} if debugMsg then msgList('[AddToLeveledListByList] slTemp := ', slTemp, '');
		for x := 0 to bList.Count-1 do begin
			tempRecord := ote(bList.Objects[x]);
			tempInteger := -1;
			// Custom input from 'Add To Leveled List' menu		
			tempString := EditorID(LLrecord)+'-/Level/-'+EditorID(tempRecord);
			if slContains(slGlobal, tempString) then begin
				tempInteger := Integer(GetObject(tempString, slGlobal)); {Debug} if debugMsg then msg('[AddToLeveledListByList] Custom Level for '+EditorID(tempRecord)+' in '+EditorID(LLrecord)+' := '+IntToStr(tempInteger));
				slGlobal.Delete(slGlobal.IndexOf(tempString));
				slGlobal.Delete(slGlobal.IndexOf(EditorID(LLrecord)+'-//-'+EditorID(tempRecord)));				
				if (tempInteger = 0) then
					Continue;
			end;
			// Level from template
			if (tempInteger = -1) then
				if slContains(slTemp, bList[x]) then
					tempInteger := Integer(slTemp.Objects[slTemp.IndexOf(bList[x])]);
			{Debug} if debugMsg then msg('[AddToLeveledListByList] Level from '+EditorID(LLrecord)+' := '+IntToStr(tempInteger));
			if (tempInteger > -1) then begin
				// Detect Pre-Existing List or Create Override
				if not (LoadOrder = GetLoadOrder(GetFile(LLrecord))) then begin
					LLcopy := CopyRecordToFile(LLrecord, aPlugin, False, True);
				end else
					LLcopy := LLrecord;
				if (tempInteger = 0) then
					tempInteger := 1;
				if not slContains(slTemp, EditorID(tempRecord)) then
					addToLeveledList(LLcopy, tempRecord, tempInteger); {Debug} if debugMsg then msg('[AddToLeveledListByList] addToLeveledList( '+EditorID(LLcopy)+', '+EditorID(tempRecord)+', '+IntToStr(tempInteger)+' )');
				if not slContains(slMessage, EditorID(LLcopy)) then
					slMessage.Add(EditorID(LLcopy));
			end;
		end;
		if (slMessage.Count > 0) then
			msgList(EditorID(tempRecord)+' added to ', slMessage, '');
  end;
	
	// Finalize
	stopTime := Time;
	if ProcessTime then addProcessTime('AddToLeveledListByList', TimeBtwn(startTime, stopTime));
	slMessage.Free;
	slTemp.Free;
	slLL.Free;
end;

// Reassembles and then adds to all outfits containing inputRecord
function AddToOutfitAuto(templateRecord: IInterface; inputRecord: IInterface; aPlugin: IInterface): String;  
var
  tempLevelList, tempRecord, tempElement, masterLevelList, baseLevelList, subLevelList, vanillaLevelList, masterRecord, LVLIrecord, OTFTrecord, 
	OTFTitems, OTFTitem, OTFTcopy, LLentry, Record_edid: IInterface;
  debugMsg, tempBoolean, LightArmorBoolean, HeavyArmorBoolean: Boolean;  
  tempInteger, i, x, y, z, a, b: Integer;
  slTemp, slTempObject, slOutfit, slpair, slItem, slEnchantedList, slLevelList, slBlackList, slStringList, sl1, sl2: TStringList;
  tempString, String1, CommonString, OTFTrecord_edid: String;
begin
	// If the OTFT draws from a series of level lists assemble complete outfits from the items in those lists.
	// In most cases OTFT records draw from a level list for each piece of the outfit (e.g. boots level list, helmet level list, etc.)
	// Identifies and assembles based on BOD2 slots
	// This assembles a level list of the entire 'Steel Plate' outfit so that npcs will USUALLY spawn with a complete outfit instead of a hodge-podge drawn from various level lists
	// This does not edit or remove the original list.  The original entries remain intact as a single outfit within the complete list of outfits in masterLevelList.  
	// This means that, if there is 1 level list of the original outfit, 9 outfits are detected and assembled, and the script is adding 1 outfit, then you will StrToIntll have a 1/11 chance for a hodge-podge outfit <-- (1+9+1)
	// This is intended.  The goal is to improve the outfits, NEVER to remove existing entries or functionality (even if there is a lower chance to find those items).
	// The output should be A) A LL of selected Records B) LLs of outfit's original records C) A LL consiStrToIntng of the leftovers
// Begin debugMsg Section
  debugMsg := False; 
	
	// Initialize
	if not Assigned(slEnchantedList) then slEnchantedList := TStringList.Create else slEnchantedList.Clear;
	if not Assigned(slStringList) then slStringList := TStringList.Create else slStringList.Clear;
	if not Assigned(slTempObject) then slTempObject := TStringList.Create else slTempObject.Clear;
	if not Assigned(slBlacklist) then slBlacklist := TStringList.Create else slBlacklist.Clear;
	if not Assigned(slLevelList) then slLevelList := TStringList.Create else slLevelList.Clear;
	if not Assigned(slOutfit) then slOutfit := TStringList.Create else slOutfit.Clear;
	if not Assigned(slItem) then slItem := TStringList.Create else slItem.Clear;
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
	if not Assigned(slpair) then slpair := TStringList.Create else slpair.Clear;	
	if not Assigned(sl1) then sl1 := TStringList.Create else sl1.Clear;
	if not Assigned(sl2) then sl2 := TStringList.Create else sl2.Clear;	
	
	// Common Function Output
  masterRecord := MasterOrSelf(templateRecord);
  
////////////////////////////////////////////////////////////////////// OTFT RECORD DETECTION ///////////////////////////////////////////////////////////////////////////////////////	
	// Find valid OTFT records
  {Debug} if debugMsg then msg('[AddToOutfitAuto] Begin OTFT Record Detection');
  {Debug} if debugMsg then msg('[AddToOutfitAuto] for i := 0 to Pred(rbc(masterRecord)) :='+IntToStr(Pred(rbc(masterRecord)))+' do begin');
  for i := 0 to Pred(rbc(masterRecord)) do begin {Debug} if debugMsg then msg('[AddToOutfitAuto] LVLIrecord := '+EditorID(rbi(masterRecord, i)));
    slTempObject.Clear;
		LVLIrecord := rbi(masterRecord, i); {Debug} if debugMsg then msg('[AddToOutfitAuto] if (sig(LVLIrecord) := '+sig(LVLIrecord)+'= ''LVLI'') then begin');
		if (sig(LVLIrecord) = 'LVLI') then begin
			// Check for outfits that reference a list of items of a specific type (e.g. Boots, Gauntlets)
			while (sig(LVLIrecord) = 'LVLI') do begin			
				{Debug} if debugMsg then msg('[AddToOutfitAuto] for x := 0 to Pred(rbc(LVLIrecord)) := '+IntToStr(Pred(rbc(LVLIrecord)))+' do begin');
				for x := 0 to Pred(rbc(LVLIrecord)) do begin {Debug} if debugMsg then msg('[AddToOutfitAuto] OTFTrecord := rbi(LVLIrecord, x) := '+EditorID(rbi(LVLIrecord, x))+';');
					OTFTrecord := rbi(LVLIrecord, x); {Debug} if debugMsg then msg('[AddToOutfitAuto] if IsWinningOVerride(OTFTrecord) := '+BoolToStr(IsWinningOVerride(OTFTrecord))+' and (sig(OTFTrecord) := '+sig(OTFTrecord)+' = ''OTFT'') and StrWithinStr(EditorID(OTFTrecord), ''Armor'') := '+BoolToStr(StrWithinStr(EditorID(OTFTrecord), 'Armor'))+' then begin');
					if (sig(OTFTrecord) = 'OTFT') then begin
						if not IsWinningOverride(OTFTrecord) then Continue;
						// Check if OTFT references LVLI or is referenced more than once (to exclude outfits specifically for a single NPC)
						tempBoolean := False;
						if (rbc(OTFTrecord) > 1) then tempBoolean := True;
						if not tempBoolean then
							for y := 0 to Pred(ec(ebp(OTFTrecord, 'INAM'))) do
								if (sig(ebi(ebp(OTFTrecord, 'INAM'), y)) = 'LVLI') then
									tempBoolean := True;
						if tempBoolean and (sig(OTFTrecord) = 'OTFT') then
							if not slContains(slOutfit, EditorID(OTFTrecord)) then
								slOutfit.AddObject(EditorID(OTFTrecord), OTFTrecord);
					end else if (sig(LVLIrecord) = 'LVLI') then begin
						slTempObject.AddObject(EditorID(OTFTrecord), TObject(OTFTrecord));
					end;
				end;
				if (slTempObject.Count > 0) then begin
					LVLIrecord := ote(slTempObject.Objects[0]);
					slTempObject.Delete(0);
				end else begin
					Break;
				end;
			end;
		end else begin
			OTFTrecord := rbi(masterRecord, i); {Debug} if debugMsg then msg('[AddToOutfitAuto] if (sig(OTFTrecord) := '+sig(OTFTrecord)+'= ''LVLI'') then begin');
			if IsWinningOverride(OTFTrecord) and (sig(OTFTrecord) = 'OTFT') then
				if not slContains(slOutfit, EditorID(OTFTrecord)) then
					slOutfit.AddObject(EditorID(OTFTrecord), TObject(OTFTrecord));
		end;
  end;	
////////////////////////////////////////////////////////////////////// RESTRUCTURE OTFT RECORDS ///////////////////////////////////////////////////////////////////////////////////
    {Debug} if debugMsg then msg('[AddToOutfitAuto] FormID Detection Complete; Restructuring OTFT records');
    {Debug} if debugMsg then msgList('[AddToOutfitAuto] slOutfit := ', slOutfit, '');
		if not (slOutfit.Count > 0) then Continue;
    for i := 0 to slOutfit.Count-1 do begin
			OTFTcopy := nil;
			OTFTrecord := WinningOverride(ote(slOutfit.Objects[i])); {Debug} if debugMsg then msg('[AddToOutfitAuto] OTFTrecord := '+EditorID(OTFTrecord));
			OTFTrecord_edid := EditorID(OTFTrecord);
			// Add Masters
			AddMastersAuto(GetFile(OTFTrecord), aPlugin);
			OTFTitems := ebp(OTFTrecord, 'INAM');
			// Check for a previous script run
			if (ec(OTFTitems) = 1) and (sig(LinksTo(ebi(OTFTitems, 0))) = 'LVLI') then begin			
				{Debug} if debugMsg then msg('[AddToOutfitAuto] if tempInteger = 1 end else begin');
				masterLevelList := ebEDID(gbs(aPlugin, 'LVLI'), (OTFTrecord_edid+'_Master'));
				// This is for outfits with a single level list that can be used in a new masterLevelList
				if not Assigned(masterLevelList) then begin
					slTemp.CommaText := '"Use All"');
					masterLevelList := createLeveledList(aPlugin, OTFTrecord_edid+'_Master', slTemp, 0);		
					vanillaLevelList := LinksTo(ebi(OTFTitems, 0));
					for y := 0 to 3 do 
						addToLeveledList(masterLevelList, vanillaLevelList, 1);
					addToLeveledList(masterLevelList, inputRecord, 1);
				end;
			// This section restructures the outfit if this is the first time the script is editing this outfit
			end else begin
				// Preps the leveled lists
				{Debug} if debugMsg then msg('[AddToOutfitAuto] Creating a new vanillaLevelList and masterLevelList if not already present');
				// Check if aPlugin already has a leveled list created for vanillaLevelList
				vanillaLevelList := ebEDID(gbs(aPlugin, 'LVLI'), (OTFTrecord_edid+'_Original'));
				{Debug} if debugMsg and Assigned(vanillaLevelList) then msg('[AddToOutfitAuto] Pre-existing vanillaLevelList := '+EditorID(vanillaLevelList))
				{Debug}	else if debugMsg and not Assigned(vanillaLevelList) then msg('[AddToOutfitAuto] Pre-existing vanillaLevelList not detected');
				if not Assigned(vanillaLevelList) then begin
					if (ec(OTFTitems) > 1) then begin
						slTemp.CommaText := '"Use All"');
						vanillaLevelList := createLeveledList(aPlugin, OTFTrecord_edid+'_Original', slTemp, 0);
						for y := 0 to Pred(ec(OTFTitems)) do
							addToLeveledList(vanillaLevelList, LinksTo(ebi(OTFTitems, y)), 1);		
					end else 
						vanillaLevelList := ebi(OTFTitems, 0);
				end;
				// Create masterlevellist if not already present
				masterLevelList := ebEDID(gbs(aPlugin, 'LVLI'), (OTFTrecord_edid+'_Master'));
				{Debug} if debugMsg and Assigned(masterLevelList) then msg('[AddToOutfitAuto] Pre-existing masterLevelList := '+EditorID(masterLevelList))
				{Debug}	else if debugMsg and not Assigned(masterLevelList) then msg('[AddToOutfitAuto] Pre-existing masterLevelList not detected');		
				if not Assigned(masterLevelList) then begin
					slTemp.CommaText := '"Use All"');
					masterLevelList := createLeveledList(aPlugin, OTFTrecord_edid+'_Master', slTemp, 0);
					for y := 0 to 3 do 
						addToLeveledList(masterLevelList, vanillaLevelList, 1);		  
				end;
				{Debug} if debugMsg then msg('[AddToOutfitAuto] if not LLcontains( '+EditorID(masterLevellist)+', '+EditorID(inputRecord)+' ) := '+BoolToStr(LLcontains(masterLevelList, inputRecord))+' then begin');
				if not LLcontains(masterLevelList, inputRecord) then begin
					addToLeveledList(masterLevelList, inputRecord, 1);
					{Debug} if debugMsg then msg('[AddToOutfitAuto] addToLeveledList( '+EditorID(masterLevelList)+', '+EditorID(inputRecord)+', 1);');
				end;
			end;
			// This finishes restructuring the outfit so that new armor sets can be added as a whole set instead of piece by piece
			{Debug} if debugMsg then msg('[AddToOutfitAuto] if HasGroup(aPlugin, ''OTFT'') := '+BoolToStr(HasGroup(aPlugin, 'OTFT'))+' then');
			OTFTcopy := ebEDID(gbs(aPlugin, 'OTFT'), OTFTrecord_edid);
			{Debug} if debugMsg then msg('[AddToOutfitAuto] if not Assigned(OTFTcopy) := '+BoolToStr(Assigned(OTFTcopy))+' then begin');
			// If there is not already an override of OTFTcopy in aPlugin then create one
			if not Assigned(OTFTcopy) then begin
				{Debug} if debugMsg then msg('[AddToOutfitAuto] OTFTcopy := CopyRecordToFile('+OTFTrecord_edid+', '+GetFileName(aPlugin)+', False, True)');
				OTFTcopy := CopyRecordToFile(OTFTrecord, aPlugin, False, True);
			end;
  debugMsg := False;
// End debugMsg Section
////////////////////////////////////////////////////////////////////// ASSEMBLE OTFT FROM VANILLA ENTRIES - RECORD IDENTIFICATION /////////////////////////////////////////////////////////////////////////////
// Begin debugMsg Section
	debugMsg := False;	
			slEnchantedList.Clear;
			slBlacklist.Clear;
			slLevelList.Clear;
			slItem.Clear;
			slTemp.Clear;
			// Check if OTFT contains LVLI
			tempBoolean := False;
			// Checks if OTFT has a LVLI to be processed
			for x := 0 to Pred(ec(ebp(OTFTcopy, 'INAM'))) do begin
				if (sig(LinksTo(ebi(ebp(OTFTcopy, 'INAM'), x))) = 'LVLI') then begin
					tempBoolean := True;
					Break;
				end;
			end;
			{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] '+EditorID(OTFTcopy)+' contains LVLI := '+BoolToStr(tempBoolean));
			// Get a complete list of all items and enchanted sets
			{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Get a complete list of all items and enchanted sets');
			if tempBoolean then begin
				for x := 0 to Pred(ec(ebp(OTFTcopy, 'INAM'))) do begin
					// Commonly used functions; This is just to reduce the number of complicated functions that are called (and therefore reduce processing time)
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Commonly used functions');
					tempRecord := WinningOverride(LinksTo(ebi(ebp(OTFTcopy, 'INAM'), x)));
					Record_edid := EditorID(tempRecord);
					// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] tempRecord := '+EditorID(tempRecord));
					tempBoolean := False;
					// Check lists for an identical item
					if slContains(slEnchantedList, Record_edid) or slContains(slLevelList, Record_edid) or slContains(slItem, Record_edid) then
						tempBoolean := True;
					// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] ItemAlreadyAdded := '+BoolToStr(tempBoolean));
					if not tempBoolean then begin
						if (sig(tempRecord) = 'LVLI') then begin
							if StrWithinStr(EditorID(tempRecord), 'Ench') then begin								
								if not slContains(slEnchantedList, Record_edid) then begin
									// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slEnchantedList.Add( '+EditorID(tempRecord)+' );');
									slEnchantedList.AddObject(Record_edid, TObject(tempRecord));
								end;
							end else begin	
								if not slContains(slLevelList, Record_edid) then begin
									// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slTemp.Add(EditorID( '+EditorID(tempRecord)+' ));');
									slLevelList.AddObject(Record_edid, TObject(tempRecord));	
								end;
							end;
						end else begin	
							if not slContains(slItem, Record_edid) then begin
								// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slItem.Add(EditorID( '+EditorID(tempRecord)+' ));');
								slItem.AddObject(Record_edid, TObject(tempRecord));	
							end;
						end;
					end;
					// Leveled lists are often nested multiple times. This 'while' loop adds all their entries to a single list
					{Debug} if debugMsg and (slLevelList.Count > 0) then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Leveled lists are often nested multiple times. This ''while'' loop adds all their entries to a single list');
					{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slLevelList := ', slLevelList, '');
					while (slLevelList.Count > 0) do begin											
						for y := 0 to Pred(LLec(ote(slLevelList.Objects[0]))) do begin
							tempRecord := WinningOverride(LLebi(ote(slLevelList.Objects[0]), y));
							Record_edid := EditorID(tempRecord);
							if not (Length(EditorID(tempRecord)) > 0) then Continue;
							// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] tempRecord := '+Record_edid);
							if (sig(tempRecord) = 'LVLI') then begin
								if StrWithinStr(EditorID(tempRecord), 'Ench') then begin
									if not slContains(slEnchantedList, Record_edid) then begin
										// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slEnchantedList.Add(EditorID( '+Record_edid+' ));');
										slEnchantedList.AddObject(Record_edid, TObject(tempRecord));
									end;
								end else begin
									if not slContains(slLevelList, Record_edid) then begin
										// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slTempObject.Add(EditorID( '+Record_edid+' ));');
										slTempObject.AddObject(Record_edid, TObject(tempRecord));
									end;
								end;
							end else begin
								if not slContains(slItem, Record_edid) then begin
									// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slItem.Add(EditorID( '+Record_edid+' ));');
									slItem.AddObject(Record_edid, TObject(tempRecord));
								end;
							end;
						end;
						// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slLevelList.Delete( '+slLevelList[0]+' );');
						slLevelList.Delete(0);
						if (slLevelList.Count = 0) then begin
						  for z := 0 to slTempObject.Count-1 do begin
								if not slContains(slLevelList, slTempObject[z]) then begin
									// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slLevelList.Add( '+slTempObject[z]+' );');
									slLevelList.AddObject(slTempObject[z], ote(slTempObject.Objects[z]));
								end;
							end;
							slTempObject.Clear;
						end;
						if (slLevelList.Count = -1) then Break;
					end;					
				end;
				// If there are enchanted lists, replace them with a 'template' record.  For the sake of simplicity it will be replaced with the enchanted list later
				{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] If there are enchanted lists, make sure the original record is in the items list.  For the sake of simplicity it will be replaced with the enchanted list later');
				for x := 0 to slEnchantedList.Count-1 do begin
					// Grab the template for the enchanted list.  These are also nested often
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] tempRecord := '+EditorID(WinningOverride(ote(slEnchantedList.Objects[x]))));
					tempRecord := WinningOverride(ote(slEnchantedList.Objects[x]));
					while (sig(tempRecord) = 'LVLI') do begin
						tempRecord := LLebi(tempRecord, 0);
						{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] tempRecord := '+EditorID(tempRecord));
					end;
					// Check the list for the template item
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Check the list for the template item');
					if not slContains(slItem, EditorID(GetEnchTemplate(tempRecord))) then begin
						// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slItem.Add( '+EditorID(tempRecord)+' );');
						slItem.AddObject(EditorID(GetEnchTemplate(tempRecord)), TObject(GetEnchTemplate(tempRecord)));
					end;
				end;
				// This is the main section where similiar items are added to an outfit
				{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] This is the main section where similiar items are added to an outfit');
				{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slItem := ', slItem, '');
				for x := 0 to slItem.Count-1 do begin				
					slStringList.Clear;
					// Exclude entries already added to lists by this script
					if slContains(slBlacklist, slItem[x]) then Continue
					// Delete common junk words
					slTemp.CommaText := 'Mask, Bracers, Armor, Helmet, Hood, Crown, Shield, Buckler, Cuirass, Greaves, Boots, Gloves, Gauntlets, Hood';	
					slStringList.CommaText := full(WinningOverride(ote(slItem.Objects[x])));
					{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slStringList := ', slStringList, '');				
					for y := 0 to slTemp.Count-1 do
						if slContains(slStringList, slTemp[y]) then
							slStringList.Delete(slStringList.IndexOf(slTemp[y]));					
					if slStringList.Count = 0 then Continue;
					slTempObject.Clear;
					// Search all slItem records for similiar words to the current record with decreasing levels of precision
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Search all slItem records for similiar words to the current record with decreasing levels of precision');
					{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slStringList := ', slStringList, '');
					for y := 0 to slStringList.Count-1 do begin
						CommonString := nil;
						for z := slStringList.Count-1 downto 0 do begin
							CommonString := Trim(CommonString+' '+slStringList[z]);
							// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] [Decreasing Precision] CommonString := '+CommonString);
						end;	
						for z := 0 to slItem.Count-1 do
							if StrWithinStr(full(ote(slItem.Objects[z])), CommonString) then
								if not (z = x) then
									if not slContains(slTempObject, slItem[z]) then
										slTempObject.AddObject(slItem[z], slItem.Objects[z]);
						if (slTempObject.Count > 1) then Break;
					end;	
					if not (slTempObject.Count > 1) then Continue;
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Decreasing Precision Output := '+CommonString);
					{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slTempObject := ', slTempObject, '');
	debugMsg := False;
// End debugMsg section	
////////////////////////////////////////////////////////////////////// ASSEMBLE OTFT FROM VANILLA ENTRIES - OUTFIT GENERATION /////////////////////////////////////////////////////////////////////////////	
// Begin debugMsg section
	debugMsg := False;
					// Create and fill a level list for the outfit if one does not exist
					// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Create and fill a level list for the outfit');	
					tempString := ('LLOutfit_'+RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(MasterOrSelf(tempRecord)))))+'_'+RemoveSpaces(CommonString));
					tempLevelList := ebEDID(gbs(aPlugin, 'LVLI'), tempString);
					{Debug} if debugMsg and Assigned(tempLevelList) then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] tempLevelList already exists; tempLevelList := '+EditorID(tempLevelList));
					if not Assigned(tempLevelList) then begin
						{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] tempLevelList unassigned; Creating '+tempString);
						slTemp.CommaText := '"Use All"');
						tempLevelList := createLeveledList(aPlugin, tempString, slTemp, 0);
						{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Begin vanilla outfit generation; slTempObject := ', slTempObject, '');
						for y := 0 to slTempObject.Count-1 do begin
							tempRecord := ote(slTempObject.Objects[y]);
							Record_edid := slTempObject[y];
							// Check to see if the record was used in a previous loop
							// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check to see if the record was used in a previous loop');
							if slContains(slBlacklist, slTempObject[y]) then Continue;
							// Check if a subLevelList is needed
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check if a subLevelList is needed for '+Record_edid);
							sl1.Clear;
							sl2.Clear;
							tempBoolean := False;
							// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] slGetFlagValues( '+slTempObject[y]+', '+GetElementType+' , ''First Person Flags''), sl1, False);');
							slGetFlagValues(tempRecord, sl1, False);
							{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] sl1 := ', sl1, '');
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check for items that don''t use a primary or vanilla slot');
							// Check for items that don't use a primary or vanilla slot; All of these items get subLevelLists in order to implement a percent chance none
							sl2.CommaText := '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
							for z := 0 to sl2.Count-1 do
								if slContains(sl1, sl2[z]) then
									tempBoolean := True;
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Primary slot check := '+BoolToStr(tempBoolean));
							// Check for common primary slot keywords; This is primarily for to account for mods that change the slot layout of helmets for compatability reasons
							sl2.CommaText := 'Boots, Helmet, Shield, Cuirass, Gauntlets, Shield, Hands, Head, Body, Gloves, Bracers, Ring, Robes, Hood, Mask';
							for z := 0 to sl2.Count-1 do
								if StrWithinStr(Record_edid, sl2[z]) or StrWithinStr(full(tempRecord), sl2[z]) then
									tempBoolean := True;
							tempBoolean := Flip(tempBoolean);
							// Check for subLevelLists' slots							
							if not tempBoolean then begin
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check for subLevelLists'' slots');
								for z := 0 to Pred(LLec(tempLevelList)) do begin
									if (Signature(LLebi(tempLevelList, z)) = 'LVLI') then begin
										for a := 0 to sl1.Count-1 do begin
											if StrWithinStr(EditorID(LLebi(tempLevelList, z)), sl1[a]) then begin
												tempBoolean := True;
												{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] subLevelList check := '+BoolToStr(tempBoolean));
												{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] StrWithinStr( '+EditorID(LLebi(tempLevelList, z))+', '+sl1[a]+' )');
												Break;
											end;
										end;
									end;
								end;	
							end;							
							// Check for items that use the same slot						
							if not tempBoolean then begin
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check for items that use the same slot');
								for z := 0 to slTempObject.Count-1 do begin
									if (z = y) then Continue;
									sl2.Clear;								
									slGetFlagValues(tempRecord, sl2, False);
									// {Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] sl1 := ', sl1, '');
									// {Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] sl2 := ', sl2, '');
									for a := 0 to sl1.Count-1 do begin
										if slContains(sl2, sl1[a]) then begin
											tempBoolean := True;
											{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] same slot check := '+BoolToStr(tempBoolean));
											// {Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slContains( ',sl2, ', '+sl1[a]+' )');
											Break;
										end;
									end;
								end;
							end;
							// Create subLevelList
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Create subLevelList for '+slTempObject[y]+' := '+BoolToStr(tempBoolean));
							if tempBoolean then begin
								// Get pre-existing list or create a new one
								String1 := nil;
								for z := 0 to sl1.Count-1 do
										String1 := Trim(String1+' '+sl1[z]);
								// Check for pre-existing subLevelList
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check for pre-existing subLevelList');
								subLevelList := ebEDID(gbs(aPlugin, 'LVLI'), ('LLOutfit_'+RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(MasterOrSelf(tempRecord)))))+'_'+RemoveSpaces(CommonString)+'_SubList_(BOD2: '+String1+')'));
								if Assigned(subLevelList) then begin
									{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Pre-existing sublist '+EditorID(subLevelList)+' detected; if not LLcontains( '+EditorID(tempLevelList)+', '+Record_edid+' ) := '+BoolToStr(LLcontains(tempLevelList, tempRecord))+' then begin');
									if not LLcontains(subLevelList, tempRecord) then begin
										addToLeveledList(subLevelList, tempRecord, 1);
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] addToLeveledList( '+EditorID(tempLevelList)+', '+slTempObject[y]+', 1);');											
									end;
									// Blacklist used items
									if not slContains(slBlacklist, Record_edid) then
										slBlackList.Add(Record_edid);
								end;
								// Create subLevelList if not already assigned
								if not Assigned(subLevelList) then begin
									{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Creating new subLevelList');
									slTemp.CommaText := '"Calculate from all levels <= player''s level", "Calculate for each item in count"';
									subLevelList := createLeveledList(aPlugin, ('LLOutfit_'+RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile((MasterOrSelf(tempRecord))))))+'_'+RemoveSpaces(CommonString)+'_SubList_(BOD2: '+String1+')'), slTemp, 0);
									{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] addToLeveledList( '+EditorID(subLevelList)+', '+Record_edid+', 1);');
									addToLeveledList(subLevelList, tempRecord, 1);
									// Items in non-primary or non-vanilla slots get an 80 percent chance none; This should include scarves, necklaces, etc.
									sl2.Clear;
									sl2.CommaText := '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
									tempBoolean := False;
									for z := 0 to sl2.Count-1 do
										if StrWithinStr(String1, sl2[z]) then
											tempBoolean := True;
									// Check for common primary slot keywords; This is primarily for to account for mods that change the slot layout of helmets for compatability reasons
									sl2.CommaText := 'Boots, Helmet, Shield, Cuirass, Gauntlets, Shield, Hands, Head, Body, Gloves, Bracers, Ring, Robes, Hood, Mask';
									for z := 0 to sl2.Count-1 do
										if StrWithinStr(Record_edid, sl2[z]) or StrWithinStr(full(tempRecord), sl2[z]) then
											tempBoolean := True;
									if not tempBoolean then 
										senv(subLevelList, 'LVLD', 80); // Percent chance none
									// Blacklist used items
									if not slContains(slBlackList, Record_edid) then
										slBlackList.Add(Record_edid);										
								end;
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Identify Records by BOD2');
								// Identify Records by BOD2				
								for z := 0 to slTempObject.Count-1 do begin
									tempElement := ote(slTempObject.Objects[z]);
									sl2.Clear;							
									slGetFlagValues(tempElement, sl2, False);
									tempInteger := 0;
									for a := 0 to sl1.Count-1 do begin
										for b := 0 to sl2.Count-1 do begin
											if StrWithinStr(sl2[b], sl1[a]) then begin
												// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] StrWithinStr( '+sl2[b]+', '+sl1[a]+' )');
												tempInteger := tempInteger+1;		
											end;
										end;
									end; 
									if (tempInteger = sl1.Count) then begin
										// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] if not LLcontains( '+EditorID(subLevelList)+', '+slTempObject[z]+' ) := '+BoolToStr(LLcontains(subLevelList, tempElement))+' then begin');
										if not LLcontains(subLevelList, tempElement) then begin
											{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] addToLeveledList( '+EditorID(subLevelList)+', '+slTempObject[z]+', 1);');
											addToLeveledList(subLevelList, tempElement, 1);
										end;
										// Blacklist used items
										if not slContains(slBlackList, slTempObject[z]) then
											slBlackList.Add(slTempObject[z]);
									end;
								end;							
								// Check if the leveled list contains a template for an enchanted list
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check if the leveled list contains a template for an enchanted list');
								for a := 0 to slEnchantedList.Count-1 do begin
									for b := 0 to Pred(LLec(subLevelList)) do begin
										tempElement := ote(slEnchantedList.Objects[a]);
										if ee(LLebi(tempElement, 0), 'CNAM') then begin
											if (EditorID(LinksTo(ElementBySignature(LLebi(tempElement, 0), 'CNAM'))) = EditorID(LLebi(subLevelList, b))) then begin
												{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] LLreplace( '+EditorID(subLevelList)+', '+EditorID(LLebi(subLevelList, b))+', '+slEnchantedList[a]+' );');
												if not LLcontains(tempLevelList, tempElement) then
													LLreplace(tempLevelList, LLebi(subLevelList, b), tempElement);
											end;
										end else if ee(LLebi(tempElement, 0), 'TNAM') then begin
											if (EditorID(LinksTo(ElementBySignature(LLebi(tempElement, 0), 'TNAM'))) = EditorID(LLebi(subLevelList, b))) then begin
												{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] LLreplace( '+EditorID(subLevelList)+', '+EditorID(LLebi(subLevelList, b))+', '+slEnchantedList[a]+' );');
												if not LLcontains(tempLevelList, tempElement) then
													LLreplace(tempLevelList, LLebi(subLevelList, b), tempElement);
											end;
										end;
									end;
								end;
								// Check if another leveled list also covers the same BOD2 parts
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check if another leveled list also covers the same BOD2 parts');
								tempBoolean := False;
								for z := 0 to Pred(LLec(tempLevelList)) do begin
									if (Signature(LLebi(tempLevelList, z)) = 'LVLI') then begin
										for a := 0 to sl1.Count-1 do begin
											if StrWithinStr(EditorID(LLebi(tempLevelList, z)), sl1[a]) then begin
												String1 := StrPosCopy(EditorID(LLebi(tempLevelList, z)), '(', False);
												String1 := StrPosCopy(String1, ')', True);
												sl2.CommaText := String1;
												if (sl1.Count < sl2.Count) then begin
													if not LLcontains(LLebi(tempLevelList, z), subLevelList) then begin
														addToLeveledList(LLebi(tempLevelList, z), subLevelList, 1);
														tempBoolean := True;
														// Removes duplicate elements in the leveled list one level above
														// Example: A sublist for slot 40 is created and contains all items that occupy slot 40.  There is already a list in tempLevelList for items with slot 40 and slot 42.
														// This removes items that have slot bot slot 40 and slot 42, leaving only slot 40 items in the sublist
														for b := 0 to Pred(LLec(tempLevelList)) do
															if LLcontains(subLevelList, LLebi(tempLevelList, b)) then 
																LLremove(subLevelList, LLebi(tempLevelList, b));
														// Sub-sublists don't need a percent chance none
														if ElementExists(subLevelList, 'LVLD') then
															Remove(ElementBySignature(subLevelList, 'LVLD'));
													end;
												end else if (sl1.Count > sl2.Count) then begin
													LLreplace(tempLevelList, LLebi(tempLevelList, z), subLevelList);
													if not LLcontains(subLevelList, LLebi(tempLevelList, z)) then begin
														{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] addToLeveledList( '+EditorID(subLevelList)+', '+EditorID(LLebi(tempLevelList, z))+', 1);');
														addToLeveledList(subLevelList, LLebi(tempLevelList, z), 1);
														tempBoolean := True;
														// Removes duplicate elements in the leveled list one level above
														for b := 0 to Pred(LLec(subLevelList)) do
															if LLcontains(tempLevelList, LLebi(tempLevelList, b)) then 
																LLremove(tempLevelList, LLebi(tempLevelList, b));	
														// Sub-sublists don't need a percent chance none
														if ElementExists(tempLevelList, 'LVLD') then
															Remove(ElementBySignature(TempLevelList, 'LVLD'));																
													end;
												end;
											end;
										end;
									end;
								end;
								if not tempBoolean and not LLcontains(tempLevelList, subLevelList) then
									addToLeveledList(tempLevelList, subLevelList, 1);
							end else begin
								if not LLcontains(tempLevelList, tempRecord) then
									addToLeveledList(tempLevelList, tempRecord, 1);
								// Blacklist used items
								if not slContains(slBlackList, slTempObject[y]) then
									slBlacklist.Add(slTempObject[y]);
							end;
						end;	
						// Check if the leveled list contains a template for an enchanted list
						{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check if the leveled list contains a template for an enchanted list');
						for z := 0 to slEnchantedList.Count-1 do begin
							for a := 0 to Pred(LLec(tempLevelList)) do begin
								tempElement := ote(slEnchantedList.Objects[z]);
								if ee(LLebi(tempElement, 0), 'CNAM') then begin
									if EditorID(LinksTo(ElementBySignature(LLebi(tempElement, 0), 'CNAM'))) = EditorID(LLebi(subLevelList, b)) then begin
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] LLreplace( '+EditorID(tempLevelList)+', '+EditorID(LLebi(subLevelList, b))+', '+slEnchantedList[z]+' );');
										if not LLcontains(tempLevelList, tempElement)) then
											LLreplace(tempLevelList, LLebi(subLevelList, b), tempElement);
									end;
								end else if ee(LLebi(tempElement, 0), 'TNAM') then begin
									if EditorID(LinksTo(ElementBySignature(LLebi(tempElement, 0), 'TNAM'))) = EditorID(LLebi(subLevelList, b)) then begin
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] LLreplace( '+EditorID(tempLevelList)+', '+EditorID(LLebi(subLevelList, b))+', '+slEnchantedList[z]+' );');
										if not LLcontains(tempLevelList, tempElement) then
											LLreplace(tempLevelList, LLebi(subLevelList, b), tempElement);
									end;
								end;
							end;
						end;
						// Remove outfits with no primary vanilla BOD2 slots
						{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check '+EditorID(tempLevelList)+' for primary vanilla BOD2 slots');
						tempBoolean := False;
						for z := 0 to Pred(LLec(tempLevelList)) do begin
							// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] LLebi(tempLevelList, z) := '+EditorID(LLebi(tempLevelList, z)));
							// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] sig(LLebi(tempLevelList, z)) := '+sig(LLebi(tempLevelList, z)));
							if (sig(LLebi(tempLevelList, z)) = 'LVLI') then begin
								// Check sublist
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check if '+EditorID(tempLevelList)+' sublist '+EditorID(LLebi(tempLevelList, z))+' is a script sublist');
								// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] if StrWithinStr(EditorID( '+EditorID(LLebi(tempLevelList, z))+', ''BOD2'') then begin');
								if StrWithinStr(EditorID(LLebi(tempLevelList, z)), 'BOD2') or StrWithinStr(EditorID(LLebi(tempLevelList, z)), 'Ench') then begin
									sl1.Clear;
									tempString := Trim(StrPosCopy(EditorID(Llebi(tempLevelList, z)), ':', False));
									tempString := Trim(StrPosCopy(tempString, ')', True));
									sl1.CommaText := tempString;
									sl2.Clear;
									sl2.CommaText := '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
									// This 'if' prevents tempLevelList deletion if the BOD2 list doesn't generate correctly
									if (sl1.Count > 0) then begin
										for a := 0 to sl1.Count-1 do
											if slContains(sl2, sl1[a]) then
												tempBoolean := True;
									end else begin
										msg('[ERROR] '+EditorID(LLebi(tempLevelList, z))+' expected BOD2 did not generate correctly - [AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation]');
										tempBoolean := True;
									end;
								end;
							end else begin
								// Check normal item
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check '+EditorID(tempLevelList)+' for a normal item');
								sl1.Clear;							
								slGetFlagValues(LLebi(tempLevelList, z), sl1, False);
								sl2.CommaText := '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
								// This 'if' prevents tempLevelList deletion if the BOD2 list doesn't generate correctly
								if (sl1.Count > 0) then begin
									for a := 0 to sl1.Count-1 do
										if slContains(sl2, sl1[a]) then
											tempBoolean := True;
								end else begin
									msg('[ERROR] '+EditorID(LLebi(tempLevelList, z))+' expected BOD2 did not generate correctly - [AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation]');
									tempBoolean := True;
								end;
							end;
						end;
						if not tempBoolean then begin
							sl1.Clear;
							{Debug} if debugMsg then for z := 0 to Pred(LLec(tempLevelList)) do sl1.Add(EditorID(LLebi(tempLevelList, z)));
							{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] '+EditorID(tempLevelList)+' := ', sl1, '');
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Remove( '+EditorID(tempLevelList)+' )');
							Remove(tempLevelList);
							Continue;
						end else begin
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] '+EditorID(tempLevelList)+' does contain primary vanilla BOD2 slots');
						end;						
					end;
	debugMsg := False;
// End debugMsg section	
////////////////////////////////////////////////////////////////////// ASSEMBLE OTFT FROM VANILLA ENTRIES - OUTFIT VARIATIONS /////////////////////////////////////////////////////////////////////////////	
// Begin debugMsg section
	debugMsg := False;	
					if Assigned(tempLevelList) then begin
						// If an outfit Master list requires additional BOD2 slots, make a variant of tempLevelList 
						for z := 0 to Pred(ec(ElementBySignature(OTFTcopy, 'INAM'))) do begin
							sl1.Clear;
							sl2.Clear;
							tempRecord := WinningOverride(LinksTo(ebi(ebp(OTFTcopy, 'INAM'), z)));
							// Get a list of expected BOD2 slots
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Get a list of expected BOD2 slots for '+EditorID(tempRecord));
							if (sig(tempRecord) = 'LVLI') then begin
								for a := 0 to Pred(LLec(tempRecord)) do begin
									if (sig(LLebi(tempRecord, a)) = 'LVLI') then begin
										sl2.AddObject(EditorID(LLebi(tempRecord, z)), TObject(LLebi(tempRecord, z)));
									end else begin
										slGetFlagValues(LLebi(tempRecord, a), sl1, False);
									end;
								end;
								// This is a recursive check for nested leveled lists
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] This is a recursive check for nested leveled lists');
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] sl2.Count := '+IntToStr(sl2.Count));
								if (sl2.Count > 0) then begin
									While (sl2.Count > 0) do begin
										tempElement := ote(sl2.Objects[0]);
										if (LLec(tempElement) = 0) then begin
											sl2.Delete(0);
											Continue;
										end;
										// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] for a := 0 to '+IntToStr(Pred(LLec(tempElement)))+' do begin');
										for a := 0 to Pred(LLec(tempElement)) do begin
											// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] if ( '+sig(LLebi(tempElement, a))+' = ''LVLI'') then begin');
											if (sig(LLebi(tempElement, a)) = 'LVLI') then begin
												// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] if not slContains( sl1, '+EditorID(LLebi(tempElement, a))+' ) then');
												if not slContains(sl1, EditorID(LLebi(tempElement, a))) then begin
													// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] sl2.Add( '+EditorID(LLebi(tempElement, a))+' );');
													sl2.AddObject(EditorID(LLebi(tempElement, a)), TObject(LLebi(tempElement, a)));
												end;
											end else begin
												slGetFlagValues(LLebi(tempElement, a), sl1, False);											
											end;	
										end;
										sl2.Delete(0);
										// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] sl2.Delete( '+sl2[0]+' )');
									end;
								end;
							end else begin
								sl1.Clear;		
								slGetFlagValues(tempRecord, sl1, False);
							end;
							// Check to see if the outfit contains any item or sublist covering these BOD2 slots
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Check to see if the outfit contains any item or sublist covering these BOD2 slots');
							if (sl1.Count > 0) then begin
								tempBoolean := False;
								for z := 0 to Pred(LLec(tempLevelList)) do begin
									if (sig(LLebi(tempLevelList, z)) = 'LVLI') then begin
										// Check sublist
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Check if '+EditorID(tempLevelList)+' sublist '+EditorID(LLebi(tempLevelList, z))+' is a script sublist');
										if StrWithinStr(EditorID(LLebi(tempLevelList, z)), 'BOD2') then begin
											sl2.Clear;
											tempString := Trim(StrPosCopy(EditorID(Llebi(tempLevelList, z)), ':', False));
											tempString := Trim(StrPosCopy(tempString, ')', True));											
											sl2.CommaText := tempString;
											// This 'if' prevents tempLevelList deletion if the BOD2 list doesn't generate correctly
											if (sl1.Count > 0) then begin
												for a := 0 to sl1.Count-1 do
													if slContains(sl2, sl1[a]) then
														tempBoolean := True;
											end else begin
												msg('[ERROR] '+EditorID(tempRecord)+' expected BOD2 did not generate correctly - [AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations]');
												tempBoolean := True;
											end;
											{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Check '+EditorID(LLebi(tempLevelList, z))+' sublist for ', sl1, ' := '+BoolToStr(tempBoolean));										
										// Check enchanted list
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Check if '+EditorID(LLebi(tempLevelList, z))+' is an enchanted list');
										end;
									end else begin
										// Check normal item
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Check normal item');
										sl2.Clear;							
										slGetFlagValues(LLebi(tempLevelList, z), sl2, False);
										{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Checking for '+EditorID(tempRecord)+' BOD2 sl1 := ', sl1, '');
										{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Checking for '+EditorID(LLebi(tempLevelList, z))+' BOD2 sl2 := ', sl2, '');	
										// This 'if' prevents tempLevelList deletion if the BOD2 list doesn't generate correctly
										if (sl1.Count > 0) then begin
											for a := 0 to sl1.Count-1 do
												if slContains(sl2, sl1[a]) then
													tempBoolean := True;
										end else begin
											msg('[ERROR] '+EditorID(tempRecord)+' expected BOD2 did not generate correctly - [AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations]');
											tempBoolean := True;
										end;
									end;
								end;
								// If the generated outfit does not cover all the BOD2 slots the master outfit contains, create a copy and use that instead
								// Example: Leather outfits often generate with only a cuirass.  
								// In this case, if an outfit consists of LItemBanditHelmet, LItemBanditCuirass, and LItemBanditBoots (a common setup)
								// a variant of the leveled list with just the leather cuirass would generate containing the leather cuirass, LItemBanditHelmet, and LItemBanditBoots
								if not tempBoolean then begin
									// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] if StrEndsWith( '+EditorID(tempLevelList)+', '+EditorID(OTFTcopy)+' ) then begin');
									if StrEndsWith(EditorID(tempLevelList), EditorID(OTFTcopy)) then begin
										subLevellist := tempLevelList
									end else begin
										subLevelList := ebEDID(gbs(aPlugin, 'LVLI'), EditorID(tempLevelList)+'_'+EditorID(OTFTcopy));
									end;
									if not Assigned(subLevelList) then begin
										subLevelList := CopyRecordToFile(tempLevelList, aPlugin, True, True);
										SetElementEditValues(subLevelList, 'EDID', EditorID(tempLevelList)+'_'+EditorID(OTFTcopy));
									end;
									if Assigned(subLevelList) then
										tempLevelList := subLevelList;
									if not LLcontains(tempLevelList, tempRecord) then
										addToLeveledList(tempLevelList, tempRecord, 1);
								end;
							end;
						end;
						// Add tempLevelList to masterLevelList if it is not already present
						{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] if not LLcontains( '+EditorID(masterLevelList)+', '+EditorID(tempLevelList)+' ) := '+BoolToStr(LLcontains(masterLevelList, tempLevelList))+' then begin');
						if not LLcontains(masterLevelList, tempLevelList) then begin
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] addToLeveledList( '+EditorID(masterLevelList)+', '+EditorID(tempLevelList)+', 1);');
							addToLeveledList(masterLevelList, tempLevelList, 1);
						end;
					end;
					// Blacklist used items
					if not slContains(slBlacklist, slItem[x]) then
						slBlacklist.Add(slItem[x]);					
				end;
			end;
      debugMsg := False;
// End debugMsg Section
////////////////////////////////////////////////////////////////////// SPECIFIC OTFT TYPES - PRE-CHECK ////////////////////////////////////////////////////////////////////////////////
// Begin debugMsg Section
      debugMsg := False;			
			// Checks for integer-keyword pairs (e.g. Shield20 becomes 20=Shield)	
			// This checks each OTFT item for an integer-keyword pair (e.g. Shield20 becomes 20=Shield)
			slTemp.Clear;
			slpair.Clear;			
			slTemp.CommaText := 'Bracers, Helmet, Hood, Crown, Shield, Buckler, Cuirass, Greaves, Boots, Gloves, Gauntlets';	
			tempBoolean := False;
			for x := 0 to Pred(ec(ebp(OTFTcopy, 'INAM'))) do begin 
				tempRecord := LinksTo(ebi(ebp(OTFTcopy, 'INAM'), x)); {Debug} if debugMsg then msg('[AddToOutfitAuto] [Pre-Check] tempRecord := '+EditorID(tempRecord));	
				{Debug} if debugMsg then msg('[AddToOutfitAuto] [Pre-Check] if sig( '+EditorID(tempRecord)+' ) := '+sig(tempRecord)+' = ''LVLI'' then begin');
				if (sig(tempRecord) = 'LVLI') then begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Pre-Check] if (IntWithinStr(EditorID(tempRecord)) := '+IntToStr(IntWithinStr(EditorID(tempRecord)))+' ) <> -1) then begin');
					if (IntWithinStr(EditorID(tempRecord)) <> -1) then begin
						for y := 0 to slTemp.Count-1 do begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Pre-Check] if StrWithinStr( '+EditorID(tempRecord)+', '+slTemp[y]+' ) then begin');
							if StrWithinStr(EditorID(tempRecord), slTemp[y]) then begin
								for z := 0 to slpair.Count-1 do
								  if slpair.Names[z] = slTemp[y] then
									  tempBoolean := True;
							  if not tempBoolean then begin
								  slpair.Add(slAddValue(IntToStr(IntWithinStr(EditorID(tempRecord))), slTemp[y]));								
									{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Pre-Check] slpair := ', slpair, '');
								end;
							end;
						end;
					end;
				end;
			end;
			// This checks the OTFT EditorID for an integer-keyword pair
			if (IntWithinStr(EditorID(OTFTcopy)) <> -1) then begin 
				for y := 0 to slTemp.Count-1 do begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Pre-Check] if ( IntWithinStr(EditorID(OTFTcopy) := '+IntToStr(IntWithinStr(EditorID(OTFTcopy)))+' <> -1) then begin');
					if (IntWithinStr(EditorID(OTFTcopy)) <> -1) then begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Pre-Check] if StrWithinStr( '+EditorID(OTFTcopy)+', '+slTemp[y]+' ) then begin');
						if StrWithinStr(EditorID(OTFTcopy), slTemp[y]) then begin 
							for z := 0 to slpair.Count-1 do
								if slpair.Names[z] = slTemp[y] then
									tempBoolean := True;
							if not tempBoolean then begin
								slpair.Add(slAddValue(IntToStr(IntWithinStr(EditorID(OTFTcopy))), slTemp[y]));		
								{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Pre-Check] slpair := ', slpair, '');
							end;
						end;
					end;
				end;			
			end;
////////////////////////////////////////////////////////////////////// SPECIFIC OTFT TYPES - INTEGER ////////////////////////////////////////////////////////////////////////////////
			if (slPair.Count > 0) then begin {Debug} if debugMsg then msgList('[AddToOutfitAuto] [Integer] slpair := ', slPair, '');
				// This is checking the input level list for keywords similiar to the identified keyword
				// This is ghetto fuzzy logic.  Example: If the pre-check identifies 'Gauntlets' then this
				// section would check the input record for entries containing 'Gauntlets, Gloves';				
				tempBoolean := False;
				{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Integer] slpair := ', slpair, '');
				for x := 0 to slpair.Count-1 do begin			
					{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Integer] slFuzzyItem( '+slpair.Names[x]+', ', slTemp, ' )');
					// Check for inputRecord for all keywords related to the keyword detected in the OTFT 'EditorID' or 'INAM' items
					slTemp.Clear;
					slFuzzyItem(slpair.Names[x], slTemp); {Debug} if debugMsg and (x = 0) then msgList('[AddToOutfitAuto] [Integer] slTemp := ', slTemp, '');
					tempLevelList := nil;
					for y := 0 to Pred(LLec(inputRecord)) do begin
						tempRecord := LLebi(inputRecord, y); {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] tempRecord := '+EditorID(tempRecord));
						for z := 0 to slTemp.Count-1 do begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] if StrWithinStr( '+EditorID(tempRecord)+', '+slTemp[z]+' ) or StrWithinStr( '+full(tempRecord)+', '+slTemp[z]+' ) or HasKeyword( '+EditorID(tempRecord)+', Armor'+slTemp[z]+' ) or HasKeyword( '+EditorID(tempRecord)+', Clothing'+slTemp[z]+' ) then begin');
							if StrWithinStr(EditorID(tempRecord), slTemp[z]) or StrWithinStr(full(tempRecord), slTemp[z]) or HasKeyword(tempRecord, 'Armor'+slTemp[z]) or HasKeyword(tempRecord, 'Clothing'+slTemp[z]) then begin
							  // If more than one integer-keyword pair is detected we need to account for both (e.g. Shield20Helmet50
							  tempString := nil;
								for a := 0 to slpair.Count-1 do
									tempString := tempString+slpair.Names[a]+slpair.ValueFromIndex[a]; {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] tempString := '+tempString);
								// Check if aPlugin already has an identically named variant of inputRecord
								// The result needs to be true for any combination of slpair entries
								// Example: Either Gauntlets50Helmet50 or Helmet50Gauntlets50 will return true
								if not Assigned(tempLevelList) then begin
									for a := 0 to Pred(ec(gbs(aPlugin, 'LVLI'))) do begin
										tempInteger := 0;
										for b := 0 to slpair.Count-1 do
											if StrWithinStr(EditorID(ebi(gbs(aPlugin, 'LVLI'), a)), EditorID(inputRecord)) and StrWithinStr(EditorID(ebi(gbs(aPlugin, 'LVLI'), a)), slpair.Names[b]+slpair.ValueFromIndex[b]) then 
												tempInteger := tempInteger+1;
										if (tempInteger = slpair.Count) then begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] Pre-existing variant of inputRecord detected: '+EditorID(ebi(gbs(aPlugin, 'LVLI'), a)));								  
											tempLevelList := ebi(gbs(aPlugin, 'LVLI'), a);
											Break;
										end;
									end;
								end else if debugMsg then msg('[AddToOutfitAuto] [Integer] tempLevelList already assigned');
								// Create a new level list if a pre-existing one is not detected; This is a variant of inputRecord, NOT the sublist
								if not Assigned(tempLevelList) then begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] '+EditorID(inputRecord)+' variant not detected; Creating '+EditorID(inputRecord)+'_'+tempString+' level list');							
									tempLevelList := CopyRecordToFile(inputRecord, aPlugin, True, True);
									SetElementEditValues(tempLevelList, 'EDID', EditorID(inputRecord)+'_'+tempString);
								end;
								// Check if aPlugin already has an identically named sublist
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] Checking for pre-existing '+(EditorID(inputRecord)+'_Sublist_'+slpair.Names[x]+slPair.ValueFromIndex[x])+' subLevelList');
								subLevelList := ebEDID(gbs(aPlugin, 'LVLI'), (EditorID(inputRecord)+'_SubList_'+slpair.Names[x]+slPair.ValueFromIndex[x]));
								// Add subLevelList to tempLevelList if not already added
								if Assigned(subLevelList) then begin
									{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] if not LLcontains( '+EditorID(tempLevelList)+', '+EditorID(subLevelList)+' ) := '+BoolToStr(LLcontains(tempLevelList, subLevelList))+' then begin');
									if not LLcontains(tempLevelList, subLevelList) then begin
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] addToLeveledList( '+EditorID(tempLevelList)+', '+EditorID(subLevelList)+', 1);');
										addToLeveledList(tempLevelList, subLevelList, 1);
									end;
								end;
								// Create a new sub level list if a pre-existing one is not detected
								if not Assigned(subLevelList) then begin
									slTemp.CommaText := '"Use All"');
									subLevelList := createLeveledList(aPlugin, (EditorID(inputRecord)+'_SubList_'+slpair.Names[x]+slPair.ValueFromIndex[x]), slTemp, (100-StrToInt(slpair.ValueFromIndex[x])));
									{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] addToLeveledList( '+EditorID(subLevelList)+', '+EditorID(tempRecord)+', 1);');
									addToLeveledList(subLevelList, tempRecord, 1);
							  end;
								if Assigned(subLevelList) then begin
									{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] if not LLcontains( '+EditorID(tempLevelList)+', '+EditorID(subLevelList)+' ) := '+BoolToStr(LLcontains(tempLevelList, subLevelList))+' then begin');
									if not LLcontains(tempLevelList, subLevelList) then begin
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] LLreplace( '+EditorID(tempLevelList)+', '+EditorID(tempRecord)+', '+EditorID(subLevelList)+' );');
										LLreplace(tempLevelList, tempRecord, subLevelList);
									end;
								end;
							end;
						end;
					end;
				end;				
				OTFTitem := RefreshList(OTFTcopy, 'INAM'); {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] Refreshing '+EditorID(OTFTcopy)+' ''INAM'' Element');
				// Add the finished variant of the inputRecord level list to the OTFT
				if Assigned(tempLevelList) then begin
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] LLreplace( '+EditorID(masterLevelList)+', '+EditorID(tempLevelList)+', 1);');
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+');');
					LLreplace(masterLevelList, inputRecord, tempLevelList);
					SetEditValue(OTFTitem, ShortName(masterLevelList)); {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] SetEditValue( '+GetEditValue(OTFTitem)+', ShortName( '+EditorID(tempLevelList)+' ) := '+ShortName(tempLevelList)+' )');
				end else 
					msg('[AddToOutfitAuto] [ERROR] tempLevelList output not generated for: '+EditorID(OTFTcopy));
////////////////////////////////////////////////////////////////////// SPECIFIC OTFT TYPES - NO/WITHOUT ////////////////////////////////////////////////////////////////////////////////
			end else if StrWithinStr(EditorID(OTFTcopy), 'No') or StrWithinStr(EditorID(OTFTcopy), 'without') then begin
				// Check for a keyword with the OTFT 'EDID'
				// Get a list of all keywords related to the keyword detected
				slTemp.CommaText := 'Mask, Bracers, Helmet, Hood, Crown, Shield, Buckler, Cuirass, Greaves, Boots, Gloves, Gauntlets';	
				for x := 0 to slTemp.Count-1 do begin
					if StrWithinStr(EditorID(OTFTcopy), slTemp[x]) then begin
					  tempString := slTemp[x];
						slFuzzyItem(slTemp[x], slTemp);
						Break;
					end;
				end;	
				// Checking FULL, EditorID, and Keywords for relevant item types
				OTFTitem := RefreshList(OTFTcopy, 'INAM');
				{Debug} if debugMsg then msg('[AddToOutfitAuto] [No/Without] No/Without OTFT detected');
				for y := 0 to Pred(LLec(inputRecord)) do begin					
					LLentry := LLebi(inputRecord, y);
					tempBoolean := False;
					for z := 0 to slTemp.Count-1 do begin
						if StrWithinStr(EditorID(LLentry), slTemp[z]) then tempBoolean := True;
						if StrWithinStr(full(LLentry), slTemp[z]) then tempBoolean := True;
						if HasKeyword(LLentry, 'Armor'+slTemp[z]) or HasKeyword(LLentry, 'Clothing'+slTemp[z]) then tempBoolean := True;
					end;
					if tempBoolean then begin 
						tempInteger := y;
						Break;
					end;
				end;
				if tempBoolean then begin
					tempLevelList := CopyRecordToFile(inputRecord, aPlugin, True, True);
					SetElementEditValues(tempLevelList, 'EDID', EditorID(inputRecord)+'_No'+tempString);
					Remove(ebi(ebp(inputRecord, 'Leveled List Entries'), tempInteger));
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [No/Without] addToLeveledList( '+EditorID(masterLevelList)+', '+EditorID(tempLevelList)+', 1);');
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [No/Without] SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+');');
					addToLeveledList(masterLevelList, tempLevelList, 1);
					SetEditValue(OTFTitem, ShortName(masterLevelList));
				end else begin
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [No/Without] SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+');');
					SetEditValue(OTFTitem, ShortName(masterLevelList));
				end;
////////////////////////////////////////////////////////////////////// SPECIFIC OTFT TYPES - SIMPLE ////////////////////////////////////////////////////////////////////////////////
			end else if StrWithinStr(EditorID(OTFTcopy), 'Simple') then begin
				OTFTitem := RefreshList(OTFTcopy, 'INAM');
				{Debug} if debugMsg then msg('[AddToOutfitAuto] [Simple] Simple OTFT detected');
				tempLevelList := CopyRecordToFile(inputRecord, aPlugin, True, True);
				SetElementEditValues(tempLevelList, 'EDID', EditorID(inputRecord)+'_Simple');
				Remove(ebp(tempLevelList, 'Leveled List Entries'));
				Add(tempLevelList, 'Leveled List Entries', True);
				RemoveInvalidEntries(tempLevelList);
				// Checking FULL, EditorID, and Keywords for relevant item types
				for y := 0 to Pred(LLec(inputRecord)) do begin
					LLentry := LLebi(inputRecord, y);
					slTemp.CommaText := 'Helm, Hood, Head, Boots, Shoes, Feet';
					tempBoolean := False;
					for z := 0 to slTemp.Count-1 do begin
						if StrWithinStr(EditorID(LLentry), slTemp[z]) then tempBoolean := True;
						if StrWithinStr(full(LLentry), slTemp[z]) then tempBoolean := True;
						if HasKeyword(LLentry, 'Armor'+slTemp[z]) or HasKeyword(LLentry, 'Clothing'+slTemp[z]) then tempBoolean := True;
					end;
					if tempBoolean then addToLeveledList(tempLevelList, LLentry, 1);
				end;	
			end else if StrWithinStr(EditorID(OTFTrecord), 'Bandit') then begin
				OTFTitem := RefreshList(OTFTcopy, 'INAM');
				{Debug} if debugMsg then msg('[AddToOutfitAuto] Bandit OTFT detected');
				// Checking FULL, EDID, and Keywords for relevant item types
				for y := 0 to Pred(LLec(inputRecord)) do begin
					LLentry := LLebi(inputRecord, y);
					slTemp.CommaText := 'Gloves, Gauntlets, Hands';
					tempBoolean := False;
					for z := 0 to slTemp.Count-1 do begin
						if StrWithinStr(EditorID(LLentry), slTemp[z]) then tempBoolean := True;
						if StrWithinStr(full(LLentry), slTemp[z]) then tempBoolean := True;
						if HasKeyword(LLentry, 'Armor'+slTemp[z]) or HasKeyword(LLentry, 'Clothing'+slTemp[z]) then tempBoolean := True;
					end;
					if tempBoolean then begin
						tempInteger := y;
						Break;
					end;
				end;
				if tempBoolean then begin
					tempLevelList := CopyRecordToFile(inputRecord, aPlugin, True, True);
					SetElementEditValues(tempLevelList, 'EDID', EditorID(inputRecord)+'_Gauntlets50');
					subLevelList := ebEDID(gbs(aPlugin, 'LVLI'), EditorID(inputRecord)+'_SubList_Gauntlets50');
					if not Assigned(subLevelList) then
						slTemp.CommaText := '"Use All"');
						subLevelList := createLeveledList(aPlugin, EditorID(inputRecord)+'_SubList_Gauntlets50', slTemp, 50);	
					if not LLcontains(subLevelList, LLebi(inputRecord, tempInteger) then begin
						{Debug} if debugMsg then msg('[AddToOutfitAuto] addToLeveledList( '+EditorID(subLevelList)+', '+EditorID(LLebi(inputRecord, tempInteger))+', 1);');
						addToLeveledList(subLevelList, LLebi(inputRecord, tempInteger), 1);
					end;
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Simple] addToLeveledList( '+EditorID(masterLevelList)+', '+EditorID(tempLevelList)+', 1);');
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Simple] SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+');');
					addToLeveledList(masterLevelList, tempLevelList, 1);
					SetEditValue(OTFTitem, ShortName(masterLevelList));
				end else begin
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Simple] SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+');');
					SetEditValue(OTFTitem, ShortName(masterLevelList));
				end;
////////////////////////////////////////////////////////////////////// SPECIFIC OTFT TYPES - OTHER ////////////////////////////////////////////////////////////////////////////////				
			end else begin
			{Debug} if debugMsg then msg('[AddToOutfitAuto] [Other] Other OTFT detected; SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+' );');
			slTemp.CommaText := 'Shield, Buckler';
			tempBoolean := False;
			for y := 0 to Pred(ec(ebp(OTFTrecord, 'INAM'))) do begin
				for z := 0 to slTemp.Count-1 do begin
					if StrWithinStr(EditorID(LLentry), slTemp[z]) then tempBoolean := True;
					if StrWithinStr(full(LLentry), slTemp[z]) then tempBoolean := True;
					if HasKeyword(LLentry, 'Armor'+slTemp[z]) or HasKeyword(LLentry, 'Clothing'+slTemp[z]) then tempBoolean := True;
				end;
				if tempBoolean then tempInteger := y;
			end;
			OTFTitem := RefreshList(OTFTcopy, 'INAM');
			if tempBoolean then begin
				tempBoolean := False;
				for y := 0 to Pred(LLec(inputRecord)) do begin
					tempRecord := LLebi(inputRecord, y);
					for z := 0 to slTemp.Count-1 do begin
						if StrWithinStr(EditorID(LLentry), slTemp[z]) then tempBoolean := True;
						if StrWithinStr(full(LLentry), slTemp[z]) then tempBoolean := True;
						if HasKeyword(LLentry, 'Armor'+slTemp[z]) or HasKeyword(LLentry, 'Clothing'+slTemp[z]) then tempBoolean := True;
					end;
				end;
				if tempBoolean then begin
					tempLevelList := CopyRecordToFile(inputRecord, aPlugin, True, True);
					SetElementEditValues(tempLevelList, 'EDID', EditorID(inputRecord)+'_NoShield');
					RemoveElement(ebi(ebp(tempLevelList, 'Leveled List Entries'), tempInteger));
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Other] addToLeveledList( '+EditorID(masterLevelList)+', '+EditorID(tempLevelList)+', 1);');
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Other] SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+' );');
					addToLeveledList(masterLevelList, tempLevelList, 1);
					SetEditValue(OTFTitem, ShortName(masterLevelList));	    
				end else SetEditValue(OTFTitem, ShortName(masterLevelList));
			end else SetEditValue(OTFTitem, ShortName(masterLevelList));		
	  end;
	end;
	
	// Finalize
	if Assigned(slEnchantedList) then slEnchantedList.Free;
	if Assigned(slStringList) then slStringList.Free;
	if Assigned(slTempObject) then slTempObject.Free;
	if Assigned(slBlacklist) then slBlacklist.Free;
	if Assigned(slLevelList) then slLevelList.Free;
	if Assigned(slOutfit) then slOutfit.Free;
	if Assigned(slItem) then slItem.Free;
	if Assigned(slTemp) then slTemp.Free;
	if Assigned(slpair) then slpair.Free;
	if Assigned(sl1) then sl1.Free;
	if Assigned(sl2) then sl2.Free;
	
  debugMsg := False;
// End debugMsg Section
end;

// Find the type of Item
function ItemKeyword(inputRecord: IInterface): String;
var
  KWDAentries, KWDAkeyword: IInterface;
  debugMsg: Boolean;
  slTemp: TStringList;
  i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	// Initialize
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
	
	// Function
  slTemp.CommaText := 'ArmorHelmet, ArmorCuirass, ArmorGauntlets, ArmorBoots, ArmorShield, ClothingHead, ClothingBody, ClothingHands, ClothingFeet, ClothingCirclet, ClothingRing, ClothingNecklace, WeapTypeBattleaxe, WeapTypeBow, WeapTypeDagger, WeapTypeGreatsword, WeapTypeMace, WeapTypeSword, WeapTypeWarAxe, WeapTypeWarhammer, VendorItemArrow';
  {Debug} if debugMsg then for i := 0 to slTemp.Count-1 do msg('[ItemKeyword] '+slTemp[i]);
  KWDAentries := ebp(inputRecord, 'KWDA'); {Debug} if debugMsg then msg('[ItemKeyword] Pred(ec(KWDAentries)) :='+IntToStr(Pred(ec(KWDAentries))));
  for i := 0 to Pred(ec(KWDAentries)) do begin {Debug} if debugMsg then msg('[ItemKeyword] LinksTo(ebi(KWDAentries, i)) :='+EditorID(LinksTo(ebi(KWDAentries, i))));
    KWDAkeyword := LinksTo(ebi(KWDAentries, i)); {Debug} if debugMsg then msg('[ItemKeyword] slTemp.Count-1 :='+IntToStr(slTemp.Count-1));
	for i := 0 to slTemp.Count-1 do begin {Debug} if debugMsg then msg('[ItemKeyword] Result := '+slTemp[i]);
	  Result := slTemp[i]; {Debug} if debugMsg then msg('[ItemKeyword] EditorID(KWDAkeyword) := '+EditorID(KWDAkeyword)+') = Result := '+slTemp[i]+') then Exit;');
	  if (EditorID(KWDAkeyword) = Result) then begin
			slTemp.Free;
			Exit;
		end;
	end;
	Result := nil;
  end;
  {Debug} if debugMsg then msg('[ItemKeyword] Result := nil; Exit;')
	
	// Finalize
  slTemp.Free;
	debugMsg := False;
// End debugMsg section
end;

// Returns the BOD2 slot associated with the keyword
function KeywordToBOD2(aKeyword: String): String;
var
	slTemp: TStringList;
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg Section
	debugMsg := False;
	
	// Initialize
	slTemp := TStringList.Create;
	
	// Function
	{Debug} if debugMsg then msg('[KeywordToBOD2] KeywordToBOD2( '+aKeyword+' );');
	slTemp.CommaText := 'ArmorHelmet, ClothingHead';
	if slContains(slTemp, aKeyword) then
		Result := '30';
	slTemp.CommaText := 'ArmorCuirass, ClothingBody';
	if slContains(slTemp, aKeyword) then
		Result := '32';
	slTemp.CommaText := 'ArmorGauntlets, ClothingHands';
	if slContains(slTemp, aKeyword) then
		Result := '33';
	slTemp.CommaText := 'ArmorBoots, ClothingFeet';
	if slContains(slTemp, aKeyword) then
		Result := '37';	
	slTemp.CommaText := 'ArmorShield';
	if slContains(slTemp, aKeyword) then
		Result := '39';
	slTemp.CommaText := 'ClothingCirclet';
	if slContains(slTemp, aKeyword) then
		Result := '42';
	slTemp.CommaText := 'ClothingRing';
	if slContains(slTemp, aKeyword) then
		Result := '36';
	slTemp.CommaText := 'ClothingNecklace';
	if slContains(slTemp, aKeyword) then
		Result := '35';
	{Debug} if debugMsg then msg('[KeywordToBOD2] Result := '+Result);
	
	// Finalize
	slTemp.Free;
	
	debugMsg := False;
// End debugMsg Section
end;

// Creates an enchanted copy of the item record and returns it [From Generate Enchanted Versions]
function CreateEnchantedVersion(aRecord, aPlugin, objEffect, enchRecord: IInterface; suffix: String; enchAmount: Integer; aBoolean: Boolean): IInterface;
var
  tempRecord: IInterface;
	tempString: String;
	debugMsg: Boolean;
  enchCost: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[CreateEnchantedVersion] Begin');
	{Debug} if debugMsg then msg('[CreateEnchantedVersions] CreateEnchantedVersion( '+EditorID(aRecord)+', '+GetFileName(aPlugin)+', '+EditorID(objEffect)+', '+EditorID(enchRecord)+', '+suffix+', '+IntToStr(enchAmount)+' );');
	
	// Create new enchantment if one is not detected
	{Debug} if debugMsg then msg('[CreateEnchantedVersions] SetElementEditValues( enchRecord, EditorID, '+EditorID(aRecord)+'_'+EditorID(objEffect)+' );');
	SetElementEditValues(enchRecord, 'EDID', EditorID(aRecord)+'_'+EditorID(objEffect));	
	SetElementEditValues(enchRecord, 'EITM', GetEditValue(objEffect));
	if (enchAmount = 0) then
		enchAmount := 1;
	SetElementEditValues(enchRecord, 'EAMT', enchAmount);	
	SetElementEditValues(enchRecord, 'FULL', full(aRecord)+' of '+Trim(suffix));
	// Set template so that enchanted version will use base record's COBJ
	if (sig(aRecord) = 'WEAP') then begin
		{Debug} if debugMsg then msg('[CreateEnchantedVersions] SetElementEditValues( '+EditorID(enchRecord)+', CNAM, '+ShortName(aRecord)+' );');
		SetElementEditValues(enchRecord, 'CNAM', ShortName(aRecord));
	end else if (sig(aRecord) = 'ARMO') then begin
		{Debug} if debugMsg then msg('[CreateEnchantedVersions] SetElementEditValues( '+EditorID(enchRecord)+', TNAM, '+ShortName(aRecord)+' );');
		SetElementEditValues(enchRecord, 'TNAM', ShortName(aRecord));
	end;
	
	// Disallow enchanting
	if not aBoolean then begin
		if not HasKeyword(enchRecord, EditorID(GetRecordByFormID('000C27BD'))) then begin
			enchRecord := CopyRecordToFile(enchRecord, aPlugin, False, True);
			SetElementEditValues(enchRecord, 'EDID', EditorID(aRecord)+'_'+EditorID(objEffect)+'_DisallowEnchanting');
			AddKeyword(enchRecord, GetRecordByFormID('000C27BD'));
		end;
	end;
	
	{Debug} if debugMsg then msg('[CreateEnchantedVersions] Result := '+EditorID(enchRecord));
  Result := enchRecord;
	
	debugMsg := False;
// End debugMsg section
end;

// Checks to see if a string ends with an entered substring [mte functions]
function StrEndsWith(s1, s2: String): Boolean;
var
  i, n1, n2: Integer;
begin
  Result := false;
  n1 := Length(s1);
  n2 := Length(s2);
  if (n1 < n2) then Exit;
  Result := (Copy(s1, n1-n2+1, n2) = s2);
end;

// Appends a string to the end of the input string if it's not already there (from mte functions)
function AppendIfMissing(s1, s2: String): String;
begin
  Result := s1;
  if not StrEndsWith(s1, s2) then Result := s1 + s2; 
end;

// This function will allow you to find the position of a substring in a string. If the iteration of the substring isn't found -1 is returned.
function ItPos(substr: String; str: String; it: Integer): Integer;
var
  debugMsg: Boolean;
  i, found: integer;
begin
// Begin debugMsg Section
  debugMsg := False; 
  {Debug} if debugMsg then msg('[ItPos] substr := '+substr);
  {Debug} if debugMsg then msg('[ItPos] str := '+str);
  {Debug} if debugMsg then msg('[ItPos] it := '+IntToStr(it)); 
  {Debug} if debugMsg then msg('[ItPos] Result := -1');
  Result := -1;
  //msg('Called ItPos('+substr+', '+str+', '+IntToStr(it)+')');
  if it = 0 then exit;
  found := 0;
  for i := 1 to Length(str) do begin
    //msg('    Scanned substring: '+Copy(str, i, Length(substr)));
    if (Copy(str, i, Length(substr)) = substr) then Inc(found);
    if found = it then begin
      Result := i;
      Break;
    end;
  end;
  debugMsg := False;
// End debugMsg Section
end;

// Gets a template from and enchanted record
function GetEnchTemplate(e: IInterface): IInterface;
var
	debugMsg: Boolean;
begin
	if ee(e, 'CNAM') then begin
		Result := LinksTo(ElementBySignature(e, 'CNAM'));
		Exit;
	end;
	if ee(e, 'TNAM') then begin
		Result := LinksTo(ElementBySignature(e, 'TNAM'));
		Exit;
	end;
end;

// Checks if a string contains integers and then returns those integers
function IntWithinStr(aString: String): Integer;
var
  debugMsg: Boolean;
  i, x, tempInteger: Integer;
  slTemp, slItem: TStringList;
  tempString: String;
begin
// Begin debugMsg Section
  debugMsg := False;
	// Initialize
  if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
  if not Assigned(slItem) then slItem := TStringList.Create else slItem.Clear;
	
	// Function
  slTemp.CommaText := '0, 1, 2, 3, 4, 5, 6, 7, 8, 9';
  for i := 1 to Length(aString) do begin
    tempString := Copy(aString, i, 1);
		// {Debug} if debugMsg then msg('[IntWithinStr] tempString := '+tempString);
		for x := 0 to slTemp.Count-1 do begin 
			if (tempString = slTemp[x]) then begin {Debug} if debugMsg then msg('[IntWithinStr] '+tempString+' = '+slTemp[x]);
				if (slItem.Count = 0) then begin {Debug} if debugMsg then msg('[IntWithinStr] slItem.Count-1 = 0');
					slItem.Add(tempString); {Debug} if debugMsg then msg('[IntWithinStr] slItem.Add( '+tempString+' );');
					tempInteger := i; {Debug} if debugMsg then msg('[IntWithinStr] tempInteger := '+IntToStr(tempInteger));
				end else begin {Debug} if debugMsg then msg('[IntWithinStr] slItem.Count-1 <> 0'); 
				  {Debug} if debugMsg then msg('[IntWithinStr] if not ( '+IntToStr(i)+' - '+IntToStr(tempInteger)+' > 1) then begin');
					if not (i-tempInteger > 1) then begin {Debug} if debugMsg then msg('[IntWithinStr] slItem.Add( '+tempString+' );');
						slItem.Add(tempString); {Debug} if debugMsg then msg('[IntWithinStr] if not '+IntToStr(i)+' - '+IntToStr(tempInteger)+' > 1) then begin');
						tempInteger := i; {Debug} if debugMsg then msg('[IntWithinStr] tempInteger := '+IntToStr(i));
					end;
				end;
			end;
		end;
  end;
	{Debug} if debugMsg then msg('[IntWithinStr] if not slItem.Count := '+IntToStr(slItem.Count)+' = 0 then begin');
	tempString := nil;
  if not (slItem.Count = 0) then begin
    for i := 0 to slItem.Count-1 do begin
		  {Debug} if debugMsg then msg('[IntWithinStr] tempString := '+tempString+' + '+slItem[i]);
      tempString := tempString+slItem[i];
		end;
		if (length(tempString) > 0) then
			Result := StrToInt(tempString);
		{Debug} if debugMsg then msg('[IntWithinStr] Result := '+IntToStr(Result));
  end else Result := -1;
	
	// Finalize
  slTemp.Free;
  slItem.Free;
	debugMsg := False;
// End debugMsg Section
end;

// Finds if a string contains a substring
function StrWithinStr(aString: String; bString: String): Boolean;
var
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Function
	{Debug} if debugMsg then msg('[StrWithinStr] aString := '+aString);
	{Debug} if debugMsg then msg('[StrWithinStr] bString := '+bString);
  if ItPos(Lowercase(bString), Lowercase(aString), 1) <> -1 then 
		Result := True   
  else 
		Result := False; 
		
	debugMsg := False;
// End debugMsg section
end;

// Finds if StringList contains substring
function StrWithinSL(s: String; aList: TStringList): Boolean;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[StrWithinSL] s := '+s);
	Result := False;
	for i := 0 to aList.Count-1 do begin
		if StrWithinStr(aList[i], s) then begin
			Result := True;
			Break;
		end;
	end;
	
	debugMsg := False;
// End debugMsg section
end;

// Finds if StringList contains substring
function StrWithinStrSL(aList, bList: TStringList): Boolean;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[StrWithinStrSL] s := '+s);
	Result := False;
	for i := 0 to aList.Count-1 do begin
		if StrWithinSL(aList[i], bList) then begin
			Result := True;
			Exit
		end;
	end;
	
	debugMsg := False;
// End debugMsg section
end;

// Finds if StringList contains substring
function SLWithinStr(s: String; aList: TStringList): Boolean;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[StrWithinSL] s := '+s);
	Result := False;
	for i := 0 to aList.Count-1 do begin
		if StrWithinStr(s, aList[i]) then begin
			Result := True;
			Break;
		end;
	end;
	
	debugMsg := False;
// End debugMsg section
end;

// Fills a TStringList with 'true' flag values; Boolean controls if list gets just numbers or the whole element name
Procedure slGetFlagValues(e: IInterface; aList: TStringList; aBoolean: Boolean);
var
	slTemp: TStringList;
	i: Integer;
	debugMsg: Boolean;
	tempString, BinaryList: String;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Initialize
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
	
	// Function
	if (sig(e) = 'ARMO') then begin
		{Debug} if debugMsg then msgList('[slGetFlagValues] slGetFlagValues( '+EditorID(e)+', ', aList, ', '+BoolToStr(aBoolean));
		slTemp.CommaText := FlagValues(ebp(ElementBySignature(e, GetElementType(e)), 'First Person Flags'));
		{Debug} if debugMsg then msgList('[slGetFlagValues] FlagValues := ', slTemp, '');
		BinaryList := GetEditValue(ebp(ElementBySignature(e, GetElementType(e)), 'First Person Flags'));
		{Debug} if debugMsg then msg('[slGetFlagValues] BinaryList := '+BinaryList);
		if aBoolean then begin
			for i := 1 to Length(BinaryList) do	begin
				if (Copy(BinaryList, i, 1) = '1') then begin
					if (i+2 <= slTemp.Count-1) then begin
						tempString := slTemp[3*(i-1)]+' '+slTemp[3*(i-1)+1]+' '+slTemp[3*(i-1)+2];
						if not slContains(aList, tempString) then
							aList.Add(tempString);
					end;
				end;
			end;
		end else begin
			for i := 1 to Length(BinaryList) do	begin
				if (Copy(BinaryList, i, 1) = '1') then begin
					if not slContains(aList, slTemp[3*(i-1)]) then begin
						{Debug} if debugMsg then msg('[slGetFlagValues] aList.Add( '+slTemp[3*(i-1)]+' );');
						aList.Add(slTemp[3*(i-1)]);
					end;
				end;
			end;
		end;
	end else if (sig(e) = 'LVLI') then begin
		{Debug} if debugMsg then msgList('[slGetFlagValues] slGetFlagValues( '+EditorID(e)+', ', aList, ', '+BoolToStr(aBoolean));
		sl1.CommaText := '"Calculate from all levels <= player''s level", "Calculate for each item in count", "Use All", "Special Loot"';
		{Debug} if debugMsg then msgList('[slGetFlagValues] FlagValues := ', slTemp, '');
	end else begin
		aList.Add(sig(e));
		slTemp.Free;
		Exit;
	end;
	
	// Finalize
	slTemp.Free;
	
	debugMsg := False;
// End debugMsg section
end;

// Set Flag Values based on input string list
Procedure slSetFlagValues(e: IInterface; aList: TStringList; aPlugin: IInterface);
var
	tempString, BinaryList: String;
	slTemp, sl1: TStringList;
	tempRecord: IInterface;
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Initialize
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
	if not Assigned(sl1) then sl1 := TStringList.Create else sl1.Clear;
	
	// Function
	{Debug} if debugMsg then msgList('[slSetFlagValues] slSetFlagValues( '+EditorID(e)+', ', aList, ' )');
	if (sig(e) = 'ARMO') then begin
		slTemp.CommaText := FlagValues(ebp(ElementBySignature(e, GetElementType(e)), 'First Person Flags'));
		{Debug} if debugMsg then msgList('[slSetFlagValues] FlagValues := ', slTemp, '');
		BinaryList := GetEditValue(ebp(ElementBySignature(e, GetElementType(e)), 'First Person Flags'));
		{Debug} if debugMsg then msg('[slSetFlagValues] BinaryList := '+BinaryList);
		for i := 0 to slTemp.Count-1 do	begin
			// {Debug} if debugMsg then msg('[slSetFlagValues] if ( '+IntToStr(i+2)+' <= '+IntToStr(slTemp.Count-1)+' ) then begin');
			if (3*(i)+2 <= slTemp.Count-1) then begin
				tempString := slTemp[3*(i)]+' '+slTemp[3*(i)+1]+' '+slTemp[3*(i)+2];
				if not slContains(sl1, tempString) then
					sl1.Add(tempString);
				i := i+3;
			end;
		end;
		{Debug} if debugMsg then msgList('[slSetFlagValues] sl1 := ', sl1, '');
		slTemp.Clear;
		tempString := nil;
		for i := 0 to sl1.Count-1 do begin
			if slContains(aList, sl1[i]) then begin
				tempString := tempString + '1';
			end else begin
				tempString := tempString + '0';
			end;
		end;
		{Debug} if debugMsg then msg('[slSetFlagValues] New BinaryList := '+tempString);
		if StrWithinStr(tempString, '1') then
			SetEditValue(ebp(ElementBySignature(e, GetElementType(e)), 'First Person Flags'), Copy(tempString, 0, rPos(tempString, '1')));
	end else if (sig(e) = 'LVLI') then begin
		// Make a copy of the list
		tempRecord := ebEDID(gbs(aPlugin, 'LVLI'), EditorID(e));
		if not Assigned(tempRecord) then begin
			AddMastersAuto(GetFile(e), aPlugin);
			tempRecord := CopyRecordToFile(e, aPlugin, False, True);
		end;
		
		// Assemble and assign new binary list
		sl1.CommaText := '"Calculate from all levels <= player''s level", "Calculate for each item in count", "Use All", "Special Loot"';
		{Debug} if debugMsg then msgList('[slGetFlagValues] FlagValues := ', sl1, '');
		{Debug} if debugMsg then msgList('[slSetFlagValues] sl1 := ', sl1, '');
		slTemp.Clear;
		tempString := nil;
		for i := 0 to sl1.Count-1 do begin
			if slContains(aList, sl1[i]) then begin
				tempString := tempString + '1';
			end else begin
				tempString := tempString + '0';
			end;
		end;
		{Debug} if debugMsg then msg('[slSetFlagValues] New BinaryList := '+Copy(tempString, 0, rPos(tempString, '1')));
		if StrWithinStr(tempString, '1') then
			SetEditValue(ElementBySignature(tempRecord, 'LVLF'), Copy(tempString, 0, rPos(tempString, '1')));
	end else begin
		aList.Add(sig(e));
		slTemp.Free;
		Exit;
	end;

		
	// Finalize
	slTemp.Free;
	sl1.Free;
	
	debugMsg := False;
// End debugMsg section
end;

// Copies string preceding [TRUE] or following [FALSE] a string 
function StrPosCopy(inputString: String; findString: String; inputBoolean: Boolean): String;
var
 debugMsg: Boolean;
begin
// Begin debugMsg Section
  debugMsg := False; {Debug} if debugMsg then msg('[StrPosCopy] if StrWithinStr(inputString := '+inputString+', findString := '+findString+') then begin');
  if StrWithinStr(inputString, findString) then begin 
    {Debug} if debugMsg then msg('[StrPosCopy] if not inputBoolean := '+BoolToStr(inputBoolean)+' then');
    if not inputBoolean then begin 
	  Result := Copy(inputString, (ItPos(findString, inputString, 1)+length(findString)), (length(inputString)-ItPos(findstring, inputstring, 1))); 
	  {Debug} if debugMsg then msg('[StrPosCopy] Copy(inputString := '+inputString+', (ItPos(findString := '+findString+' inputString := '+inputString+', 1)+length(findString) := '+IntToStr(length(findString))+') := '+IntToStr(ItPos(findString, inputString, 1))+', (length(inputString) := '+IntToStr(length(inputString))+' - ItPos(findstring, inputString, 1)) := '+IntToStr(ItPos(findstring, inputstring, 1))+')'); 
	  {Debug} if debugMsg then msg('[StrPosCopy] Result := '+Copy(inputString, (ItPos(findString, inputString, 1)+length(findString)), (length(inputString)-ItPos(findstring, inputstring, 1))));
	end;
    {Debug} if debugMsg then msg('[StrPosCopy] if inputBoolean := '+BoolToStr(inputBoolean)+' then');    
	if inputBoolean then begin 
	  Result := Copy(inputString, 0, (ItPos(findString, inputString, 1)-1)); 
	  {Debug} if debugMsg then msg('[StrPosCopy] Copy(inputString := '+inputString+', 0, (ItPos(findString, inputString, 1)-1 := '+IntToStr(ItPos(findString, inputString, 1)-1)+'));'); 
	  {Debug} if debugMsg then msg('[StrPosCopy] Result := '+Copy(inputString, 0, (ItPos(findString, inputString, 1)-1)));
	end;
  end else Result := Trim(inputString);
  debugMsg := False;
// End debugMsg Section
end;

// Copies from end instead of beginning
function StrPosCopyReverse(inputString: String; findString: String; inputBoolean: Boolean): String;
begin
  if StrWithinStr(inputString, findString) then begin
    RemoveFromEnd(inputString, ' ');
    if (findString = ' ') then 
	  if Flip(inputBoolean) then Result := RemoveFromEnd(ReverseString(Copy(ReverseString(inputString), 0, ItPos(findString, ReverseString(inputString), 2)-length(findString))), ' ')
	  else Result := RemoveFromEnd(ReverseString(Copy(ReverseString(inputString), ItPos(findString, ReverseString(inputString), 2)-length(findString)), (Length(ReverseString(inputString))-ItPos(findstring, inputstring, 2))), ' ')
	else Result := ReverseString(StrPosCopy(ReverseString(inputString), findString, Flip(inputBoolean)))
	// msg('[StrPosCopyReverse]'+ReverseString(inputString));
	// msg('[StrPosCopyReverse]'+StrPosCopy(ReverseString(inputString), ' ', Flip(inputBoolean)));
	// msg('[StrPosCopyReverse]'+ReverseString(StrPosCopy(ReverseString(inputString), ' ', Flip(inputBoolean))));
  end else Result := inputString;
end;

// Shortens geev
function geev(e: IInterface; s: String): String;
begin
  Result := GetElementEditValues(e, s);
end;

// Shortens GetElementNativeValues
function genv(e: IInterface; s: String): String;
begin
  Result := GetElementNativeValues(e, s);
end;

// Shortens SetElementEditValues
function seev(e: IInterface; v, s: String): String;
begin
  Result := SetElementEditValues(e, v, s);
end;

// Shortens SetElementNativeValues
Procedure senv(e: IInterface; s: String; i: Integer);
begin
	SetElementNativeValues(e, s, i);
end;

// Shortens ElementByName [mte functions]
function ebn(e: IInterface; n: string): IInterface;
begin
  Result := ElementByName(e, n);
end;

//Shortens ElementByPath [mte functions]
function ebp(e: IInterface; p: string): IInterface;
begin
  Result := ElementByPath(e, p);
end;

// Shortens ElementByIndex [mte functions]
function ebi(e: IInterface; i: integer): IInterface;
begin
  Result := ElementByIndex(e, i);
end;

{ // Shortens ElementBySignature
function ElementBySignature(e: IInterface; s: String): IInterface;
begin
	Result := ElementBySignature(e, s);
end; }

// Shortens ElementCount
function ec(e: IInterface): Integer;
begin
	Result := ElementCount(e);
end;

// Shortens ReferencedByCount
function rfc(e: IInterface): Integer;
begin
	Result := ReferencedByCount(e);
end;

// Shortens ReferencedByIndex
function rbi(e: IInterface; int: Integer): IInterface;
begin
	Result := ReferencedByIndex(e, int);
end;

// Shortens GroupBySignature
function gbs(e: IInterface; s: String): IInterface;
begin
	Result := GroupBySignature(e, s);
end;

// Shortens Signature
function sig(e: IInterface): String;
begin
	Result := Signature(e);
end;

// Shortens ReferencedByCount
function rbc(e: IInterface): Integer;
begin
	Result := ReferencedByCount(e);
end;

// Shortens addMessage
Procedure msg(s: String);
begin
	addMessage(s);
end;

// Shortens ElementExists
function ee(e: IInterface; s: String): Boolean;
begin
	Result := ElementExists(e, s);
end;

// Shortens MainRecordByEditorID
function ebEDID(e: IInterface; s: String): IInterface;
begin
	Result := MainRecordByEditorID(e, s);
end;

// Shortens geev(e, 'FULL')
function full(e: IInterface): String;
begin
	Result := geev(e, 'FULL');
end;

// Shortens ObjectToElement
function ote(e: TObject): IInterface;
var
	startTime, stopTime: TDateTime;
begin
	startTime := Time;
	Result := ObjectToElement(e);
	stopTime := Time;
	if ProcessTime then
		addProcessTime('ObjectToElement', TimeBtwn(startTime, stopTime));
end;

// Shortens wbCopyElementToFile
Procedure CopyRecordToFile(aRecord, aFile: IInterface; aBoolean, bBoolean: Boolean);
var
	startTime, stopTime: TDateTime;
begin
	startTime := Time;
	Result := wbCopyElementToFile(aRecord, aFile, aBoolean, bBoolean);
	stopTime := Time;
	if ProcessTime then addProcessTime('wbCopyElementToFile', TimeBtwn(startTime, stopTime));
end;

// This is just a ghetto way of replacing all the items with a single leveled list; Returns the first element in the list
function RefreshList(aRecord: IInterface; aString: String): IInterface;
var
  debugMsg: Boolean;
begin
// Begin debugMsg Section
  debugMsg := False;
	
	{Debug} if debugMsg then msg('[AddToOutfitAuto] Remove(ebp('+geev(OTFTcopy, 'EditorID')+', '''+aString+'''));');
	Remove(ebp(aRecord, aString));
	{Debug} if debugMsg then msg('[AddToOutfitAuto] Add('+GetFileName(aPlugin)+', '''+aString+''', True);');
	Add(aRecord, aString, True);
	Result := ebi(ebp(aRecord, aString), 0);
	
	debugMsg := False;
// End debugMsg Section
end;

// Find a record by name (e.x. 'IronSword')
function RecordByName(aName: String; aGroupName: String; aFileName: String): IInterface;
var
  slTemp: TStringList;
  i, slTempCount: Integer;
begin
	// Initialize
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
	
	// Function
  if not (StrEndsWith(aFileName, '.esm') or StrEndsWith(aFileName, '.esl') or StrEndsWith(aFileName, '.exe')) then AppendIfMissing(aFileName, '.esp');
  if (aFileName = 'Skyrim.esm') then begin
    slTemp := TStringList.Create;
	slTemp.CommaText := 'Skyrim.esm, Dawnguard.esm, HearthFires.esm, Dragonborn.esm';
  end else begin
    slTemp := TStringList.Create;
	slTemp.Add(aFileName);
  end;
  for slTempCount := 0 to slTemp.Count-1 do begin
		for i := 0 to Pred(ec(gbs(FileByName(slTemp[slTempCount]), aGroupName))) do begin
			if StrWithinStr(EditorID(ebi(gbs(FileByName(slTemp[slTempCount]), aGroupName), i)), 'Ench') or StrWithinStr(full(ebi(gbs(FileByName(slTemp[slTempCount]), aGroupName), i)), 'Of') then begin
				Continue;
			end else if StrWithinStr(EditorID(ebi(gbs(FileByName(slTemp[slTempCount]), aGroupName), i)), aName) then begin
				Result := ebi(gbs(FileByName(slTemp[slTempCount]), aGroupName), i);
				Exit;
			end;
		end;
  end;
	
	// Finalize
	slTemp.Free;
end;

// Removes s1 from the end of s2, if found [mte functions]
function RemoveFromEnd(s1, s2: string): string; 
begin
  Result := s1;
  if StrEndsWith(s1, s2) then Result := Copy(s1, 1, Length(s1) - Length(s2));  
end;

// This adds a name-value pair in a way that allows for duplicate values
function slAddValue(aName, aValue: String): String;
var
  slTemp: TStringList;
  debugMsg: Boolean;
begin
	// Initialize
  if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
	
	// Function
	slTemp.Values[aValue] := aName;
	if (slTemp.Count > 0) then
		Result := slTemp[0];
	
	// Finalize
	slTemp.Free;
end;

// Reverses a string.
function ReverseString(var s: string): string;
var
  i: integer;
begin
   Result := '';
   for i := Length(s) downto 1 do begin
     Result := Result + Copy(s, i, 1);
   end;
end;

// find the last position of a substring in a string [mte Functions]
function rPos(aString, substr: string): integer;
var
  i: integer;
begin
  Result := -1;
  if (Length(aString) - Length(substr) < 0) then
   Exit;
  for i := Length(aString) - Length(substr) downto 1 do begin
    if (Copy(aString, i, Length(substr)) = substr) then begin
      Result := i;
      Break;
    end;
  end;
end;

// Converts a boolean value into a string [mte Functions]
function BoolToStr(b: boolean): string;
begin
  if b then
    Result := 'True'
  else
    Result := 'False';
end;

// Converts string to boolean
function StrToBool(s: String): Boolean;
begin
	if StrWithinStr(s, 'True') then
		Result := True
	else 
		Result := False;
end;

// Searches for string within TStringList
function slContains(aList: TStringList; s: String): Boolean;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	Result := False;
	{Debug} if debugMsg then msgList('[slContains] if ', aList, ' contains '+s);
	if (aList.IndexOf(s) <> -1) then
		Result := True;
		
	debugMsg := False;
// End debugMsg section
end;

// Adds masters
Procedure AddMastersAuto(inputPlugin, outputPlugin: IInterface);
var
	slTemp, slinputPlugin: TStringList;
	startTime, stopTime: TDateTime;
	inputPlugin_filename: String;
	debugMsg: Boolean;
	i: Integer;
begin
	// Initialize
	debugMsg := False;
	startTime := Time;
	
	// Filter Invalid Records
	{Debug} if debugMsg then msg('[AddMastersAuto] AddMastersAuto( '+GetFileName(inputPlugin)+', '+GetFileName(outputPlugin)+' )');	
	inputPlugin_fileName := GetFileName(inputPlugin);
	if (GetFileName(outputPlugin) = inputPlugin_filename) then Exit;
	if not DoesFileExist(inputPlugin_fileName) then Exit;
	// Initialize
	slinputPlugin := TStringList.Create;
	slinputPlugin.Sorted := True;
	slinputPlugin.Duplicates := dupIgnore;
	slTemp := TStringList.Create;
	
	// Common function output
	ReportRequiredMasters(inputPlugin, slInputPlugin, False, True);
	{Debug} if debugMsg then msgList('[AddMastersAuto] slinputPlugin := ', slInputPlugin, '');
	
	// Add masters that outputPlugin does not already have
	for i := 0 to slinputPlugin.Count-1 do begin
		if (GetLoadOrder(outputPlugin) > GetLoadOrder(FileByName(slInputPlugin[i]))) then begin
			if not HasMaster(outputPlugin, slInputPlugin[i]) then begin
				msg('Adding '+GetFileName(outputPlugin)+' to '+slInputPlugin[i]+' as a Master');
				AddMasterIfMissing(outputPlugin, slInputPlugin[i]);
			end;
		end;
	end;

	AddMasterIfMissing(outputPlugin, inputPlugin_fileName);
	
	// Finalize
	stopTime := Time;
	if ProcessTime then addProcessTime('AddMastersAuto', TimeBtwn(startTime, stopTime));
	slinputPlugin.Free;
	slTemp.Free;
end;

// Adds masters
Procedure AddMastersList(aList, outputPlugin: IInterface);
var
	slTemp, slinputPlugin: TStringList;
	tempRecord: IInterface;
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Filter Invalid Records
	{Debug} if debugMsg then msgList('[AddMastersList] AddMastersList( ', aList, +' to '+GetFileName(outputPlugin)+' )');	
	// Initialize
	slInputPlugin := TStringList.Create;
	slInputPlugin.Sorted := True;
	slInputPlugin.Duplicates := dupIgnore;
	slTemp := TStringList.Create;
	slTemp.Sorted := True;
	slTemp.Duplicates := dupIgnore;
	
	// Process
	for i := 0 to aList.Count-1 do begin
		ReportRequiredMasters(ote(aList.Objects[i]), slinputPlugin, False, True);
		{Debug} if debugMsg then msgList('[AddMastersList] slinputPlugin := ', slInputPlugin, '');
	end;
	
	// Add masters that outputPlugin does not already have
	for i := 0 to slInputPlugin.Count-1 do
		if (GetLoadOrder(outputPlugin) > GetLoadOrder(FileByName(slInputPlugin[i]))) then
			AddMasterIfMissing(outputPlugin, slInputPlugin[i]);
	
	// Finalize
	slInputPlugin.Free;
	slTemp.Free;
	
	debugMsg := False;
// End debugMsg section
end;

// Removes records dependent on a specified master
Procedure RemoveMastersAuto(inputPlugin, outputPlugin: IInterface);
var
	slTemp, slRemove: TStringList;
	tempRecord: IInterface;
	tempString: String;
	debugMsg: Boolean;
	i, x, y: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Initialize
	{Debug} if debugMsg then msg('[RemoveMastersAuto] RemoveMastersAuto( '+GetFileName(inputPlugin)+', '+GetFileName(outputPlugin)+' )');
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
	if not Assigned(slRemove) then slRemove := TStringList.Create else slRemove.Clear;
	tempString := GetFileName(inputPlugin);
	
	// Function
	{Debug} if debugMsg then msg('[RemoveMastersAuto] for i := 0 to '+IntToStr(Pred(ec(outputPlugin)))+' do begin');
	for i := 0 to Pred(ec(outputPlugin)) do begin
		{Debug} if debugMsg then msg('[RemoveMastersAuto] for x := 0 to '+IntToStr(Pred(ec(ebi(outputPlugin, i))))+' do begin');
		for x := 0 to Pred(ec(ebi(outputPlugin, i))) do begin
			// {Debug} if debugMsg then msg('[RemoveMastersAuto] tempRecord := '+EditorID(ebi(ebi(outputPlugin, i), x)));
			tempRecord := ebi(ebi(outputPlugin, i), x);
			slTemp.Clear;
			ReportRequiredMasters(tempRecord, slTemp, False, True);
			{Debug} if debugMsg then msgList('[RemoveMastersAuto] slTemp := ', slTemp, '');
			for y := 0 to slTemp.Count-1 do begin
				{Debug} if debugMsg then msg('[RemoveMastersAuto] if ( '+slTemp[y]+' = '+tempString+' ) then begin');
				if (slTemp[y] = tempString) then begin
					slRemove.AddObject(EditorID(tempRecord), TObject(tempRecord));
					Break;
				end;
			end;
		end;
	end;
	
	// Remove records
	for i := 0 to slRemove.Count-1 do begin
		{Debug} if debugMsg then msg('[RemoveMastersAuto] Remove( '+slRemove[i]+' );');
		Remove(ote(slRemove.Objects[i]));
	end;
		
	// Clean masters
	CleanMasters(outputPlugin);
	
	// Finalize
	slTemp.Free;
	slRemove.Free;
	
	debugMsg := False;
// End debugMsg section
end;

// Creates a leveled list
function createLeveledList(aPlugin: IInterface; aName: String; LVLF: TStringList; LVLD: Integer): IInterface;
var
	startTime, stopTime: TDateTime;
	aLevelList: IInterface;
	debugMsg: Boolean;
begin
	// Initialize
	debugMsg := False;
	startTime := Time;
	
	{Debug} if debugMsg then msgList('[createLeveledList] createLeveledList( '+GetFileName(aPlugin)+', '+aName+', ', LVLF, ', '+IntToStr(LVLD)+' );');
	aLevelList := createRecord(aPlugin, 'LVLI');
	SetElementEditValues(aLevelList, 'EDID', aName);
	slSetFlagValues(aLevelList, LVLF, aPlugin);
	if not (LVLD = 0) then
		SetElementEditValues(aLevelList, 'LVLD', LVLD);
	Add(aLevelList, 'Leveled List Entries', true);
	RemoveInvalidEntries(aLevelList);
	Result := aLevelList;
	{Debug} if debugMsg then msg('[createLeveledList] Result := '+EditorID(Result));
	
	// Finalize
	stopTime := Time;
	if ProcessTime then
		addProcessTime('createLeveledList', TimeBtwn(startTime, stopTime));
end;

// Converts Hex FormID to String
function HexToStr(aFormID: String): String;
begin
  Result := IntToStr(StrToInt(aFormID));
end;

function Flip(inputBoolean: Boolean): Boolean;
begin
  if inputBoolean then Result := False    
  else Result := True;
end;

// gets record by IntToStr HEX FormID [SkyrimUtils]
function getRecordByFormID(id: string): IInterface;
var
	startTime, stopTime: TDateTime;
  tmp: IInterface;
begin
	// Initialize
	startTime := Time;
	
  // basically we took record like 00049BB7, and by slicing 2 first symbols, we get IntToStr file index, in this case Skyrim (00)
  tmp := FileByLoadOrder(StrToInt('$' + Copy(id, 1, 2)));

  // file was found
  if Assigned(tmp) then begin
    // look for this record in founded file, and return it
    tmp := RecordByFormID(tmp, StrToInt('$' + id), true);

    // check that record was found
    if Assigned(tmp) then begin
      Result := tmp;
    end else begin // return nil if not
      Result := nil;
    end;

  end else begin // return nil if not
    Result := nil;
  end;
	
	// Finalize
	stopTime := Time;
	if ProcessTime then
		addProcessTime('getRecordByFormID', TimeBtwn(startTime, stopTime));
end;

// Checks for keyword [SkyrimUtils]
function HasKeyword(aRecord: IInterface; aString: String): boolean;
var
  tempRecord: IInterface;
	debugMsg: Boolean;
  i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
  Result := False;
  tempRecord := ebp(aRecord, 'KWDA');
  for i := 0 to Pred(ec(tempRecord)) do begin
		{Debug} if debugMsg then msg('[HasKeyword] if ( '+EditorID(LinksTo(ebi(tempRecord, i)))+' = '+aString+' ) then begin');
    if (EditorID(LinksTo(ebi(tempRecord, i))) = aString) then begin
			{Debug} if debugMsg then msg('[HasKeyword] Result := True');
      Result := True;
      Break;
    end;
  end;
	
	debugMsg := False;
// End debugMsg section
end;

// Gets a keyword list [SkyrimUtils]
Procedure slKeywordList(aRecord: IInterface; aList: TStringList);
var
  tempRecord: IInterface;
	debugMsg: Boolean;
  i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
  tempRecord := ebp(aRecord, 'KWDA');
  for i := 0 to Pred(ec(tempRecord)) do
		aList.Add(EditorID(LinksTo(ebi(tempRecord, i))));
	debugMsg := False;
// End debugMsg section
end;

// Adds keyword [SkyrimUtils]
function AddKeyword(itemRecord: IInterface; keyword: IInterface): integer;
var
  keywordRef: IInterface;
begin
  // don't edit records, which already have this keyword
  if not HasKeyword(itemRecord, EditorID(keyword)) then begin
    // get all keyword entries of provided record
    keywordRef := ElementByName(itemRecord, 'KWDA');

    // record doesn't have any keywords
    if not Assigned(keywordRef) then begin
      Add(itemRecord, 'KWDA', true);
    end;
    // add new record in keywords list
    keywordRef := ElementAssign(ebp(itemRecord, 'KWDA'), HighInteger, nil, false);
    // set provided keyword to the new entry
    SetEditValue(keywordRef, GetEditValue(keyword));
  end;
end;

// Gets a template item of the comparable type (e.g. sword) and tier (e.g. ebony)
function GetTemplate(aRecord: IInterface): IInterface;
var
	i, x, y, recordValue, slItemMaxValue, slItemMaxLength, slItemMinLength: Integer;	
	tempRecord, record_sig, record_edid, record_full: IInterface;
	debugMsg, tempBoolean, ExitFunction: Boolean;
	slTemp, slItem, slBOD2, slFiles: TStringList;
	startTime, stopTime: TDateTime;
	tempString, itemType: String;
begin
	// Initialize 
	debugMsg := False;
	startTime := Time;
	
	// Initialize
	{Debug} if debugMsg then msg('[GetTemplate] GetTemplate( '+EditorID(aRecord)+' );');
	slFiles := TStringList.Create;
	slTemp := TStringList.Create;
	slItem := TStringList.Create;
	slBOD2 := TStringList.Create;
	
	// Common function output
	record_sig := sig(aRecord);
	record_edid := EditorID(aRecord);
	record_full := full(aRecord);
	
	// Detect existing plugins
	slTemp.CommaText := 'Skyrim.esm, Dawnguard.esm, Hearthfires.esm, Dragonborn.esm';
	for i := 0 to slTemp.Count-1 do
		if DoesFileExist(Trim(slTemp[i])) then
			slFiles.AddObject(Trim(slTemp[i]), TObject(FileByName(slTemp[i])));
	// {Debug} if debugMsg then msgList('[GetTemplate] slFiles := ', slFiles, '');
	// {Debug} if debugMsg then for i := 0 to slFiles.Count-1 do msg('[GetTemplate] slFiles.Objects['+IntToStr(i)+'] := '+GetFileName(ote(slFiles.Objects[i])));
	
	// This section filters clothing items
	slTemp.Clear;
	Randomize;
	slTemp.CommaText := 'ArmorClothing, VendorItemClothing, ClothingBody';
	for i := 0 to slTemp.Count-1 do begin
		if HasKeyword(aRecord, slTemp[i]) then begin
			if StrWithinStr(full(aRecord), 'Fine') then begin
				slItem.CommaText := '00086991, 000CEE80';
			end else
				slItem.CommaText := '0001BE1A, 000209A6, 000261C0, 0003452E';
			Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
			ExitFunction := True;
		end;
	end;
	slTemp.CommaText := 'ClothingHead';
	for i := 0 to slTemp.Count-1 do begin
		if HasKeyword(aRecord, slTemp[i]) then begin
			if StrWithinStr(full(aRecord), 'Fine') then begin
				slItem.CommaText := '000CEE84';
			end else
				slItem.CommaText := '00017696, 000330B3, 000209AA, 000330BC';			
			Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
			ExitFunction := True;
		end;
	end;
	slTemp.CommaText := 'ClothingHands';
	for i := 0 to slTemp.Count-1 do begin
		if HasKeyword(aRecord, slTemp[i]) then begin
			Result := GetRecordByFormID('000261C1');
			ExitFunction := True;
		end;
	end;
	slTemp.CommaText := 'ClothingFeet';
	for i := 0 to slTemp.Count-1 do begin
		if HasKeyword(aRecord, slTemp[i]) then begin
			if StrWithinStr(full(aRecord), 'Fine') then begin
				slItem.CommaText := '00086993, 000CEE82';
			end else
				slItem.CommaText := '0001BE1B, 000209A5, 000261BD, 0003452F';
			Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
			ExitFunction := True;
		end;
	end;
	if ExitFunction then begin
		slTemp.Free;
		slItem.Free;
		slBOD2.Free;
		Exit;
	end;
	
////////////////////////////////////////////////////////////////////// TIER ASSIGNMENT ////////////////////////////////////////////////////////////////////////////////////////////
	slItem.Clear;
	// Weapon tier detection
	itemType := GetItemType(aRecord);
	if (record_sig = 'WEAP') or (record_sig = 'AMMO') then begin {Debug} if debugMsg then msg('['+record_full+'] Begin Weapon Detection');
		// Get selected record type
		{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] itemType := '+itemType);
		// Assign tiers
		{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] Assign Tiers');
		if (itemType = 'Bow') then begin
			slTemp.CommaText := 'Long, Orcish, Dwarven, Elven, Glass, Ebony, Daedric, Dragonbone';
		end else
			slTemp.CommaText := 'Iron, Steel, Orcish, Dwarven, Elven, Glass, Ebony, Daedric, Dragonbone';
		for i := 0 to slTemp.Count-1 do begin
			for x := 0 to slFiles.Count-1 do begin
				{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] tempRecord := ebEDID(gbs( '+GetFileName(ote(slFiles.Objects[x]))+', WEAP ), '+slTemp[i]+itemType+' );');
				tempRecord := ebEDID(gbs(ote(slFiles.Objects[x]), record_sig), slTemp[i]+itemType);
				if not Assigned(tempRecord) then 
					tempRecord := ebEDID(gbs(ote(slFiles.Objects[x]), record_sig), 'DLC1'+slTemp[i]+itemType);
				if not Assigned(tempRecord) then 
					tempRecord := ebEDID(gbs(ote(slFiles.Objects[x]), record_sig), 'DLC2'+slTemp[i]+itemType);
				if Assigned(tempRecord) then Break;
			end;
			if Assigned(tempRecord) and not slContains(slItem, EditorID(tempRecord)) then
				slItem.AddObject(EditorID(tempRecord), TObject(tempRecord));
		end;	
	end;
	// Armor tier detection
	if (record_sig = 'ARMO') then begin {Debug} if debugMsg then msg('[Tier Assignment] Begin Armor Detection');
	// Get selected record type
		// Assign tiers
		{Debug} if debugMsg then msg('[GetTemplate] Assign Tiers');
		slTemp.CommaText := 'Necklace, Ring, Circlet';
		if not slContains(slTemp, itemType) then begin
			tempString := nil;
			if ee(aRecord, 'BODT') then begin
				tempString := 'BODT';
			end else
				tempString := 'BOD2';
			{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] geev( '+EditorID(aRecord)+', BOD2\Armor Type) := '+geev(aRecord, 'BOD2\Armor Type'));
			if (geev(aRecord, tempString+'\Armor Type') = 'Clothing') then begin {Debug} if debugMsg then msg('[TIER ASSIGNMENT] Begin Clothing Detection');
				if (itemType = 'Cuirass') then begin
					if StrWithinStr(full(aRecord), 'Fine') then begin
						slItem.CommaText := '00086991, 000CEE80';
					end else
						slItem.CommaText := '0001BE1A, 000209A6, 000261C0, 0003452E';
					Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
				end else if (itemType = 'Helmet') then begin
					if StrWithinStr(full(aRecord), 'Fine') then begin
						slItem.CommaText := '000CEE84';
					end else
						slItem.CommaText := '00017696, 000330B3, 000209AA, 000330BC';			
					Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
				end else if (itemType = 'Gauntlets') then begin
					Result := GetRecordByFormID('000261C1');
				end else if (itemType = 'Boots') then begin
					if StrWithinStr(full(aRecord), 'Fine') then begin
						slItem.CommaText := '00086993, 000CEE82';
					end else
						slItem.CommaText := '0001BE1B, 000209A5, 000261BD, 0003452F';
					Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
				end else if (itemType = 'Necklace') then begin
					Result := GetRecordByFormID('0009171B');
				end else if (itemType = 'Ring') then begin
					Result := GetRecordByFormID('000877AB');
				end else if (itemType = 'Circlet') then begin
					Result := GetRecordByFormID('000166FF');
				end;
				slTemp.Free;
				slItem.Free;
				slBOD2.Free;
				Exit;
			end else if (geev(aRecord, tempString+'\Armor Type') = 'Light Armor') then begin {Debug} if debugMsg then msg('[TIER ASSIGNMENT] Begin Light Armor Detection');
				slTemp.CommaText := 'Hide, Leather, Elven, Scaled, Glass, Dragonscale';
				for i := 0 to slTemp.Count-1 do begin
					{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] tempRecord := ebEDID( gbs(Skyrim.esm, ARMO), Armor'+slTemp[i]+itemType+' );');
					tempRecord := MainRecordByEditorID(gbs(ote(slFiles.Objects[0]), 'ARMO'), ('Armor'+slTemp[i]+itemType));
					{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] tempRecord := '+EditorID(tempRecord));
					if (EditorID(tempRecord) <> '') and not slContains(slItem, EditorID(tempRecord)) then
						slItem.AddObject(EditorID(tempRecord), TObject(tempRecord));
				end;	
			end else if (geev(aRecord, tempString+'\Armor Type') = 'Heavy Armor') then begin {Debug} if debugMsg then msg('[TIER ASSIGNMENT] Begin Heavy Armor Detection');
				slTemp.CommaText := 'Iron, Steel, SteelPlate, Dwarven, Orcish, Ebony, Dragonplate, Daedric';
				for i := 0 to slTemp.Count-1 do begin
					{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] tempRecord := ebEDID( gbs(Skyrim.esm, ARMO), Armor'+slTemp[i]+itemType+' );');
					if not (slTemp[i] = 'Steel') then begin
						tempRecord := MainRecordByEditorID(gbs(ote(slFiles.Objects[0]), 'ARMO'), ('Armor'+slTemp[i]+itemType));
					end else begin
						tempRecord := MainRecordByEditorID(gbs(ote(slFiles.Objects[0]), 'ARMO'), ('Armor'+slTemp[i]+itemType+'A'));
					end;
					{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] tempRecord := '+EditorID(tempRecord));
					if Assigned(tempRecord) and not slContains(slItem, EditorID(tempRecord)) then
						slItem.AddObject(EditorID(tempRecord), TObject(tempRecord));
				end;					
			end;
		end else begin
			if (itemType = 'Circlet') then begin
				for i := 1 to 10 do begin
					tempRecord := ebEDID(gbs(ote(slFiles.Objects[0]), 'ARMO'), 'ClothesCirclet0'+IntToStr(i));
					if Assigned(tempRecord) and not slContains(slItem, EditorID(tempRecord)) then
						slItem.AddObject(EditorID(tempRecord), TObject(tempRecord));
				end;
			end else if (itemType = 'Necklace') then begin
				slTemp.CommaText := 'Gold, GoldDiamond, GoldGems, GoldRuby, Silver, SilverEmerald, SilverGems, SilverSapphire';
				for i := 0 to slTemp.Count-1 do begin
					tempRecord := ebEDID(gbs(ote(slFiles.Objects[0]), 'ARMO'), 'JewelryNecklace'+slTemp[i]);
					if Assigned(tempRecord) and not slContains(slItem, EditorID(tempRecord)) then
						slItem.AddObject(EditorID(tempRecord), TObject(tempRecord));
				end;
			end else if (itemType = 'Ring') then begin
				slTemp.CommaText := 'Gold, GoldDiamond, GoldEmerald, GoldSapphire, Silver, SilverAmethyst, SilverGarnet, SilverRuby';
				for i := 0 to slTemp.Count-1 do begin
					tempRecord := ebEDID(gbs(ote(slFiles.Objects[0]), 'ARMO'), 'JewelryRing'+slTemp[i]);
					if Assigned(tempRecord) and not slContains(slItem, EditorID(tempRecord)) then
						slItem.AddObject(EditorID(tempRecord), TObject(tempRecord));
				end;
			end;
		end;
	end;
	{Debug} if debugMsg then msgList('[Tier Assignment] slItem := ', slItem, '');
////////////////////////////////////////////////////////////////////// TIER DETECTION //////////////////////////////////////////////////////////////////////////////////////
	// Replace EditorID with GameValue once tiers are assigned
	{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] Replace EditorID with GameValue');
	for i := 0 to slItem.Count-1 do
		slItem[i] := GetGameValue(ote(slItem.Objects[i]));
	// Checks the selected item against the tier list in order to assign the tier	  
	if Assigned(itemType) and Assigned(slItem) and (slItem.Count > 0) then begin
		// Assigns the relevant value (Armor/Damage/Value) of the selected record
		slItem.Sort;
		recordValue := GetGameValue(aRecord);
		{Debug} if debugMsg then msg('[GetTemplate] [Tier Detection] aRecord := '+EditorID(aRecord));
		{Debug} if debugMsg then msg('[GetTemplate] [Tier Detection] GameValueType := '+GetGameValueType(aRecord));
		{Debug} if debugMsg then msg('[GetTemplate] [Tier Detection] recordValue := '+IntToStr(recordValue));
		{Debug} if debugMsg then msgList('[Tier Detection] slItem := ', slItem, '');

		// Assigns Item Tier based on the relevant value
		{Debug} if debugMsg then for i := 0 to slItem.Count-1 do msg(slItem[i]);
		for i := 0 to slItem.Count-1 do begin {Debug} if debugMsg and not ((i+1) > slItem.Count-1) then msg('[GetTemplate] [Tier Detection] recordValue := '+IntToStr(recordValue)+' < StrToInt(slItem[i+1]) := '+slItem[i+1]); {Debug} if debugMsg then msg('[GetTemplate] [Tier Detection] slItem.Count-1 := '+IntToStr(slItem.Count-1)+' i := '+IntToStr(i));
			// This checks the value of the selected record against the value of the next tier
			// Example: Iron Sword.  This checks if the damage value of the iron sword is less than i+1 (the next tier).  
			// The value of an iron sword is less than i+1 (steel). Therefore the sword is tier i (Iron).  
			// The length() part is due to how TStringLists sort.  They sort by the first digit first.  Example:  2,3,4,10,11,12 would sort as 10,11,12,2,3,4.  
			// If a sword is 1-9 damage it has length = 1 so it will skip 10, 11, 12, and then start checking at 2.
			// Min and max length are also useful for checking if the record value has fewer digits than the minimum or more than the maximum
			if (i+1) > slItem.Count-1 then Break; 
			if (recordValue < (StrToInt(slItem[i+1]))) and (length(IntToStr(recordValue)) = Length(slItem[i])) then begin
				// msg('['+record_full+'] '+record_full+' assigned '+full(ote(slItem.Objects[i]))+' template');
				{Debug} if debugMsg then msg('[GetTemplate] Result := '+EditorID(ote(slItem.Objects[i])));
				Result := ote(slItem.Objects[i]);
				Break;
			end else if (recordValue = StrToInt(slItem[i+1])) and (length(IntToStr(recordValue)) = Length(slItem[i+1])) then begin
				// msg('['+record_full+'] '+record_full+' assigned '+full(ote(slItem.Objects[i]))+' template');
				{Debug} if debugMsg then msg('[GetTemplate] Result := '+EditorID(ote(slItem.Objects[i])));
				Result := ote(slItem.Objects[i]);
				Break;		  
			end;
			// This checks the max and min length of the values in the TStringList.
			// Example: 9 damage sword.  But tier i is 8 damage and tier i+1 is 10 damage.  
			// In this case the section above won't assign the tier because 9 > 8 and length(9) =/= length(10).
			slItemMaxValue := Max(StrToInt(slItem[i]), slItemMaxValue);
			slItemMaxLength := Max(Length(slItem[i]), slItemMaxLength);
			slItemMinLength := Min(Length(slItem[i]), slItemMinLength);
		end;
		
		// Fringe cases for Item Tiers
		if not Assigned(Result) then begin
		// For item values greater than i but length less than i+1.
			if (Length(recordValue) >= slItemMinLength) and (Length(recordValue) < slItemMaxLength) then begin
				for i := 0 to slItem.Count-1 do begin
					if Length(IntToStr(recordValue)) = Length(slItem[i]) then begin
						// msg('['+record_full+'] '+record_full+' assigned '+full(ote(slItem.Objects[i]))+' template');
						{Debug} if debugMsg then msg('[GetTemplate] Result := '+EditorID(ote(slItem.Objects[i])));
						Result := ote(slItem.Objects[i]);
					end;
				end;	
			// For item values greater than the maximum (Daedric/Dragonscale/GoldDiamond/etc.)
			end else if (recordValue > slItemMaxValue) then begin
				// msg('['+record_full+'] '+record_full+' assigned '+full(ote(slItem.Objects[slItem.Count-1]))+' template');
				{Debug} if debugMsg then msg('[GetTemplate] Result := '+EditorID(ote(slItem.Objects[slItem.Count-1])));
				if (slItem.Count-1 >= 0) then
					Result := ote(slItem.Objects[slItem.Count-1]);
			// For item values with fewer digits than the minimum (e.x. min armor is 10 but item armor is 1)
			end else if Length(IntToStr(recordValue)) < slItemMinLength then begin  
				// msg('['+record_full+'] '+record_full+' assigned '+full(ote(slItem.Objects[0]))+' template');
				{Debug} if debugMsg then msg('[GetTemplate] Result := '+EditorID(ote(slItem.Objects[0])));
				if (slItem.Count-1 >= 0) then
					Result := ote(slItem.Objects[0]);
			// For item values with more digits than the maximum (e.x. max armor is 10 but item armor is 100)
			end else if Length(IntToStr(recordValue)) > slItemMaxLength then begin
				// msg('['+record_full+'] '+record_full+' assigned '+full(ote(slItem.Objects[slItem.Count-1]))+' template');
				{Debug} if debugMsg then msg('[GetTemplate] Result := '+EditorID(ote(slItem.Objects[slItem.Count-1])));
				if (slItem.Count-1 >= 0) then
					Result := ote(slItem.Objects[slItem.Count-1]);   
			end else msg('[ERROR] [GetTemplate] Game Value is out of bounds');  // This should not display under any circumstances
		end;    
	end;
	
	// Finalize
	stopTime := Time;
	if ProcessTime then
		addProcessTime('GetTemplate', TimeBtwn(startTime, stopTime));
	slFiles.Free;
	slTemp.Free;
	slItem.Free;
	slBOD2.Free;
end;

// Gets a HexFormID
function HexFormID(e: IInterface): String;
begin
	Result := IntToHex(GetLoadOrderFormID(e), 8);
end;

// Adds requirement 'HasPerk' to Conditions list [SkyrimUtils]
function addPerkCondition(aList: IInterface; aPerk: IInterface): IInterface;
var
  newCondition, tempRecord: IInterface;
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := False;
  if not (Name(aList) = 'Conditions') then begin
    if sig(aList) = 'COBJ' then begin // record itself was provided
      tempRecord := ebp(aList, 'Conditions');
      if not Assigned(tempRecord) then begin
        Add(aList, 'Conditions', True);
        aList := ebp(aList, 'Conditions');
        newCondition := ebi(aList, 0); // xEdit will create dummy condition if new list was added
      end else
        aList := tempRecord;
    end;
  end;
  if not Assigned(newCondition) then
    newCondition := ElementAssign(aList, HighInteger, nil, false);
  // set type to Equal to
  SetElementEditValues(newCondition, 'CTDA - \Type', '10000000');
  // set some needed properties
	SetElementEditValues(ebp(newCondition, 'CTDA'), 'Type', '10000000');
	SetElementEditValues(ebp(newCondition, 'CTDA'), 'Comparison Value', '1');
  SetElementEditValues(ebp(newCondition, 'CTDA'), 'Function', 'HasPerk'); 
  SetElementEditValues(ebp(newCondition, 'CTDA'), 'Perk', GetEditValue(aPerk));
  SetElementEditValues(ebp(newCondition, 'CTDA'), 'Run On', 'Subject');
  SetElementEditValues(ebp(newCondition, 'CTDA'), 'Parameter #3', '-1');	
  removeInvalidEntries(aList);
  Result := newCondition;
	debugMsg := False;
// End debugMsg section
end;


// Gets the relevant game value
function GetGameValue(aRecord: IInterface): String;
var
  slTemp: TStringList;
  i: Integer;
begin
	// Initialize
  slTemp := TStringList.Create;	

	// Function
  slTemp.CommaText := 'Circlet, Ring, Necklace';
  if (sig(aRecord) = 'ARMO') then begin
		for i := 0 to slTemp.Count-1 do begin
			if StrWithinStr(full(aRecord), slTemp[i]) or StrWithinStr(ItemKeyword(aRecord), slTemp[i]) or HasKeyword(aRecord, ('Clothing'+slTemp[i])) then begin 
				Result := geev(aRecord, 'DATA\Value');
				Exit
			end;
		end;
		Result := StrPosCopy(geev(aRecord, 'DNAM'), '.', True);
		Exit;
  end else if (sig(aRecord) = 'AMMO') then begin
		Result := StrPosCopy(geev(aRecord, 'DATA\Damage'), '.', True);
		Exit;
  end else begin
		Result := geev(aRecord, 'DATA\Damage');
		Exit;
	end;
	
	// Finalize
	slTemp.Free;
end;

// Gets the relevant game value type
function GetGameValueType(inputRecord: IInterface): String;
var
  slTemp: TStringList;
  i: Integer;
begin
	// Initialize
  slTemp := TStringList.Create;
	
	//Function
  slTemp.CommaText := 'Circlet, Ring, Necklace';
  if sig(inputRecord) = 'ARMO' then begin
		for i := 0 to slTemp.Count-1 do begin
			if StrWithinStr(geev(inputRecord, 'FULL'), slTemp[i]) or StrWithinStr(ItemKeyword(inputRecord), slTemp[i]) or (ItemKeyword(inputRecord) = ('Clothing'+slTemp[i])) then begin
				Result := 'DATA\Value';
				Exit;
			end;
		end;
		Result := 'DNAM';
		Exit;
	end else begin
		Result := 'DATA\Damage';
		Exit;
	end;
	
	// Finalize
	slTemp.Free;
end;

// Removes spaces from a string
function RemoveSpaces(inputString: String): String;
var
  debugMsg: Boolean;
  tempString: String;
begin
// Begin debugMsg Section
  debugMsg := False; {Debug} if debugMsg then msg('[RemoveSpaces] Trim(inputString := '+inputString+')');
  Trim(inputString); {Debug} if debugMsg then msg('[RemoveSpaces] tempString := inputString);');
  while (rPos(inputString, ' ') > 0) do begin 
    {Debug} if debugMsg then msg('[RemoveSpaces] while (rPos(inputString, ' ') := '+IntToStr(rPos(inputString, ' '))+' > 0) do begin');
    {Debug} if debugMsg then msg('[RemoveSpaces] inputString := '+inputString);
		{Debug} if debugMsg then msg('[RemoveSpaces] tempString := '+tempString);
    Delete(inputString, rPos(inputString, ' '), 1);
  end; 
	{Debug} if debugMsg then msg('Result := '+inputString);
  Result := inputString;
  debugMsg := False;
// End debugMsg Section
end;

// Checks if a level list contains a record
function LLcontains(aLevelList, aRecord: IInterface): Boolean;
var
  debugMsg: Boolean;
  i: Integer;
begin
// Begin debugMsg Section
  debugMsg := False;
  Result := False;
	{Debug} if debugMsg then msg('[LLcontains] LLcontains( '+EditorID(aLevelList)+', '+EditorID(aRecord)+' );');
  for i := 0 to Pred(LLec(aLevelList)) do begin
		{Debug} if debugMsg then msg('[LLcontains] LLebi := '+EditorID(LLebi(aLevelList, i)));
		if StrWithinStr(EditorID(LLebi(aLevelList, i)), EditorID(aRecord)) then begin
			{Debug} if debugMsg then msg('[LLcontains] if '+EditorID(LLebi(aLevelList, i))+' = '+EditorID(aRecord)+' then begin');
			{Debug} if debugMsg then msg('[LLcontains] Result := True');
		  Result := True;
			Exit;
	  end;
  end;
	if debugMsg then msg('[LLcontains] Result := False');
	debugMsg := False;
// End debugMsg Section
end;

// Removes a LL entry; Returns removed element
function LLremove(aLevelList, aRecord): IInterface;
var
	debugMsg: Boolean;
	i: Integer;
begin
	for i := 0 to Pred(LLec(aLevelList)) do begin
		if StrWithinStr(LLebi(aLevelList, i), EditorID(aRecord)) then begin
			Result := LLebi(aLevelList, i);
			Remove(ebi(ebp(aLevelList, 'Leveled List Entries'), i));
		end;	
	end;
end;

// Finds the nth record in a level list
function IndexOfLL(aLevelList, aRecord): Integer;
var
  debugMsg: Boolean;
  i: Integer;
begin
// Begin debugMsg Section
  debugMsg := False;
  Result := False;
  for i := 0 to Pred(LLec(aLevelList)) do begin
	  if debugMsg then msg('[IndexOfLL] if '+geev(ebi(ebp(aLevelList, 'Leveled List Entries'), i), 'LVLO\Reference')+', '+ShortName(aRecord)+' then begin');
	  if StrWithinStr(geev(ebi(ebp(aLevelList, 'Leveled List Entries'), i), 'LVLO\Reference'), EditorID(aRecord)) then begin
		  Result := i;
			Exit;
	  end;
  end;
	debugMsg := False;
// End debugMsg Section
end;

// Replaces aRecord with bRecord in aLevelList; Adds bRecord to aLevelList if aRecord is not detected; Returns true if replaced, false if added
function LLreplace(aLevelList, aRecord, bRecord: IInterface): Boolean;
var
  debugMsg: Boolean;
  i: Integer;
begin
// Begin debugMsg Section
  debugMsg := False;
	
  Result := False;
  for i := 0 to Pred(LLec(aLevelList)) do begin
		if debugMsg then msg('[LLreplace] '+geev(ebi(ebp(aLevelList, 'Leveled List Entries'), i), 'LVLO\Reference'));
	  if StrWithinStr(geev(ebi(ebp(aLevelList, 'Leveled List Entries'), i), 'LVLO\Reference'), EditorID(aRecord)) then begin
			if debugMsg then msg('[LLreplace] SetEditValue( '+geev(ebi(ebp(aLevelList, 'Leveled List Entries'), i), 'LVLO\Reference')+', '+ShortName(bRecord)+');');
			SetEditValue(ebp(ebi(ebp(aLevelList, 'Leveled List Entries'), i), 'LVLO\Reference'), ShortName(bRecord));
			Result := True;
			if debugMsg then msg('[LLreplace] '+EditorID(LLebi(aLevelList, i))+' = '+EditorID(aRecord));
			if debugMsg then msg('[LLreplace] Result := True');
	  end;
  end;
	if not (Result = True) then begin
	  addToLeveledList(aLevelList, bRecord, 1);
		if debugMsg then msg('[LLreplace] addToLeveledList( '+EditorID(aLevelList)+', '+EditorID(bRecord)+', 1);');
	end;

	debugMsg := False;
// End debugMsg Section
end;

// Check a records Flags for aFlag
function FlagCheck(aRecord: IInterface; aFlag: String): Boolean;
var
  debugMsg: Boolean;
begin
  Result := False;
	if ee(aRecord, 'LVLF') then // If this record has a 'Flags' section
	  if ee(ebp(aRecord, 'LVLF'), aFlag) then // If this record has the flag, 'aFlag'
		  Result := GetElementNativeValues(ebp(aRecord, 'LVLF'), aFlag); // Return an integer value for this flag.  IIRC it's a binary for Flag on/off
end;

// Creates new record inside provided file [Skyrim Utils]
function createRecord(recordFile: IwbFile; recordSignature: string): IInterface;
var
  newRecordGroup: IInterface;
begin
  newRecordGroup := gbs(recordFile, recordSignature);
  if not Assigned(newRecordGroup) then
    newRecordGroup := Add(recordFile, recordSignature, true);
  Result := Add(newRecordGroup, recordSignature, true);
end;

// Removes invalid entries from containers and recipe items, from Leveled lists, npcs and spells [SkyrimUtils]
Procedure removeInvalidEntries(aRecord: IInterface);
var
  i, aList_ec: integer;
  aList, tempRecord: IInterface;
  record_sig, refName, countname: String;
begin
  record_sig := sig(aRecord);
  if (record_sig = 'CONT') or (record_sig = 'COBJ') then begin
    aList := ElementByName(aRecord, 'Items');
    refName := 'CNTO\Item';
    countname := 'COCT';
  end else if (record_sig = 'LVLI') or (record_sig = 'LVLN') or (record_sig = 'LVSP') then begin
    aList := ElementByName(aRecord, 'Leveled List Entries');
    refName := 'LVLO\Reference';
    countname := 'LLCT';
  end else if record_sig = 'OTFT' then begin
    aList := ElementByName(aRecord, 'INAM');
    refName := 'item';
  end;
  if not Assigned(aList) then
    Exit;
  aList_ec := ec(aList);
  for i := aList_ec-1 downto 0 do begin
    tempRecord := ebi(aList, i);
    if Check(ElementByPath(tempRecord, refName)) <> '' then
      Remove(tempRecord);
  end;
  if Assigned(countname) then begin
    if (aList_ec <> ec(aList)) then begin
      aList_ec := ec(aList);
      if (aList_ec > 0) then
        senv(aRecord, countname, aList_ec)
      else
        RemoveElement(aRecord, countname);
    end;
  end;
end;

// Adds item record reference to the list [SkyrimUtils]
function addItem(aRecord: IInterface; aItem: IInterface; aCount: integer): IInterface;
var
  tempRecord: IInterface;
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := False;
	
	if not Assigned(ebp(aRecord, 'Items')) then
		Add(aRecord, 'Items', True);
	tempRecord := ElementAssign(ebp(aRecord, 'Items'), HighInteger, nil, False);
	seev(tempRecord, 'CNTO - Item\Item', Name(aItem));
	seev(tempRecord, 'CNTO - Item\Count', aCount);
	Result := tempRecord;
	
	debugMsg := False;
// End debugMsg section
end;

// Adds item reference to the leveled list [SkyrimUtils]
function addToLeveledList(aLeveledList, aRecord: IInterface; aLevel: integer): IInterface;
var
  tempRecord: IInterface;
	debugMsg: Boolean;
begin
// Begin debugMgs section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[addToLeveledList] addToLeveledList( '+EditorID(aLeveledList)+', '+EditorID(aRecord)+', '+IntToStr(aLevel)+' );');
  tempRecord := ElementAssign(ebp(aLeveledList, 'Leveled List Entries'), HighInteger, nil, False);
	seev(tempRecord, 'LVLO\Reference', Name(aRecord));
  seev(tempRecord, 'LVLO\Count', 1);
  seev(tempRecord, 'LVLO\Level', aLevel);
  Result := tempRecord;
	
	debugMsg := False;
// End debugMsg section
end;

// Creates COBJ record for item [SkyrimUtils]
function createRecipe(aRecord, aPlugin: IInterface): IInterface;
var
  recipe: IInterface;
begin
  recipe := createRecord(aPlugin, 'COBJ');
  SetElementEditValues(recipe, 'CNAM', Name(aRecord));
  SetElementEditValues(recipe, 'NAM1', '1');
	Add(aRecord, 'items', True);
  Result := recipe;
end;

// Gets an item type for slFuzzyItem
function GetItemType(aRecord: IInterface): String;
var
	debugMsg: Boolean;
	slTemp, slBOD2: TStringList;
	i: Integer;
begin
// End debugMsg section
	debugMsg := False;
	
	// Initialize
	{Debug} if debugMsg then msg('[GetItemType] GetItemType( '+EditorID(aRecord)+' );');
	slTemp := TStringList.Create;
	slBOD2 := TStringList.Create;

	// Function
	if (sig(aRecord) = 'WEAP') then begin
		slTemp.CommaText := 'Sword, Bow, WarAxe, Dagger, Greatsword, Mace, Warhammer, Battleaxe';
		// Prioritize keywords
		for i := 0 to slTemp.Count-1 do begin
			if HasKeyword(aRecord, 'WeapType'+slTemp[i]) then begin
				Result := slTemp[i];
				if debugMsg then msg('[GetItemType] '+Result+' Detected');
				slTemp.Free;
				slBOD2.Free;
				Exit;
			end;
		end;
		// Check edid/full for keywords
		for i := 0 to slTemp.Count-1 do begin
			if StrWithinStr(full(aRecord), slTemp[i]) or StrWithinStr(EditorID(aRecord), slTemp[i]) then begin
				// Exception for the string 'Sword' being within the string 'Greatsword'
				if (slTemp[i] = 'Sword') then
					if StrWithinStr(full(aRecord), 'Greatsword') or StrWithinStr(EditorID(aRecord), 'Greatsword') then
						Continue;
				Result := slTemp[i];
				if debugMsg then msg('[GetItemType] '+Result+' Detected');
				slTemp.Free;
				slBOD2.Free;
				Exit;
			end;
		end;
		// Broad Default values based on skill/animation style
		if StrWithinStr(GetEditValue(ebp(ElementBySignature(aRecord, 'DNAM'), 'Animation Type')), 'TwoHand') or StrWithinStr(GetEditValue(ebp(ElementBySignature(aRecord, 'DNAM'), 'Skill')), 'TwoHand') then begin
			Result := slTemp[slTemp.Count-1];
		end else if StrWithinStr(GetEditValue(ebp(ElementBySignature(aRecord, 'DNAM'), 'Animation Type')), 'Bow') or StrWithinStr(GetEditValue(ebp(ElementBySignature(aRecord, 'DNAM'), 'Skill')), 'Archery') then begin
			Result := slTemp[1];
		end else begin
			Result := slTemp[0];
		end;
	end else if (sig(aRecord) = 'AMMO') then begin
		// Get selected record type
		slTemp.CommaText := 'Arrow, Bolt';
		// Prioritize keywords
		for i := 0 to slTemp.Count-1 do begin
			if HasKeyword(aRecord, 'WeapType'+slTemp[i]) then begin
				Result := slTemp[i];
				if debugMsg then msg('[GetItemType] '+Result+' Detected');
				slTemp.Free;
				slBOD2.Free;
				Exit;
			end;
		end;
		// Check edid/full for keywords
		for i := 0 to slTemp.Count-1 do begin
			if StrWithinStr(full(aRecord), slTemp[i]) or StrWithinStr(EditorID(aRecord), slTemp[i]) then begin
				Result := slTemp[i];
				if debugMsg then msg('[GetItemType] '+Result+' Detected');
				slTemp.Free;
				slBOD2.Free;
				Exit;
			end;
		end;
		// Broad default value
		Result := slTemp[0];
	end else if (sig(aRecord) = 'ARMO') then begin
		// '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
		slGetFlagValues(aRecord, slBOD2, False);
		{Debug} if debugMsg then msgList('[Tier Assignment] slBOD2 := ', slBOD2, '');
		slTemp.CommaText := '30, 32, 33, 37, 39, 35, 36, 42'; // 30 - Head, 32 - Body, 33 - Gauntlets, 37 - Feet, 39 - Shield, 35 - Necklace, 36 - Ring, 42 - Circlet
		// For vanilla slots
		for i := 0 to slTemp.Count-1 do begin
			if slContains(slBOD2, slTemp[i]) then begin
				// This 'if' covers certain mods that change helmet BOD2
				if (slTemp[i] = '42') then
					if Assigned(ebp(aRecord, 'DNAM')) then
						if (geev(aRecord, 'DNAM') > 0) then
							Result := '30';
				if not Assigned(Result) then
					Result := slTemp[i];
				Break;
			end;
		end;
		// Non-vanilla slots prioritize keywords
		if debugMsg then msg('[GetItemType] Non-vanilla slots prioritize keywords');
		if (Result = '') then begin
			{Debug} if debugMsg then msg('[GetTemplate] Check Keywords');
			for i := 0 to Pred(ec(ebp(aRecord, 'KWDA'))) do begin
				{Debug} if debugMsg then msg('[GetTemplate] Keyword := '+GetEditValue(ebi(ebp(aRecord, 'KWDA'), i)));
				Result := KeywordToBOD2(GetEditValue(ebi(ebp(aRecord, 'KWDA'), i)));
				if (Result <> '') then Break;
			end;
		end;
		// Default BOD2 for items without keywords
		if debugMsg then msg('[GetItemType] Default BOD2 for items without keywords');
		if (Result = '') then begin
			{Debug} if debugMsg then msg('[GetTemplate] Check Non-Vanilla BOD2');
			// Helmet
			slTemp.CommaText := '31, 41, 55, 130, 131, 141, 150, 230'; 
			for i := 0 to slTemp.Count-1 do
				if slContains(slBOD2, slTemp[i]) then
					Result := '30';
			// Body
			slTemp.CommaText := '38, 40, 46, 49, 52, 53, 54, 56';
			for i := 0 to slTemp.Count-1 do
				if slContains(slBOD2, slTemp[i]) then
					Result := '32';
			// Gauntlets
			slTemp.CommaText := '38, 58, 57, 59';
			for i := 0 to slTemp.Count-1 do
				if slContains(slBOD2, slTemp[i]) then
					Result := '37';		
			// Boots
			slTemp.CommaText := '34';
			for i := 0 to slTemp.Count-1 do
				if slContains(slBOD2, slTemp[i]) then
					Result := '33';							
			// Circlet
			slTemp.CommaText := '43, 142';
			for i := 0 to slTemp.Count-1 do begin
				if slContains(slBOD2, slTemp[i]) then begin
					Result := '42';
					if Assigned(ebp(aRecord, 'DNAM')) then
						if (geev(aRecord, 'DNAM') > 0) then
							Result := '30';	
				end;
			end;
			// Necklace
			slTemp.CommaText := '44, 45, 47, 143';
			for i := 0 to slTemp.Count-1 do
				if slContains(slBOD2, slTemp[i]) then
					Result := '35';
			// Ring
			slTemp.CommaText := '48, 60';
			for i := 0 to slTemp.Count-1 do
				if slContains(slBOD2, slTemp[i]) then
					Result := '36';
		end;
		// Convert BOD2 to EditorID
		{Debug} if debugMsg then msg('[GetTemplate] Convert BOD2 to EditorID');
		slTemp.CommaText := '30-Helmet, 32-Cuirass, 33-Gauntlets, 37-Boots, 39-Shield, 35-Necklace, 36-Ring, 42-Circlet'; // 30 - Head, 32 - Body, 33 - Gauntlets, 37 - Feet, 39 - Shield, 35 - Necklace, 36 - Ring, 42 - Circlet
		for i := 0 to slTemp.Count-1 do begin
			if StrWithinStr(slTemp[i], Result) then begin
				Result := StrPosCopy(slTemp[i], '-', False);
				// msg('['+full(aRecord)+'] '+Result+' Detected');
				Break;
			end;
		end;		
	end;
			
	// Finalize
	slTemp.Free;
	
	debugMsg := False;
// End debugMsg section
end;

// Reduces a BOD2 to an associated BOD2
function AssociatedBOD2(aString: String): String;
var
	slTemp: TStringList;
	i: Integer;
begin
	slTemp := TStringList.Create;
	
	Result := aString;
	// Helmet
	slTemp.CommaText := '31, 41, 55, 130, 131, 141, 150, 230'; 
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '30';
	// Body
	slTemp.CommaText := '38, 40, 46, 49, 52, 53, 54, 56';
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '32';
	// Gauntlets
	slTemp.CommaText := '38, 58, 57, 59';
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '37';		
	// Boots
	slTemp.CommaText := '34';
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '33';							
	// Circlet
	slTemp.CommaText := '43, 142';
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '42';
	// Necklace
	slTemp.CommaText := '44, 45, 47, 143';
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '35';
	// Ring
	slTemp.CommaText := '48, 60';
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '36';
			
	slTemp.Free;
end;

// Takes a single armor keyword and returns a list of all keywords related to it
Procedure slFuzzyItem(aString: String; aList: TStringList);
var
  slTemp: TStringList;
  debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg Section
  debugMsg := False;
	
	// Initialize
	{Debug} if debugMsg then msg('[slFuzzyItem] inputString := '+aString);
  if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
	
	// Function
	slTemp.CommaText := 'Helmet, Crown, Helm, Hood, Mask, Circlet, Headdress';
  for i := 0 to slTemp.Count-1 do if aString = slHelmet[i] then 
		if not slContains(aList, slHelmet[i]) then
			aList.Add(slHelmet[i]);
	slTemp.CommaText := 'Bracers, Gloves, Gauntlets';
  for i := 0 to slTemp.Count-1 do if aString = slGauntlets[i] then 
		if not slContains(aList, slGauntlets[i]) then
			aList.Add(slGauntlets[i]);
  slTemp.CommaText := 'Boots, Shoes';
	for i := 0 to slTemp.Count-1 do if aString = slBoots[i] then 
		if not slContains(aList, slBoots[i]) then
			aList.Add(slBoots[i]);
  slTemp.CommaText := 'Cuirass, Armor';
	for i := 0 to slTemp.Count-1 do if aString = slCuirass[i] then 
		if not slContains(aList, slCuirass[i]) then
			aList.Add(slCuirass[i]);
	slTemp.CommaText := 'Shield, Buckler';
	for i := 0 to slTemp.Count-1 do if aString = slShield[i] then 
		if not slContains(aList, slShield[i]) then
			aList.Add(slShield[i]);
	{Debug} if debugMsg then msgList('[slFuzzyItem] Result := ', aList, '');
	
	// '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
	// Finalize
	slTemp.Free;
	
	debugMsg := False;
// End debugMsg Section
end;

// Reduces a list of armor keywords into a single armor keyword
function GetFuzzyItem(aString: String): String;
var
  slTemp: TStringList;
  debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg Section
  debugMsg := False;
	
	// Initialize
	{Debug} if debugMsg then msg('[slFuzzyItem] inputString := '+aString);
  if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
	
	// Function
	slTemp.CommaText := 'Helmet, Crown, Helm, Hood, Mask, Circlet, Headdress';
  for i := 0 to slTemp.Count-1 do if aString = slHelmet[i] then begin
		Result := 'Helmet';
		slTemp.Free;
		Exit;
	end;
  slTemp.CommaText := 'Bracers, Gloves, Gauntlets';
	for i := 0 to slTemp.Count-1 do if aString = slGauntlets[i] then begin
		Result := 'Gauntlets';
 		slTemp.Free;
		Exit;
	end; 
	slTemp.CommaText := 'Boots, Shoes';
	for i := 0 to slTemp.Count-1 do if aString = slBoots[i] then begin
		Result := 'Boots';
		slTemp.Free;
		Exit;
	end;  
	slTemp.CommaText := 'Cuirass, Armor';
	for i := 0 to slTemp.Count-1 do if aString = slCuirass[i] then begin
		Result := 'Cuirass';
		slTemp.Free;
		Exit;
	end;	
	slTemp.CommaText := 'Shield, Buckler';
	for i := 0 to slTemp.Count-1 do if aString = slShield[i] then begin
		Result := 'Shield';
		slTemp.Free;
		Exit;
	end;	
	{Debug} if debugMsg then msgList('[slFuzzyItem] Result := ', aList, '');
	
	// Finalize
	if Assigned(slTemp) then slTemp.Free;
	
	debugMsg := False;
// End debugMsg Section
end;

// Adds a TStringList to an msg on a single line
Procedure msgList(s1: String; aList: TStringList; s2: String);
var
  debugMsg: Boolean;
  i: Integer;
  tempString: String;
begin
// Begin debugMsg section
	debugMsg := False;
	
  if not Assigned(aList) or (aList.Count = 0) then begin
	  msg(s1+'EMPTY LIST'+s2);
	  Exit;
	end;
  for i := 0 to aList.Count-1 do begin
		if (i = 0) then begin
			tempString := aList[0];
		end else begin
			tempString := tempString+', '+aList[i];
		end;
	end;
  msg(s1+tempString+s2);
	
	debugMsg := False;
// End debugMsg section
end;

// Adds a TStringList and its objects to an msg on a single line
Procedure msgListObject(s1: String; aList: TStringList; s2: String);
var
  debugMsg: Boolean;
  i: Integer;
  tempString: String;
begin
// Begin debugMsg section
	debugMsg := False;
	
  if not Assigned(aList) or (aList.Count = 0) then begin
	  msg(s1+'EMPTY LIST'+s2);
	  Exit;
	end;
  for i := 0 to aList.Count-1 do begin
		if (i = 0) then begin
			tempString := aList[0];
		end else begin
			tempString := tempString+', '+aList[i]+' ('+varTypeAsText(aList.Objects[i])+')';
		end;
	end;
  msg(s1+tempString+s2);
	
	debugMsg := False;
// End debugMsg section
end;

// Trims all the string in a list
function TrimList(aList: TStringList): TStringList;
var
	debugMsg: Boolean;
	i: Integer;
begin
	for i := 0 to aList.Count-1 do
		aList[i] := Trim(aList[i]);
	Result := aList;
end;

// Gets ElementCount of the Leveled List Entries
function LLec(e: IInterface): Integer;
begin
	Result := ec(ebp(e, 'Leveled List Entries'));
end;

// Gets record from leveled list index
function LLebi(e: IInterface; i: Integer): IInterface;
var
 debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := False;
	{Debug} if debugMsg then msg('[LLebi] e := 'EditorID(e));
	//{Debug} if debugMsg then msg('[LLebi] ebi := '+geev(ebi(ebp(e, 'Leveled List Entries'), i), 'LVLO\Reference'));
	{Debug} if debugMsg then msg('[LLebi] Result := '+EditorID(LinksTo(ebp(ebi(ebp(e, 'Leveled List Entries'), i), 'LVLO\Reference'))));
	Result := LinksTo(ebp(ebi(ebp(e, 'Leveled List Entries'), i), 'LVLO\Reference'));
	debugMsg := False;
// End debugMsg section
end;

// Removes any file suffixes from a File Name
function RemoveFileSuffix(inputString: String): String;
var
	slTemp: TStringList;
  debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg Section
  debugMsg := False;
	// Initialize
	{Debug} if debugMsg then msg('[RemoveFileSuffix] inputString := '+inputString);
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
	
	// Function
	Result := inputString;
	slTemp.CommaText := '.esp, .esm, .exe, .esl';
	for i := 0 to slTemp.Count-1 do begin  
		{Debug} if debugMsg then msg('[RemoveFileSuffix] if StrEndsWith(inputString, '+slTemp[i]+') := '+BoolToStr(StrEndsWith(inputString, slTemp[i])));
		if StrEndsWith(inputString, slTemp[i]) then begin
			Result := RemoveFromEnd(inputString, slTemp[i]);
			{Debug} if debugMsg then msg('[RemoveFileSuffix] Result := '+inputString);
			Exit;
		end;
	end;	
	
	// Finalize
	slTemp.Free;
  debugMsg := False;
// End debugMsg Section
end;

// Removes duplicate strings in a TStringList
Procedure slRemoveDuplicates(aList: TStringList);
var
	i: Integer;
	slTemp: TStringList;
begin
	// Initialize
	slTemp := TStringList.Create;
	
	// Function
	for i := 0 to aList.Count-1 do
		if not slContains(slTemp, aList[i]) then
			slTemp.Add(aList[i]);
	if (slTemp.Count > 0) then begin
		aList.Assign(slTemp);
	end;
		
	// Finalize
	slTemp.Free;
end;

// Creates a % Chance Leveled List
function createChanceLeveledList(aPlugin: IInterface; aName: String; Chance: Integer; aRecord, aLevelList: IInterface): IInterface;
var
	chanceLevelList, nestedChanceLevelList: IInterface;
	debugMsg, tempBoolean: Boolean;
	i, tempInteger: Integer;
	slTemp: TStringList;
begin
// Begin debugMsg section
	debugMsg := False;
	// The following section can be real confusing without examples.
	// If I have a 10% chance I need a Leveled List with 9 copies of the regular item and 1 copy of the enchantment Leveled List.  In math this looks like 1/10 = 10/100 = 10%.
	// If I have a 9% chance I need a Leveled List (List A) with 9 copies of the regular item and 1 copy of the enchantment Leveled List.
	// I also need ANOTHER list (List B) with 9 copies of the regular item and 1 copy of List A.  In math this looks like 1/10 * 9/10 = 9/100 (or 9%).
	// Similarly, if I have an 11% chance I need a Leveled List (List A) with 9 copies of the regular item and 1 copy of the enchantment Leveled List.
	// I also need ANOTHER list with 8 copies of the regular item, 1 copy of List A, and 1 copy of the enchantment list.  In math this looks like 1/10 + (1/10 * 9/10) = 11/100 (or 11%).
	
	// Initialize
	if Chance = 0 then Exit;
	slTemp := TStringList.Create;
	
	// Create %chance list
	slTemp.CommaText := '"Calculate from all levels <= player''s level", "Calculate for each item in count"';
	chanceLevelList := createLeveledList(aPlugin, aName, slTemp, 0);
	
	// If it's a 100% chance we just need a single leveled list
	if Chance = 100 then begin {Debug} if debugMsg then msg('[%Chance] Chance = 100; Removing chanceLevelList and assigning aLevelList to chanceLevelList for AddToLeveledListAuto input');
		Remove(chanceLevelList);
		chanceLevelList := aLevelList;
	end else if (Length(IntToStr(Chance)) = 1) then begin {Debug} if debugMsg then msg('[%Chance] for i := 0 to Chance do addToLeveledList( '+EditorID(nestedChanceLevelList)+', '+EditorID(aLevelList)+', 1 );');
		for i := 0 to Chance do 
			addToLeveledList(nestedChanceLevelList, aLevelList, 1); {Debug} if debugMsg then msg('[%Chance] while (LLec(nestedChanceLevelList) < 10) do addToLeveledList( '+EditorID(nestedChanceLevelList)+', '+EditorID(aRecord)+', 1 );');
		while (LLec(nestedChanceLevelList) < 10) do 
			addToLeveledList(nestedChanceLevelList, aRecord, 1);
		addToLeveledList(chanceLevelList, nestedChanceLevelList, 1); {Debug} if debugMsg then msg('[%Chance] while (LLec( '+EditorID(chanceLevelList)+' ) < 10) do addToLeveledList( '+EditorID(chanceLevelList)+', '+EditorID(aRecord)+', 1 );');
		while (LLec(chanceLevelList) < 10) do 
			addToLeveledList(chanceLevelList, aRecord, 1);				  
	end else begin
		// Grab the second digit; If the second digit is 0 we don't need the nested leveled list; Example: 10, 20, 30, etc.
		{Debug} if debugMsg then msg('[%Chance] StrToInt(Copy(IntToStr(Chance), 2, 1)) := '+Copy(IntToStr(Chance), 2, 1));
		tempInteger := StrToInt(Copy(IntToStr(Chance), 2, 1));
		if (tempInteger = 0) then 
			tempBoolean := True
		else 
			tempBoolean := False;
		{Debug} if debugMsg then msg('[%Chance] tempBoolean := '+BoolToStr(tempBoolean));
		// Grab the first digit
		{Debug} if debugMsg then msg('[%Chance] StrToInt(Copy(IntToStr(Chance), 1, 1)) := '+Copy(IntToStr(Chance), 1, 1));
		tempInteger := StrToInt(Copy(IntToStr(Chance), 1, 1));
		// Create the percent chance leveled list for 10, 20, 30, etc. (numbers that don't need the nested leveled list)
		if tempBoolean then begin {Debug} if debugMsg then msg('[%Chance] if tempBoolean then begin for i := 0 to tempInteger-1 := '+IntToStr(tempInteger-1)+' do addToLeveledList( '+EditorID(chanceLevelList)+', '+EditorID(aLevelList)+', 1 ); while (LLec(chanceLevelList) :='+IntToStr(LLec(chanceLevelList))+' < 10) do addToLeveledList( '+EditorID(chanceLevelList)+', '+EditorID(aRecord)+', 1 );');
			for i := 0 to tempInteger-1 do addToLeveledList(chanceLevelList, aLevelList, 1);
				while (LLec(chanceLevelList) < 10) do 
			addToLeveledList(chanceLevelList, aRecord, 1);
		end else begin {Debug} if debugMsg then msg('[%Chance] Not tempBoolean; Beginning nested list generation');
			// Create a nested leveled list for valid integers between 0 and 100 with a second digit greater than 0.  Example: 51, 52, 53, etc.
			{Debug} if debugMsg then msg('[%Chance] Creating and preparing nestedchanceLevelList');
			nestedChanceLevelList := createLeveledList(aPlugin, Insert('nested', aName, ItPos(aName, 'e', 3)), slTemp, 0);
			// Fill the nested and chance leveled lists based on Chance
			for i := 0 to (StrToInt(Copy(IntToStr(Chance), 2, 1))-1) do 
				addToLeveledList(nestedChanceLevelList, aLevelList, 1);
			while (LLec(nestedChanceLevelList) < 10) do 
				addToLeveledList(nestedChanceLevelList, aRecord, 1);
			addToLeveledList(chanceLevelList, nestedChanceLevelList, 1);
			for i := 0 to tempInteger-1 do 
				addToLeveledList(chanceLevelList, aLevelList, 1);
			while (LLec(chanceLevelList) < 10) do 
				addToLeveledList(chanceLevelList, aRecord, 1);	
		end;
	end;
	Result := chanceLevelList;
	
	// Finalize
	slTemp.Free;
	
	debugMsg := False;
// End debugMsg section
end;

// Only first letter capitalized
function StrCapFirst(str: String): String;
var 
	str, format_str : string; 
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[StrCapFirst] '+Uppercase(Copy(str, 1 ,1))+Lowercase(Copy(str, 2, Length(str))));
	Result:= Uppercase(Copy(str, 1 ,1))+Lowercase(Copy(str, 2, Length(str))); 
	
	debugMsg := False;
// End debugMsg section
end;

// Finds a TForm element by name
function ComponentByCaption(aString: String; aForm: TForm): TObject;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[ComponentByCaption] aString := '+aString);
	for i := aForm.ComponentCount-1 downto 0 do begin
		if (aForm.Components[i].Caption = aString) then begin
			Result := aForm.Components[i];
			Exit;
		end;
	end;
	
	debugMsg := False;
// End debugMsg Section
end;

// Finds a TForm element by name
function ComponentByTop(aTop: Integer; aForm: TObject): TObject;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	for i := aForm.ComponentCount-1 downto 0 do begin
		if (aForm.Components[i].Top = aTop) then begin
			Result := aForm.Components[i];
			Exit;
		end;
	end;
	
	debugMsg := False;
// End debugMsg Section
end;

// Caption Exists on TForm element
function CaptionExists(aString: String; aForm: TObject): Boolean;
var
	Form: TForm;
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	Result := False;
	for i := aForm.ComponentCount-1 downto 0 do begin
		{Debug} if debugMsg then msg('[CaptionExists] if ( '+aForm.Components[i].Caption+' = '+aString+' ) then begin');
		if (aForm.Components[i].Caption = aString) then begin
			Result := True;
		end;
	end;
	{Debug} if debugMsg then msg('[CaptionExists] Result := '+BoolToStr(Result));
	
	debugMsg := False;
// End debugMsg section
end;

// Finds the longest common substring
function LongestCommonString(aList: TStringList): String;
var
	i, x, y, z: Integer;
	tempString: String;
	slTemp: TStringList;
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Initialize Local
	slTemp := TStringList.Create;
	
	//Function
	for i := 0 to aList.Count-1 do begin
		tempString := nil;
		slTemp.CommaText := aList[i];
		{Debug} if debugMsg then msgList('[LongestCommonString] slTemp := ', slTemp, '');
		for x := slTemp.Count-1 downto 0 do begin
			tempString := nil;
			for y := 0 to x do
				tempString := Trim(tempString+' '+slTemp[y]);
			for y := 0 to aList.Count-1 do begin
				{Debug} if debugMsg then msg('[LongestCommonString] StrWithinStr( '+aList[y]+', '+tempString+' )');
				if StrWithinStr(aList[y], tempString) and (y <> i) then begin					
					if Assigned(Result) then begin
						if (Length(tempString) > Length(Result)) then
							Result := tempString;
					end else begin
						Result := tempString;
					end;
				end;
			end;
		end;
	end;
	
	if not Assigned(Result) then
		Result := aList[0];
	
	// Finalize Local
	slTemp.Free;
	
	debugMsg := False;
// End debugMsg section
end;

function DecToRoman(Decimal: Integer): string;
var
	slNumbers, slRomans: TStringList;
	i: Integer;
begin
	// Initialize
	slNumbers := TStringList.Create;
	slRomans := TStringList.Create;
	
	slNumbers.CommaText := '1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000';
	slRomans.CommaText := 'I, IV, V, IX, X, XL, L, XC, C, CD, D, CM, M';
	Result := '';
	for i := 12 downto 0 do begin
		while (Decimal >= slNumbers[i]) do begin
			Decimal := Decimal - slNumbers[i];
			Result := Result + slRomans[i];
		end;
	end;
	
	// Finalization
	slNumbers.Free;
	slRomans.Free;
end;

// [FUNCTIONS SPECIFIC TO GENERATEENCHANTEDVERSIONSAUTO]
Procedure Btn_Bulk_OnClick(Sender: TObject);
var
	lblAddPlugin, lblDetectedFileText, lblHelp: TLabel;
	tempComponent, btnAdd, btnOk, btnCancel, btnRemove: TButton;	
	ddAddPlugin, ddDetectedFile: TComboBox;
	slTemp, slFiles: TStringList;
	ALLAfile, tempFile, tempRecord: IInterface;
	frm: TForm;
	debugMsg: Boolean;
	ALLAplugin: String;
	i, x, y: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Initialize
	slFiles := TStringList.Create;
	slTemp := TStringList.Create;
	frm := Sender.Parent;
	tempComponent := AssociatedComponent('Output Plugin: ', Sender.Parent);
	ALLAplugin := tempComponent.Caption;
	if not StrEndsWith(ALLAplugin, '.esl') or StrEndsWith(ALLAplugin, '.exe') or StrEndsWith(ALLAplugin, '.exe') then AppendIfMissing(ALLAplugin, '.esp');
	if DoesFileExist(ALLAplugin) then begin
		ALLAfile := FileByName(ALLAplugin);
	end else begin
		if MessageDlg('Create a new plugin named '+ALLAplugin+' [YES] or cancel [NO]?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
			AddNewFileName(ALLAplugin);
		end else
			Exit;			
	end;
	
	// Dialogue Box
	frm := TForm.Create(nil);
	try	
		// Remove all previous TForm components
		btnOK := nil;
		btnCancel := nil;
			
		// Parent Form; Entire Box
		frm.Width := 850;
		frm.Height := 200;
		frm.Position := poScreenCenter;
		frm.Caption := 'Process Plugins in Bulk';	

		// Currently Selected File Label
		lblDetectedFileText := TLabel.Create(frm);
		lblDetectedFileText.Parent := frm;
		lblDetectedFileText.Height := 24;
		lblDetectedFileText.Top := 68;
		lblDetectedFileText.Left := 60;
		lblDetectedFileText.Caption := 'Output File: ';
		frm.Height := frm.Height+lblDetectedFileText.Height+12;
		
		// Currently Selected File
		ddDetectedFile := TComboBox.Create(frm);
		ddDetectedFile.Parent := frm;
		ddDetectedFile.Height := lblDetectedFileText.Height;
		ddDetectedFile.Top := lblDetectedFileText.Top;		
		ddDetectedFile.Left := 205;
		ddDetectedFile.Width := 480;
		ddDetectedFile.Items.Add(ALLAplugin);
		ddDetectedFile.ItemIndex := 0;
	
		// Add Plugin Label
		lblAddPlugin := TLabel.Create(frm);
		lblAddPlugin.Parent := frm;
		lblAddPlugin.Height := lblDetectedFileText.Height;
		lblAddPlugin.Top := lblDetectedFileText.Top+lblDetectedFileText.Height+24;
		lblAddPlugin.Left := lblDetectedFileText.Left;
		lblAddPlugin.Caption := 'Add Plugin: ';
		frm.Height := frm.Height+lblAddPlugin.Height+12;
		
		// Add Plugin Drop Down
		ddAddPlugin := TComboBox.Create(frm);
		ddAddPlugin.Parent := frm;
		ddAddPlugin.Height := lblAddPlugin.Height;
		ddAddPlugin.Top := lblAddPlugin.Top - 2;		
		ddAddPlugin.Left := ddDetectedFile.Left;
		ddAddPlugin.Width := 480;
		for i := 0 to FileCount-1 do
			if not (StrEndsWith(GetFileName(FileByIndex(i)), '.exe') or slContains(slGlobal, GetFileName(FileByIndex(i)))) then
				ddAddPlugin.Items.Add(GetFileName(FileByIndex(i)));
		ddAddPlugin.AutoComplete := True;

		// Add Button
		btnAdd := TButton.Create(frm);
		btnAdd.Parent := frm;
		btnAdd.Caption := 'Add';
		btnAdd.Left := ddAddPlugin.Left+ddAddPlugin.Width+8;
		btnAdd.Top := lblAddPlugin.Top;
		btnAdd.Width := 100;
		btnAdd.OnClick := Btn_AddOrRemove_OnClick;
		
		// Ok Button
		btnOk := TButton.Create(frm);
		btnOk.Parent := frm;
		btnOk.Caption := 'Ok';		
		btnOk.Left := (frm.Width div 2)-btnOk.Width-8;
		btnOk.Top := frm.Height-80;
		btnOk.ModalResult := mrOk;
	
		// Cancel Button
		btnCancel := TButton.Create(frm);
		btnCancel.Parent := frm;
		btnCancel.Caption := 'Cancel';	
		btnCancel.Left := btnOk.Left+btnOk.Width+16;
		btnCancel.Top := btnOk.Top;	
		btnCancel.ModalResult := mrCancel;
		
		frm.ShowModal;
		// Displays a help message
		if (frm.ModalResult = mrOk) and (ddAddPlugin.Text <> '') and not CaptionExists('Remove', frm) then begin
			lblHelp := TLabel.Create(frm);
			lblHelp.Parent := frm;
			lblHelp.Height := 24;
			lblHelp.Top := btnAdd.Top + btnAdd.Height + 8;
			lblHelp.Left := btnAdd.Left - 50;
			lblHelp.Caption := 'USE ADD BUTTON';
			frm.ShowModal;
		end;
		if (frm.ModalResult = mrOk) then begin
			// If list is empty 
			if not CaptionExists('Remove', frm) then Exit;
			// Output			
			for i := 0 to slGlobal.Count-1 do
				if StrWithinStr(slGlobal[i], 'Original') or StrWithinStr(slGlobal[i], 'Template') then
					slTemp.Add(slGlobal[i]);
			for i := 0 to slTemp.Count-1 do
				if (slGlobal.IndexOf(slTemp[i]) >= 0) then
					slGlobal.Delete(slGlobal.IndexOf(slTemp[i]));
			slFiles.Assign(slGlobal);
			// Sender.Parent.Visible := False;
			tempComponent.Caption := ddDetectedFile.Text;
			slTemp.CommaText := 'ARMO, AMMO, WEAP';
			{Debug} if debugMsg then msgList('[ELLR_Bulk_OnClick] slFiles := ', slFiles, '');
			for i := 0 to slFiles.Count-1 do begin
				{Debug} if debugMsg then msg('[ELLR_Bulk_OnClick] if DoesFileExist( '+slFiles[i]+' ) := '+BoolToStr(DoesFileExist(slFiles[i]))+' then begin');
				if DoesFileExist(slFiles[i]) then begin
					tempFile := FileByName(slFiles[i]);
					{Debug} if debugMsg then msg('[ELLR_Bulk_OnClick] tempFile := '+GetFileName(tempFile));
					{Debug} if debugMsg then msg('[ELLR_Bulk_OnClick] for x := 0 to slTemp.Count-1 := '+IntToStr(slTemp.Count-1)+' do begin');
					for x := 0 to slTemp.Count-1 do begin
						{Debug} if debugMsg then msg('[ELLR_Bulk_OnClick] for y := 0 to Pred(ec(gbs( '+GetFileName(tempFile)+', '+slTemp[x]+' ))) := '+IntToStr(Pred(ec(gbs(ote(slFiles.Objects[i]), slTemp[x]))))+' do begin');		
						for y := 0 to Pred(ec(gbs(tempFile, slTemp[x]))) do begin
							{Debug} if debugMsg then msg('[ELLR_Bulk_OnClick] tempRecord := ebi(gbs( '+GetFileName(tempFile)+', '+slTemp[x]'+), '+IntToStr(x)+' );');
							tempRecord := ebi(gbs(tempFile, slTemp[x]), y);
							if not (Length(EditorID(tempRecord)) > 0) then Continue;
							{Debug} if debugMsg then msg('[ELLR_Bulk_OnClick] tempRecord := '+EditorID(tempRecord));
							if not slContains(slGlobal, EditorID(tempRecord)) then begin
								slGlobal.AddObject(EditorID(tempRecord)+'Original', TObject(tempRecord));
								slGlobal.AddObject(EditorID(tempRecord)+'Template', TObject(GetTemplate(tempRecord)));
							end;
						end;
					end;
				end;
			end;
			{Debug} if debugMsg then msgList('[ELLR_Bulk_OnClick] slGlobal := ', slGlobal, '');
			Sender.Parent.ModalResult := mrOk;
		end else begin
			tempComponent.Caption := ddDetectedFile.Text;
			slTemp.Clear;
			for i := 0 to slGlobal.Count-1 do
				if DoesFileExist(slGlobal[i]) then
					slTemp.Add(slGlobal[i]);
			for i := 0 to slTemp.Count-1 do
				if (slGlobal.IndexOf(slTemp[i]) >= 0) then
					slGlobal.Delete(slGlobal.IndexOf(slTemp[i]));		
		end;
	finally
		frm.Free;
	end;
	
	// Finalize
	slFiles.Free;
	slTemp.Free;
	
	debugMsg := False;
// End debugMsg Section
end;

Procedure Btn_AddOrRemove_OnClick(Sender: TObject);
var
	btnAdd, btnRemove, btnOk, btnCancel: TButton;
	tempBoolean, debugMsg: Boolean;
	lblPlugin: TLabel;
	i, tempInteger: Integer;
	tempPlugin: String;
	GEVfile: IInterface;
	frm: TForm;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Grab values from parent form
	frm := Sender.Parent;
	if CaptionExists('Remove Plugin: ', frm) then begin
		tempPlugin := AssociatedComponent('Remove Plugin: ', frm).Caption;
		{Debug} if debugMsg then msg('[Btn_AddOrRemove_OnClick] tempPlugin := '+tempPlugin);
	end else if CaptionExists('Add Plugin: ', frm) then begin
		tempPlugin := AssociatedComponent('Add Plugin: ', frm).Caption;
		{Debug} if debugMsg then msg('[Btn_AddOrRemove_OnClick] tempPlugin := '+tempPlugin);
	end;
	
	// Manipulate static list of added values
	{Debug} if debugMsg then msg('[Btn_AddOrRemove_OnClick] TLabel(Sender).Caption := '+TLabel(Sender).Caption);
	if (TLabel(Sender).Caption = 'Add') then begin
		tempBoolean := False;
		for i := 0 to frm.ComponentCount-1 do
			if (frm.Components[i].Top >= 160) and (frm.Components[i].Caption = tempPlugin) then
				tempBoolean := True;
		if not tempBoolean and DoesFileExist(tempPlugin) then begin
			// Expand form
			frm.Height := frm.Height+36;
			// Shift existing components down
			TShift(160, 36, frm, False);
			// Remove Button
			btnRemove := TButton.Create(frm);
			btnRemove.Parent := frm;
			btnRemove.Caption := 'Remove';
			btnRemove.Left := 70;
			btnRemove.Top := 160;
			btnRemove.Width := 100;
			btnRemove.OnClick := Btn_AddOrRemove_OnClick;			
			// Remove Plugin label
			lblPlugin := TLabel.Create(frm);
			lblPlugin.Parent := frm;
			lblPlugin.Height := 24;
			lblPlugin.Top := btnRemove.Top + 2;
			lblPlugin.Left := 205;
			lblPlugin.Caption := tempPlugin;
		end;
		slGlobal.Add(tempPlugin);
	end else if (TLabel(Sender).Caption = 'Remove') then begin
		slGlobal.Delete(slGlobal.IndexOf(ComponentByTop(Sender.Top + 2, frm).Caption));
		ComponentByTop(Sender.Top + 2, frm).Free;
		Sender.Visible := False;
		// Shift existing components up
		TShift(Sender.Top, 36, frm, True);	
		// Shrink form
		frm.Height := frm.Height-36;		
	end;
end;

Procedure GEV_Btn_Remove(Sender: TObject);
var
	lblRemovePlugin, lblDetectedFileText,lblDetectedFile: TLabel;
	btnAdd, btnOk, btnCancel, btnRemove: TButton;	
	ddRemovePlugin: TComboBox;
	slTemp: TStringList;
	GEVfile: IInterface;
	frm_Remove: TForm;
	debugMsg: Boolean;
	GEVplugin: String;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Initialize
	slTemp := TStringList.Create;
	GEVplugin := ComponentByTop(ComponentByCaption('Output Plugin: ', Sender.Parent).Top-2, Sender.Parent).Caption;
	if not StrEndsWith(GEVplugin, '.esl') then AppendIfMissing(GEVplugin, '.esp');
	if DoesFileExist(GEVplugin) then begin
		GEVfile := FileByName(GEVplugin);
	end else begin
		msg('['+full(selectedRecord)+'] '+GEVplugin+' does not exist; Cannot use ''Remove'' on unspecified plugin');
		Exit;
	end;
	
	// Dialogue Box
	frm_Remove := TForm.Create(nil);
	while not ((frm_Remove.ModalResult = mrCancel) or (frm_Remove.ModalResult = mrOk)) do begin
		frm_Remove := TForm.Create(nil);
		try	
			// Remove all previous TForm components
			btnOK := nil;
			btnCancel := nil;
				
			// Parent Form; Entire Box
			frm_Remove.Width := 850;
			frm_Remove.Height := 200;
			frm_Remove.Position := poScreenCenter;
			frm_Remove.Caption := 'Remove a Specified Master';	

			// Currently Selected File Label
			lblDetectedFileText := TLabel.Create(frm_Remove);
			lblDetectedFileText.Parent := frm_Remove;
			lblDetectedFileText.Height := 24;
			lblDetectedFileText.Top := 68;
			lblDetectedFileText.Left := 60;
			lblDetectedFileText.Caption := 'Currently Selected File: ';
			frm_Remove.Height := frm_Remove.Height+lblDetectedFileText.Height+12;
			
			// Currently Selected File
			lblDetectedFile := TLabel.Create(frm_Remove);
			lblDetectedFile.Parent := frm_Remove;
			lblDetectedFile.Height := lblDetectedFileText.Height;
			lblDetectedFile.Top := lblDetectedFileText.Top;		
			lblDetectedFile.Left := lblDetectedFileText.Left+(9*Length(lblDetectedFileText.Caption))+85;
			lblDetectedFile.Caption := GEVplugin;
		
			// Remove Plugin label
			lblRemovePlugin := TLabel.Create(frm_Remove);
			lblRemovePlugin.Parent := frm_Remove;
			lblRemovePlugin.Height := lblDetectedFileText.Height;
			lblRemovePlugin.Top := lblDetectedFileText.Top+lblDetectedFileText.Height+24;
			lblRemovePlugin.Left := lblDetectedFileText.Left;
			lblRemovePlugin.Caption := 'Remove Plugin: ';
			frm_Remove.Height := frm_Remove.Height+lblRemovePlugin.Height+12;
			
			// Remove Plugin Drop Down
			ddRemovePlugin := TComboBox.Create(frm_Remove);
			ddRemovePlugin.Parent := frm_Remove;
			ddRemovePlugin.Height := lblRemovePlugin.Height;
			ddRemovePlugin.Top := lblRemovePlugin.Top - 2;		
			ddRemovePlugin.Left := lblRemovePlugin.Left+(9*Length(lblRemovePlugin.Caption))+36;
			ddRemovePlugin.Width := 480;
			for i := 0 to Pred(MasterCount(GEVfile)) do
				if not (StrEndsWith(GetFileName(MasterByIndex(GEVfile, i)), '.esm') or StrEndsWith(GetFileName(MasterByIndex(GEVfile, i)), '.exe') or slContains(slGlobal, GetFileName(MasterByIndex(GEVfile, i)))) then
					ddRemovePlugin.Items.Add(GetFileName(MasterByIndex(GEVfile, i)));

			// Add Button
			btnAdd := TButton.Create(frm_Remove);
			btnAdd.Parent := frm_Remove;
			btnAdd.Caption := 'Add';
			btnAdd.Left := ddRemovePlugin.Left+ddRemovePlugin.Width+8;
			btnAdd.Top := lblRemovePlugin.Top;
			btnAdd.Width := 100;
			btnAdd.ModalResult := mrRetry;
			btnAdd.OnClick := Btn_AddOrRemove_OnClick;
			
			// Items to be removed
			{Debug} if debugMsg then msgList('[GEV_Btn_Remove] slGlobal := ', slGlobal, '');
			for i := 0 to slGlobal.Count-1 do begin
				if DoesFileExist(slGlobal[i]) then begin
					// Remove Plugin label
					lblRemovePlugin := TLabel.Create(frm_Remove);
					lblRemovePlugin.Parent := frm_Remove;
					lblRemovePlugin.Height := 24;
					lblRemovePlugin.Top := slGlobal.Objects[i];
					lblRemovePlugin.Left := 188;
					lblRemovePlugin.Caption := slGlobal[i];
					frm_Remove.Height := frm_Remove.Height+lblRemovePlugin.Height+12;
					
					// Remove Button
					btnRemove := TButton.Create(frm_Remove);
					btnRemove.Parent := frm_Remove;
					btnRemove.Caption := 'Remove';
					btnRemove.Left := 80;
					btnRemove.Top := slGlobal.Objects[i];
					btnRemove.Width := 100;
					btnRemove.ModalResult := mrIgnore;
					btnRemove.OnClick := Btn_AddOrRemove_OnClick;
				end;
			end;
			
			// Ok Button
			btnOk := TButton.Create(frm_Remove);
			btnOk.Parent := frm_Remove;
			btnOk.Caption := 'OK';		
			btnOk.Left := (frm_Remove.Width div 2)-btnOk.Width-8;
			btnOk.Top := frm_Remove.Height-80;
			btnOk.ModalResult := mrOk;
		
			// Cancel Button
			btnCancel := TButton.Create(frm_Remove);
			btnCancel.Parent := frm_Remove;
			btnCancel.Caption := 'Cancel';	
			btnCancel.Left := btnOk.Left+btnOk.Width+16;
			btnCancel.Top := btnOk.Top;	
			btnCancel.ModalResult := mrCancel;
			
			if (frm_Remove.ShowModal = mrOk) then begin
				for i := 0 to slGlobal.Count-1 do begin
					if DoesFileExist(slGlobal[i]) then begin
						RemoveMastersAuto(FileByName(slGlobal[i]), FileByName(GEVplugin));
						slTemp.Add(slGlobal[i]);
					end;
				end;
				for i := 0 to slTemp.Count-1 do	
					if (slGlobal.IndexOf(slTemp[i]) >= 0) then
						slGlobal.Delete(slGlobal.IndexOf(slTemp[i]));
			end;
		finally
			frm_Remove.Free;
		end;
	end;
	
	// Finalize
	slTemp.Free;
	
	debugMsg := False;
// End debugMsg Section
end;

Function Btn_ItemTierLevels_OnClick(Sender: TObject): TStringList;
var
	lblTier01, lblTier02, lblTier03, lblTier04, lblTier05, lblTier06: TLabel;
	ddTier01, ddTier02, ddTier03, ddTier04, ddTier05, ddTier06: TComboBox;
	debugMsg, tempBoolean: Boolean;
	btnOk, btnCancel: TButton;
	i, tempInteger: Integer;
	frm: TForm;
	tempObject: TObject;
begin	
	// Get Sender Parameters
	frm := Sender.Parent;
	
	if not CaptionExists('Tier 01 appears at level: ', frm) then begin
		Sender.Caption := 'Confirm Tiers';
		// Shift Components Down
		{Debug} if debugMsg then msg('[Btn_ItemTierLevels_OnClick] Shift Components Down');
		frm.Height := frm.Height + 262;
		for i := 0 to frm.ComponentCount-1 do begin
			tempObject := nil;
			if (frm.Components[i].Top > Sender.Top) then begin
				tempObject :=	frm.Components[i];
				tempInteger := tempObject.Top;
				if Assigned(tempObject) then begin
					tempObject.Top := tempObject.Top + 262;
				end;
			end;
		end;		
		// Tier 01 Label
		lblTier01 := TLabel.Create(frm);
		lblTier01.Parent := frm;
		lblTier01.Height := 24;
		lblTier01.Top := Sender.Top+Sender.Height + 18;
		lblTier01.Left := Sender.Left;
		lblTier01.Caption := 'Tier 01 appears at level: ';
		
		// Tier 01 Drop Down
    ddTier01 := TComboBox.Create(frm);
    ddTier01.Parent := frm;
		ddTier01.Height := lblTier01.Height;
    ddTier01.Top := lblTier01.Top - 2;		
    ddTier01.Left := 530;
    ddTier01.Width := 80;
		if slContains(slGlobal, 'ItemTier01') then begin
			ddTier01.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('ItemTier01')]));
		end else begin
			ddTier01.Items.Add(IntToStr(defaultItemTier01));
		end;
		ddTier01.ItemIndex := 0;
		
		// Tier 02 Label
		lblTier02 := TLabel.Create(frm);
		lblTier02.Parent := frm;
		lblTier02.Height := lblTier01.Height;
		lblTier02.Top := lblTier01.Top+lblTier01.Height + 18;
		lblTier02.Left := lblTier01.Left;
		lblTier02.Caption := 'Tier 02 appears at level: ';
		
		// Tier 02 Drop Down
    ddTier02 := TComboBox.Create(frm);
    ddTier02.Parent := frm;
		ddTier02.Height := lblTier02.Height;
    ddTier02.Top := lblTier02.Top - 2;		
    ddTier02.Left := ddTier01.Left;
    ddTier02.Width := ddTier01.Width;
		if slContains(slGlobal, 'ItemTier02') then begin
			ddTier02.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('ItemTier02')]));
		end else begin
			ddTier02.Items.Add(IntToStr(defaultItemTier02));
		end;
		ddTier02.ItemIndex := 0;
		
		// Tier 03 Label
		lblTier03 := TLabel.Create(frm);
		lblTier03.Parent := frm;
		lblTier03.Height := lblTier02.Height;
		lblTier03.Top := lblTier02.Top+lblTier02.Height + 18;
		lblTier03.Left := lblTier02.Left;
		lblTier03.Caption := 'Tier 03 appears at level: ';
		
		// Tier 03 Drop Down
    ddTier03 := TComboBox.Create(frm);
    ddTier03.Parent := frm;
		ddTier03.Height := lblTier03.Height;
    ddTier03.Top := lblTier03.Top - 2;		
    ddTier03.Left := ddTier01.Left;
    ddTier03.Width := ddTier01.Width;
		if slContains(slGlobal, 'ItemTier03') then begin
			ddTier03.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('ItemTier03')]));
		end else begin
			ddTier03.Items.Add(IntToStr(defaultItemTier03));
		end;
		ddTier03.ItemIndex := 0;
		
		// Tier 04 Label
		lblTier04 := TLabel.Create(frm);
		lblTier04.Parent := frm;
		lblTier04.Height := lblTier03.Height;
		lblTier04.Top := lblTier03.Top+lblTier03.Height + 18;
		lblTier04.Left := lblTier03.Left;
		lblTier04.Caption := 'Tier 04 appears at level: ';
		
		// Tier 04 Drop Down
    ddTier04 := TComboBox.Create(frm);
    ddTier04.Parent := frm;
		ddTier04.Height := lblTier04.Height;
    ddTier04.Top := lblTier04.Top - 2;		
    ddTier04.Left := ddTier01.Left;
    ddTier04.Width := ddTier01.Width;
		if slContains(slGlobal, 'ItemTier04') then begin
			ddTier04.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('ItemTier04')]));
		end else begin
			ddTier04.Items.Add(IntToStr(defaultItemTier04));
		end;
		ddTier04.ItemIndex := 0;
		
		// Tier 05 Label
		lblTier05 := TLabel.Create(frm);
		lblTier05.Parent := frm;
		lblTier05.Height := lblTier04.Height;
		lblTier05.Top := lblTier04.Top+lblTier04.Height + 18;
		lblTier05.Left := lblTier04.Left;
		lblTier05.Caption := 'Tier 05 appears at level: ';	
		
		// Tier 05 Drop Down
    ddTier05 := TComboBox.Create(frm);
    ddTier05.Parent := frm;
		ddTier05.Height := lblTier05.Height;
    ddTier05.Top := lblTier05.Top - 2;		
    ddTier05.Left := ddTier01.Left;
    ddTier05.Width := ddTier01.Width;
		if slContains(slGlobal, 'ItemTier05') then begin
			ddTier05.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('ItemTier05')]));
		end else begin
			ddTier05.Items.Add(IntToStr(defaultItemTier05));
		end;
		ddTier05.ItemIndex := 0;
		
		// Tier 06 Label
		lblTier06 := TLabel.Create(frm);
		lblTier06.Parent := frm;
		lblTier06.Height := lblTier05.Height;
		lblTier06.Top := lblTier05.Top+lblTier05.Height + 18;
		lblTier06.Left := lblTier05.Left;
		lblTier06.Caption := 'Tier 06 appears at level: ';	
		
		// Tier 06 Drop Down
    ddTier06 := TComboBox.Create(frm);
    ddTier06.Parent := frm;
		ddTier06.Height := lblTier06.Height;
    ddTier06.Top := lblTier06.Top-2;		
    ddTier06.Left := ddTier01.Left;
    ddTier06.Width := ddTier01.Width;
		if slContains(slGlobal, 'ItemTier06') then begin
			ddTier06.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('ItemTier06')]));
		end else begin
			ddTier06.Items.Add(IntToStr(defaultItemTier06));
		end;
		ddTier06.ItemIndex := 0;		
	end else begin
		Sender.Caption := 'Configure Tiers';
		for i := 1 to 6 do begin
			if CaptionExists('Tier 0'+IntToStr(i)+' appears at level: ', frm) then begin
				tempObject := ComponentByTop(ComponentByCaption('Tier 0'+IntToStr(i)+' appears at level: ', frm).Top-2, frm);
				if (IntWithinStr(tempObject.Text) > 0) then begin
					if not slContains(slGlobal, 'ItemTier0'+IntToStr(i)) then begin
						slGlobal.AddObject('ItemTier0'+IntToStr(i), IntWithinStr(tempObject.Text));
					end else begin
						slGlobal.Objects[slGlobal.IndexOf('ItemTier0'+IntToStr(i))] := IntWithinStr(tempObject.Text);
					end;
				end;
			end;
			tempObject := ComponentByCaption(('Tier 0'+IntToStr(i)+' appears at level: '), frm);
			tempInteger := tempObject.Top;
			if Assigned(tempObject) then
				tempObject.Free;
			tempObject := ComponentByTop(tempInteger-2, frm);
			if Assigned(tempObject) then
				tempObject.Free;
		end;
		// Shift Components Up
		{Debug} if debugMsg then msg('[Btn_ItemTierLevels_OnClick] Shift Components Up');
		frm.Height := frm.Height - 262;
		for i := 0 to frm.ComponentCount-1 do begin
			tempObject := nil;
			if (frm.Components[i].Top > Sender.Top) then begin
				tempObject :=	frm.Components[i];
				tempInteger := tempObject.Top;
				if Assigned(tempObject) then begin
					tempObject.Top := tempObject.Top - 262;
				end;
			end;
		end;		
	end;
end;

Procedure Btn_Temper_OnClick(Sender: TObject);
var
	lblTemperLight, lblTemperHeavy: TLabel;
	ddTemperLight, ddTemperHeavy: TComboBox;
	debugMsg, tempBoolean: Boolean;
	btnOk, btnCancel: TButton;
	i, tempInteger: Integer;
	slTemp: TStringList;
	frm: TForm;
	tempObject: TObject;
begin	
// Begin debugMsg section
	debugMsg := False;
	
	// Initialize
	slTemp := TStringList.Create;
	
	// Get Sender Parameters
	{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Sender := '+Sender.Caption);
	frm := Sender.Parent;
	
	slTemp.CommaText := '"# of Ingots - Light/One-Handed: ", "# of Ingots - Heavy/Two-Handed: "';
	if not CaptionExists(slTemp[0], frm) then begin
		// Shift Components Down
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Shift Components Down');
		frm.Height := frm.Height + slTemp.Count*44;
		TShift(Sender.Top+3, slTemp.Count*44, frm, False);
		Sender.Caption := 'Confirm Temper Recipe';
		// Temper Light Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Temper Light Label');
		lblTemperLight := TLabel.Create(frm);
		lblTemperLight.Parent := frm;
		lblTemperLight.Height := 24;
		lblTemperLight.Top := Sender.Top+Sender.Height + 18;
		lblTemperLight.Left := Sender.Left;
		lblTemperLight.Caption := '# of Ingots - Light/One-Handed: ';	
		
		// Temper Light Drop Down
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Temper Light Drop Down');
    ddTemperLight := TComboBox.Create(frm);
    ddTemperLight.Parent := frm;
		ddTemperLight.Height := lblTemperLight.Height;
    ddTemperLight.Top := lblTemperLight.Top - 2;		
    ddTemperLight.Left := 450;
    ddTemperLight.Width := 80;
		if slContains(slGlobal, 'TemperLight') then begin
			ddTemperLight.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('TemperLight')]));
		end else begin
			ddTemperLight.Items.Add(IntToStr(defaultTemperLight));
		end;
		ddTemperLight.ItemIndex := 0;
		
		// Temper Heavy Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Temper Heavy Label');
		lblTemperHeavy := TLabel.Create(frm);
		lblTemperHeavy.Parent := frm;
		lblTemperHeavy.Height := lblTemperLight.Height;
		lblTemperHeavy.Top := lblTemperLight.Top + lblTemperLight.Height + 18;
		lblTemperHeavy.Left := lblTemperLight.Left;
		lblTemperHeavy.Caption := '# of Ingots - Heavy/Two-Handed: ';	
		
		// Temper Heavy Drop Down
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Temper Heavy Drop Down');
    ddTemperHeavy := TComboBox.Create(frm);
    ddTemperHeavy.Parent := frm;
		ddTemperHeavy.Height := lblTemperHeavy.Height;
    ddTemperHeavy.Top := lblTemperHeavy.Top - 2;		
    ddTemperHeavy.Left := ddTemperLight.Left;
    ddTemperHeavy.Width := ddTemperLight.Width;
		if slContains(slGlobal, 'TemperHeavy') then begin
			ddTemperHeavy.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('TemperHeavy')]));
		end else begin
			ddTemperHeavy.Items.Add(IntToStr(defaultTemperHeavy));
		end;
		ddTemperHeavy.ItemIndex := 0;
	end else begin
		Sender.Caption := 'Configure Temper Recipe';
		// Set Result
		if slContains(slGlobal, 'TemperLight') then begin
			slGlobal.Objects[slGlobal.IndexOf('TemperLight')] := StrToInt(ComponentByTop(ComponentByCaption('# of Ingots - Light/One-Handed: ', frm).Top - 2, frm).Text);
		end else
			slGlobal.AddObject('TemperLight', StrToInt(ComponentByTop(ComponentByCaption('# of Ingots - Light/One-Handed: ', frm).Top - 2, frm).Text));
		if slContains(slGlobal, 'TemperHeavy') then begin
			slGlobal.Objects[slGlobal.IndexOf('TemperHeavy')] := StrToInt(ComponentByTop(ComponentByCaption('# of Ingots - Heavy/Two-Handed: ', frm).Top - 2, frm).Text);
		end else
			slGlobal.AddObject('TemperHeavy', StrToInt(ComponentByTop(ComponentByCaption('# of Ingots - Heavy/Two-Handed: ', frm).Top - 2, frm).Text));
		// Free Components	
		for i := 0 to slTemp.Count-1 do begin
			tempObject := ComponentByCaption(slTemp[i], frm);
			tempInteger := tempObject.Top - 2;
			tempObject.Free;
			tempObject := ComponentByTop(tempInteger, frm);
			tempObject.Free;
		end;
		// Shift form
		TShift(Sender.Top+3, slTemp.Count*44, frm, True);
		frm.Height := frm.Height - slTemp.Count*44;
	end;
	
	// Finalize
	slTemp.Free;

	debugMsg := False;
// End debugMsg section
end;

Procedure Btn_Breakdown_OnClick(Sender: TObject);
var
	lblEquipped, lblEnchanted, lblDaedric, lblChitin: TLabel;
	ckEquipped, ckEnchanted, ckDaedric, ckChitin: TComboBox;
	debugMsg, tempBoolean: Boolean;
	btnOk, btnCancel: TButton;
	i, tempInteger: Integer;
	slTemp: TStringList;
	frm: TForm;
	tempObject: TObject;
begin	
// Begin debugMsg section
	debugMsg := False;
	
	// Initialize
	slTemp := TStringList.Create;
	
	// Get Sender Parameters
	{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Sender := '+Sender.Caption);
	{Debug} if debugMsg then msgList('[Btn_Temper_OnClick] slGlobal := ', slGlobal, '');
	frm := Sender.Parent;
	
	if not CaptionExists('Breakdown Equipped: ', frm) then begin
		// Shift Components
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Shift Components Down');
		frm.Height := frm.Height + 172;
		TShift(Sender.Top+3, 172, frm, False);
		Sender.Caption := 'Confirm Breakdown Recipe';
		
		// Breakdown Equipped Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown Equipped Label');
		lblEquipped := TLabel.Create(frm);
		lblEquipped.Parent := frm;
		lblEquipped.Height := 24;
		lblEquipped.Top := Sender.Top + Sender.Height + 18;
		lblEquipped.Left := Sender.Left;
		lblEquipped.Caption := 'Breakdown Equipped: ';	
		
		// Breakdown Equipped Check Box
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown Equipped Check Box');
    ckEquipped := TCheckBox.Create(frm);
    ckEquipped.Parent := frm;
		ckEquipped.Height := lblEquipped.Height;
    ckEquipped.Top := lblEquipped.Top - 2;		
    ckEquipped.Left := 465;
    ckEquipped.Width := 80;
		if slContains(slGlobal, 'BreakdownEquipped') then begin
			ckEquipped.Checked := Boolean(slGlobal.Objects[slGlobal.IndexOf('BreakdownEquipped')]);
		end else
			ckEquipped.Checked := False;
		
		// Breakdown Enchanted Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown Enchanted Label');
		lblEnchanted := TLabel.Create(frm);
		lblEnchanted.Parent := frm;
		lblEnchanted.Height := lblEquipped.Height;
		lblEnchanted.Top := lblEquipped.Top + lblEquipped.Height + 18;
		lblEnchanted.Left := lblEquipped.Left;
		lblEnchanted.Caption := 'Breakdown Enchanted: ';	
		
		// Breakdown Enchanted Check Box
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown Enchanted Check Box');
    ckEnchanted := TCheckBox.Create(frm);
    ckEnchanted.Parent := frm;
		ckEnchanted.Height := lblEnchanted.Height;
    ckEnchanted.Top := lblEnchanted.Top - 2;		
    ckEnchanted.Left := ckEquipped.Left;
    ckEnchanted.Width := ckEquipped.Width;
		if slContains(slGlobal, 'BreakdownEnchanted') then begin		
			ckEnchanted.Checked := Boolean(slGlobal.Objects[slGlobal.IndexOf('BreakdownEnchanted')]);
		end else
			ckEnchanted.Checked := False;

		// Breakdown Daedric Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown Daedric Label');
		lblDaedric := TLabel.Create(frm);
		lblDaedric.Parent := frm;
		lblDaedric.Height := lblEnchanted.Height;
		lblDaedric.Top := lblEnchanted.Top + lblEnchanted.Height + 18;
		lblDaedric.Left := lblEnchanted.Left;
		lblDaedric.Caption := 'Breakdown Daedric: ';	
		
		// Breakdown Daedric Check Box
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown Daedric Check Box');
    ckDaedric := TCheckBox.Create(frm);
    ckDaedric.Parent := frm;
		ckDaedric.Height := lblDaedric.Height;
    ckDaedric.Top := lblDaedric.Top - 2;		
    ckDaedric.Left := ckEquipped.Left;
    ckDaedric.Width := ckEquipped.Width;
		if slContains(slGlobal, 'BreakdownDaedric') then begin		
			ckDaedric.Checked := Boolean(slGlobal.Objects[slGlobal.IndexOf('BreakdownDaedric')]);
		end else
			ckDaedric.Checked := True;
		
		// Breakdown DLC Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown DLC Label');
		lblChitin := TLabel.Create(frm);
		lblChitin.Parent := frm;
		lblChitin.Height := lblDaedric.Height;
		lblChitin.Top := lblDaedric.Top + lblDaedric.Height + 18;
		lblChitin.Left := lblDaedric.Left;
		lblChitin.Caption := 'Breakdown DLC: ';	
		
		// Breakdown DLC Check Box
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown DLC Check Box');
    ckChitin := TCheckBox.Create(frm);
    ckChitin.Parent := frm;
		ckChitin.Height := lblChitin.Height;
    ckChitin.Top := lblChitin.Top - 2;		
    ckChitin.Left := ckEquipped.Left;
    ckChitin.Width := ckEquipped.Width;
		if slContains(slGlobal, 'BreakdownDLC') then begin		
			ckChitin.Checked := Boolean(slGlobal.Objects[slGlobal.IndexOf('BreakdownDLC')]);
		end else
			ckChitin.Checked := True;
	end else begin
		// Set result
		tempObject := ComponentByTop(ComponentByCaption('Breakdown Equipped: ', frm).Top - 2, frm);
		if slContains(slGlobal, 'BreakdownEquipped') then begin
			slGlobal.Objects[slGlobal.IndexOf('BreakdownEquipped')] := tempObject.Checked;
		end else
			slGlobal.AddObject('BreakdownEquipped', tempObject.Checked);
		tempObject := ComponentByTop(ComponentByCaption('Breakdown Enchanted: ', frm).Top - 2, frm);
		if slContains(slGlobal, 'BreakdownEnchanted') then begin
			slGlobal.Objects[slGlobal.IndexOf('BreakdownEnchanted')] := tempObject.Checked;
		end else
			slGlobal.AddObject('BreakdownEnchanted', tempObject.Checked);
		tempObject := ComponentByTop(ComponentByCaption('Breakdown Daedric: ', frm).Top - 2, frm);
		if slContains(slGlobal, 'BreakdownDaedric') then begin
			slGlobal.Objects[slGlobal.IndexOf('BreakdownDaedric')] := tempObject.Checked;
		end else
			slGlobal.AddObject('BreakdownDaedric', tempObject.Checked);
		tempObject := ComponentByTop(ComponentByCaption('Breakdown DLC: ', frm).Top - 2, frm);
		if slContains(slGlobal, 'BreakdownDLC') then begin
			slGlobal.Objects[slGlobal.IndexOf('BreakdownDLC')] := tempObject.Checked;
		end else
			slGlobal.AddObject('BreakdownDLC', tempObject.Checked);
		{Debug} if debugMsg then msgList('[Btn_Temper_OnClick] slGlobal := ', slGlobal, '');
		// Free Components
		slTemp.CommaText := '"Breakdown Equipped: ", "Breakdown Enchanted: ", "Breakdown DLC: ", "Breakdown Daedric: ';
		for i := 0 to slTemp.Count-1 do begin
			tempObject := ComponentByCaption(slTemp[i], frm);
			tempInteger := tempObject.Top - 2;
			tempObject.Free;
			tempObject := ComponentByTop(tempInteger, frm);
			tempObject.Free;
		end;
		// Shift form
		Sender.Caption := 'Configure Breakdown Recipe';
		TShift(Sender.Top+3, 172, frm, True);
		frm.Height := frm.Height - 172;
	end;
	
	// Finalize
	slTemp.Free;
	
	debugMsg := False;
// End debugMsg section
end;

Procedure Btn_Crafting_OnClick(Sender: TObject);
var
	lblScaling: TLabel;
	ckScaling: TComboBox;
	debugMsg, tempBoolean: Boolean;
	btnOk, btnCancel: TButton;
	i, tempInteger: Integer;
	slTemp: TStringList;
	frm: TForm;
	tempObject: TObject;
begin	
// Begin debugMsg section
	debugMsg := False;
	
	// Initialize
	slTemp := TStringList.Create;
	
	// Get Sender Parameters
	{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Sender := '+Sender.Caption);
	frm := Sender.Parent;
	
	if not CaptionExists('Recipe Scaling: ', frm) then begin
		// Shift Components
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Shift Components Down');
		frm.Height := frm.Height + 44;
		TShift(Sender.Top+3, 44, frm, False);
		Sender.Caption := 'Confirm Crafting Recipe';
		
		// Enable Scaling Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Enable Scaling Label');
		lblScaling := TLabel.Create(frm);
		lblScaling.Parent := frm;
		lblScaling.Height := 24;
		lblScaling.Top := Sender.Top + 40;
		lblScaling.Left := Sender.Left;
		lblScaling.Caption := 'Recipe Scaling: ';	
		
		// Enable Scaling
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Enable Scaling Check Box');
    ckScaling := TCheckBox.Create(frm);
    ckScaling.Parent := frm;
		ckScaling.Height := lblScaling.Height;
    ckScaling.Top := lblScaling.Top - 2;		
    ckScaling.Left := 465;
    ckScaling.Width := 80;
		if StrWithinSL('RecipeScaling', slGlobal) then begin
			for i := 0 to slGlobal.Count-1 do
				if StrWithinStr(slGlobal[i], 'RecipeScaling') then				
					ckScaling.Checked := StrToBool(StrPosCopy(slGlobal[i], '=', False));
		end else
			ckScaling.Checked := True;
	end else begin
		Sender.Caption := 'Configure Crafting Recipe';
		// Set Result
		tempObject := ComponentByTop(ComponentByCaption('Recipe Scaling: ', frm).Top - 2, frm);
		if StrWithinSL('RecipeScaling', slGlobal) then begin
			for i := 0 to slGlobal.Count-1 do begin
				if StrWithinStr(slGlobal[i], 'RecipeScaling') then begin				
					slGlobal[i] := 'RecipeScaling='+BoolToStr(tempObject.Checked);
					Break;
				end;
			end;
		end else
			slGlobal.Add('RecipeScaling='+BoolToStr(tempObject.Checked));
		// Free Components
		slTemp.CommaText := '"Recipe Scaling: "';
		for i := 0 to slTemp.Count-1 do begin
			tempObject := ComponentByCaption(slTemp[i], frm);
			tempInteger := tempObject.Top - 2;
			tempObject.Free;
			tempObject := ComponentByTop(tempInteger, frm);
			tempObject.Free;
		end;
		// Shift form
		TShift(Sender.Top+3, 44, frm, True);
		frm.Height := frm.Height - 44;
	end;
	
	// Finalize
	slTemp.Free;

	debugMsg := False;
// End debugMsg section
end;

Procedure ELLR_Btn_Patch(Sender: TObject);
var
	tempFile, tempRecord, tempElement: IInterface;
	lbl_FileA_Add, lbl_FileA_From, lbl_FileB_To: TLabel;
	dd_Patch, dd_FileA, dd_FileA_Plugin, dd_FileB_Plugin: TComboBox;
	btnOk, btnCancel: TButton;
	slTemp: TStringList;
	debugMsg: Boolean;
	i, x: Integer;
	frm: TForm;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Initialize
	slTemp := TStringList.Create;
	
	// Dialogue Box
	frm := TForm.Create(nil);
	try
		// Parent Form
		frm.Width := 1680;
		frm.Height := 200;
		frm.Position := poScreenCenter;
		frm.Caption := 'Patch Two Specific Files';	

		// File A add caption
		lbl_FileA_Add := TLabel.Create(frm);
		lbl_FileA_Add.Parent := frm;
		lbl_FileA_Add.Height := 24;
		lbl_FileA_Add.Top := 68;
		lbl_FileA_Add.Left := 60;
		lbl_FileA_Add.Caption := 'Add';

		// Items or Enchantments Drop Down
		dd_FileA := TComboBox.Create(frm);
		dd_FileA.Parent := frm;
		dd_FileA.Height := 24;
		dd_FileA.Top := lbl_FileA_Add.Top - 2;		
		dd_FileA.Left := lbl_FileA_Add.Left+(10*Length(lbl_FileA_Add.Caption))+20;
		dd_FileA.Width := 180;
		dd_FileA.Items.Add('Items');
		dd_FileA.Items.Add('Enchantments');
		dd_FileA.ItemIndex := 0;
		dd_FileA.OnClick := ELLR_OnClick_Patch_ddFileA;
		
		// File A from caption
		lbl_FileA_From := TLabel.Create(frm);
		lbl_FileA_From.Parent := frm;
		lbl_FileA_From.Height := 24;
		lbl_FileA_From.Top := lbl_FileA_Add.Top;
		lbl_FileA_From.Left := dd_FileA.Left+dd_FileA.Width+8;
		lbl_FileA_From.Caption := 'from: ';		
		
		// FileA Plugin Drop Down
		dd_FileA_Plugin := TComboBox.Create(frm);
		dd_FileA_Plugin.Parent := frm;
		dd_FileA_Plugin.Height := 24;
		dd_FileA_Plugin.Top := lbl_FileA_Add.Top - 2;		
		dd_FileA_Plugin.Left := lbl_FileA_From.Left+(10*Length(lbl_FileA_From.Caption));
		dd_FileA_Plugin.Width := 500;
		for i := 0 to Pred(FileCount) do
			dd_FileA_Plugin.Items.Add(GetFileName(FileByIndex(i)));
		dd_FileA_Plugin.AutoComplete := True;
		dd_FileA_Plugin.Sorted := True;

		// File B Variable Label
		lbl_FileB_To := TLabel.Create(frm);
		lbl_FileB_To.Parent := frm;
		lbl_FileB_To.Height := 24;
		lbl_FileB_To.Top := dd_FileA.Top + 1;
		lbl_FileB_To.Left := dd_FileA_Plugin.Left+dd_FileA_Plugin.Width+8;
		lbl_FileB_To.Caption := 'to Leveled Lists from: ';
		
		// File B Plugin Drop Down
		dd_FileB_Plugin := TComboBox.Create(frm);
		dd_FileB_Plugin.Parent := frm;
		dd_FileB_Plugin.Height := 24;
		dd_FileB_Plugin.Top := dd_FileA.Top - 1;		
		dd_FileB_Plugin.Left := lbl_FileB_To.Left+(10*Length(lbl_FileB_To.Caption) - 20);
		dd_FileB_Plugin.Width := dd_FileA_Plugin.Width;
		for i := 0 to Pred(FileCount) do
			dd_FileB_Plugin.Items.Add(GetFileName(FileByIndex(i)));
		dd_FileB_Plugin.AutoComplete := True;
		dd_FileB_Plugin.Sorted := True;
		
		// Ok Button
		btnOk := TButton.Create(frm);
		btnOk.Parent := frm;
		btnOk.Caption := 'Ok';		
		btnOk.Left := (frm.Width div 2)-btnOk.Width-8;
		btnOk.Top := frm.Height-80;
		btnOk.ModalResult := mrOk;
	
		// Cancel Button
		btnCancel := TButton.Create(frm);
		btnCancel.Parent := frm;
		btnCancel.Caption := 'Cancel';	
		btnCancel.Left := btnOk.Left+btnOk.Width+16;
		btnCancel.Top := btnOk.Top;	
		btnCancel.ModalResult := mrCancel;
		
		frm.ShowModal;
		if (frm.ModalResult = mrOk) then begin
			if DoesFileExist(dd_FileA_Plugin.Text) and DoesFileExist(dd_FileB_Plugin.Text) then begin
				// Sender.Parent.Visible := False;
				slGlobal.Clear;
				if not DoesFileExist('Patch_'+dd_FileA_Plugin.Text+'_'+dd_FileB_Plugin.Text) then begin
					SetObject('ALLAfile', TObject(AddNewFileName('Patch_'+dd_FileA_Plugin.Text+'_'+dd_FileB_Plugin.Text)), slGlobal);
				end else
					SetObject('ALLAfile', TObject(FileByName('Patch_'+dd_FileA_Plugin.Text+'_'+dd_FileB_Plugin.Text)), slGlobal);
				{Debug} if debugMsg then msg('[ELLR_Btn_Patch] ALLAfile := '+GetFileName(ote(GetObject('ALLAfile', slGlobal))));
				SetObject('Patch', TObject(FileByName(dd_FileB_Plugin.Text)), slGlobal);
				slTemp.CommaText := 'AMMO, ARMO, WEAP';
				tempFile := FileByName(dd_FileA_Plugin.Text);
				for i := 0 to slTemp.Count-1 do begin	
					tempElement := gbs(tempFile, slTemp[i]);
					for x := 0 to Pred(ec(tempElement)) do begin
						tempRecord := ebi(tempElement, x);
						if not (Length(EditorID(tempRecord)) > 0) then Continue
						SetObject(EditorID(tempRecord)+'Original', TObject(tempRecord), slGlobal);
						SetObject(EditorID(tempRecord)+'Template', TObject(GetTemplate(tempRecord)), slGlobal);
					end;
				end;				
			end;
			{Debug} if debugMsg then msgList('[ELLR_Btn_Patch] slGlobal := ', slGlobal, '');
			Sender.Parent.ModalResult := mrRetry;
		end;
	finally
		frm.Free;
	end;
	
	// Finalize
	slTemp.Free;
	
	debugMsg := False;
// End debugMsg section
end;


Procedure GEV_GeneralSettings;
var
	lblpercent, lblEnchantmentMultiplier, lblEnchantmentPercent, lblAllowUnenchanting, lblAddtoLL: TLabel;
  lblChance, lblDetectedItem, lblDetectedItemText, lblGEVfile, ckPercent, ckAllowUnenchanting, ckAddtoLL: TCheckBox;
  btnOk, btnCancel, btnAdvanced, btnRemove, btnItemTierLevels, btnBulk, btnPatch: TButton;
	ddChance, ddEnchantmentMultiplier, ddGEVfile, ddAddtoLL: TComboBox;
	debugMsg, tempBoolean: Boolean;
	frm: TForm;
  i: integer;
begin
// Begin debugMsg Section
  debugMsg := False;
	
	// Initialize Local
	if not Assigned(slGlobal) then slGlobal := TStringList.Create;

  frm := TForm.Create(nil);
  try
    // Parent Form; Entire Box
    frm.Width := 650;
    frm.Height := 180;
    frm.Position := poScreenCenter;
    frm.Caption := 'General Settings';
	
	  // Currently Selected Item Label
		lblDetectedItemText := TLabel.Create(frm);
		lblDetectedItemText.Parent := frm;
		lblDetectedItemText.Height := 24;
		lblDetectedItemText.Top := 80;
		lblDetectedItemText.Left := 60;
		lblDetectedItemText.Caption := 'Currently Selected Item: ';
		frm.Height := frm.Height+lblDetectedItemText.Height + 18;
	  
		// Currently Selected Item
		lblDetectedItem := TLabel.Create(frm);
		lblDetectedItem.Parent := frm;
		lblDetectedItem.Height := lblDetectedItemText.Height;
		lblDetectedItem.Top := lblDetectedItemText.Top;		
		lblDetectedItem.Left := lblDetectedItemText.Left + (10*Length(lblDetectedItemText.Caption));
		lblDetectedItem.Caption := full(selectedRecord);
	
		// Output Plugin Label
    lblGEVfile := TLabel.Create(frm);
    lblGEVfile.Parent := frm;
		lblGEVfile.Height := lblDetectedItemText.Height;
    lblGEVfile.Top := lblDetectedItemText.Top + lblDetectedItemText.Height + 18;
    lblGEVfile.Left := lblDetectedItemText.Left;		
    lblGEVfile.Caption := 'Output Plugin: ';
		frm.Height := frm.Height+lblGEVfile.Height + 18;
    
		// Output Plugin Edit Box
    ddGEVfile := TComboBox.Create(frm);
    ddGEVfile.Parent := frm;
		ddGEVfile.Height := lblDetectedItemText.Height;
    ddGEVfile.Top := lblGEVfile.Top - 2;		
    ddGEVfile.Left := lblGEVfile.Left + (9*Length(lblGEVfile.Caption)) + 36;
		ddGEVfile.Width := 280;
		if slContains(slGlobal, 'GEVfile') then begin
			ddGEVfile.Items.Add(GetFileName(ote(GetObject('GEVfile', slGlobal))));
		end else
			ddGEVfile.Items.Add(defaultOutputPlugin);
		ddGEVfile.ItemIndex := 0;	

	  // Item Tier Levels
		btnItemTierLevels := TButton.Create(frm);
		btnItemTierLevels.Parent := frm;
		btnItemTierLevels.Top := lblGEVfile.Top + lblGEVfile.Height + 18;
		btnItemTierLevels.Height := 24;
		btnItemTierLevels.Left := lblGEVfile.Left + 10*Length(btnItemTierLevels.Caption);
		btnItemTierLevels.Caption := 'Configure Tiers';
		btnItemTierLevels.Width := 450;
		frm.Height := frm.Height + btnItemTierLevels.Height + 18;
		btnItemTierLevels.OnClick := Btn_ItemTierLevels_OnClick;
		
		// Replace in Leveled List Label
    lblAddtoLL := TLabel.Create(frm);
    lblAddtoLL.Parent := frm;
		lblAddtoLL.Height := lblDetectedItemText.Height;
    lblAddtoLL.Top := btnItemTierLevels.Top + btnItemTierLevels.Height + 18;;
    lblAddtoLL.Left := lblGEVfile.Left;
    lblAddtoLL.Caption := 'Replace in Leveled Lists: ';
		frm.Height := frm.Height+lblAddtoLL.Height + 18;
    
		// Replace in Leveled List Check Box
    ckAddtoLL := TCheckBox.Create(frm);
    ckAddtoLL.Parent := frm;
		ckAddtoLL.Height := lblAddtoLL.Height;
    ckAddtoLL.Left := 485;
    ckAddtoLL.Top := lblAddtoLL.Top;
		if slContains(slGlobal, 'ReplaceInLeveledList') then begin
			ckAddtoLL.Checked := Boolean(GetObject('ReplaceInLeveledList', slGlobal));
		end else
			ckAddtoLL.Checked := True;
		
		// Allow Unenchanting Label
    lblAllowUnenchanting := TLabel.Create(frm);
    lblAllowUnenchanting.Parent := frm;
		lblAllowUnenchanting.Height := 24;
    lblAllowUnenchanting.Top := lblAddtoLL.Top+lblAddtoLL.Height + 18;		
    lblAllowUnenchanting.Left := lblGEVfile.Left;
    lblAllowUnenchanting.Caption := 'Allow Unenchanting: ';
		frm.Height := frm.Height + lblAllowUnenchanting.Height + 18;
    
		// Allow Unenchanting Check Box
    ckAllowUnenchanting := TCheckBox.Create(frm);
    ckAllowUnenchanting.Parent := frm;
		ckAllowUnenchanting.Height := 24;
	  ckAllowUnenchanting.Top := lblAllowUnenchanting.Top;
    ckAllowUnenchanting.Left := ckAddtoLL.Left;
		if slContains(slGlobal, 'AllowDisenchanting') then begin
			ckAllowUnenchanting.Checked := Boolean(GetObject('AllowDisenchanting', slGlobal));
		end else
			ckAllowUnenchanting.Checked := True;	

		// Percent Chance Label
    lblChance := TLabel.Create(frm);
    lblChance.Parent := frm;
    lblChance.Left := lblGEVfile.Left;
    lblChance.Top := lblAllowUnenchanting.Top + lblAllowUnenchanting.Height + 18;
    lblChance.Caption := 'Use Percent Chance: ';
		frm.Height := frm.Height+lblChance.Height + 8;
    
		// Percent Chance Check Box
    ckPercent := TCheckBox.Create(frm);
    ckPercent.Parent := frm;
		ckPercent.Height := lblGEVfile.Height;
    ckPercent.Left := ckAddtoLL.Left;
    ckPercent.Top := lblChance.Top;
		if slContains(slGlobal, 'ChanceBoolean') then begin
			ckPercent.Checked := Boolean(GetObject('ChanceBoolean', slGlobal));
		end else
			ckPercent.Checked := True;	

		// Generate Enchanted Versions % Chance Label
    lblpercent := TLabel.Create(frm);
    lblpercent.Parent := frm;
		lblpercent.Height := ddGEVfile.Height;
    lblpercent.Left := ckPercent.Left + 20;
    lblpercent.Top := lblChance.Top;
		lblpercent.Caption := '%';
		
		// Generate Enchanted Versions % Chance Edit Box
    ddChance := TComboBox.Create(frm);
    ddChance.Parent := frm;
		ddChance.Height := lblpercent.Height;
    ddChance.Left := lblpercent.Left + 25;
    ddChance.Top := lblChance.Top - 3;
		ddChance.Width := 80;
		if slContains(slGlobal, 'ChanceMultiplier') then begin
			ddChance.Items.Add(IntToStr(Integer(slGlobal.Objects[slGlobal.IndexOf('ChanceMultiplier')])));
		end else
			ddChance.Items.Add('10');	
		ddChance.ItemIndex := 0;
		
		// Enchantment Multiplier Label
    lblEnchantmentMultiplier := TLabel.Create(frm);
    lblEnchantmentMultiplier.Parent := frm;
    lblEnchantmentMultiplier.Left := lblGEVfile.Left;
    lblEnchantmentMultiplier.Top := lblChance.Top+lblChance.Height + 18;
    lblEnchantmentMultiplier.Caption := 'Enchantment Strength: ';
		frm.Height := frm.Height + lblEnchantmentMultiplier.Height + 18;
    
		// Enchantment Multiplier Edit Box
    ddEnchantmentMultiplier := TComboBox.Create(frm);
    ddEnchantmentMultiplier.Parent := frm;
		ddEnchantmentMultiplier.Height := lblEnchantmentMultiplier.Height;
    ddEnchantmentMultiplier.Left := ddChance.Left;
    ddEnchantmentMultiplier.Top := lblEnchantmentMultiplier.Top - 1;
		ddEnchantmentMultiplier.Width := ddChance.Width;
		if slContains(slGlobal, 'EnchMultiplier') then begin
			ddEnchantmentMultiplier.Items.Add(IntToStr(Integer(slGlobal.Objects[slGlobal.IndexOf('EnchMultiplier')])));
		end else
			ddEnchantmentMultiplier.Items.Add('100');	
		ddChance.ItemIndex := 0;
		ddEnchantmentMultiplier.ItemIndex := 0;	

		// Generate Enchanted Versions % Chance Label
    lblEnchantmentPercent := TLabel.Create(frm);
    lblEnchantmentPercent.Parent := frm;
		lblEnchantmentPercent.Height := ddEnchantmentMultiplier.Height;
    lblEnchantmentPercent.Left := lblpercent.Left;
    lblEnchantmentPercent.Top := ddEnchantmentMultiplier.Top + 4;
		lblEnchantmentPercent.Caption := '%';
		
		if StrWithinSL('NoButtons', slGlobal) then begin
			frm.Height := frm.Height-50;
			TShift(0, 50, frm, True);
		end else begin
			// Remove Button
			btnRemove := TButton.Create(frm);
			btnRemove.Parent := frm;
			btnRemove.Caption := 'Remove';
			btnRemove.Left := lblGEVfile.Left;
			btnRemove.Top := 20;
			btnRemove.Width := 100;
			btnRemove.OnClick := GEV_Btn_Remove;

			// Patch Button
			btnPatch := TButton.Create(frm);
			btnPatch.Parent := frm;
			btnPatch.Caption := 'Patch';
			btnPatch.Left := 285;
			btnPatch.Top := 20;
			btnPatch.Width := 100;
			btnPatch.OnClick := ELLR_Btn_Patch;

			// Bulk Button
			btnBulk := TButton.Create(frm);
			btnBulk.Parent := frm;
			btnBulk.Caption := 'Bulk';
			btnBulk.Left := frm.Width - 150;
			btnBulk.Top := 20;
			btnBulk.Width := 100;
			btnBulk.OnClick := Btn_Bulk_OnClick;
		end;

		// Ok Button
    btnOk := TButton.Create(frm);
    btnOk.Parent := frm;
    btnOk.Caption := 'Ok';
    btnOk.ModalResult := mrOk;
    btnOk.Left := (frm.Width div 2)-btnOk.Width - 8;
    btnOk.Top := frm.Height - 80;
	
		// Cancel Button
    btnCancel := TButton.Create(frm);
    btnCancel.Parent := frm;
    btnCancel.Caption := 'Cancel';
    btnCancel.ModalResult := mrCancel;
    btnCancel.Left := btnOk.Left + btnOk.Width + 16;
    btnCancel.Top := btnOk.Top;	
	
		// What happens when Ok is pressed
		frm.ShowModal;
    if (frm.ModalResult = mrOk) then begin
			if not StrEndsWith(ddGEVfile.Caption, '.esl') then AppendIfMissing(ddGEVfile.Caption, '.esp');			
			SetObject('CancelAll', False, slGlobal);
			SetObject('GEVfile', FileByName(ddGEVfile.Caption), slGlobal);				
			SetObject('ChanceBoolean', ckPercent.Checked, slGlobal);			
			SetObject('ReplaceInLeveledList', ckAddtoLL.Checked, slGlobal);
			SetObject('ChanceMultiplier', StrToInt(ddChance.Text), slGlobal);
			SetObject('AllowDisenchanting', ckAllowUnenchanting.Checked, slGlobal);
			SetObject('EnchMultiplier', StrToInt(ddEnchantmentMultiplier.Text), slGlobal);
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] CancelAll := '+BoolToStr(Boolean(GetObject('CancelAll', slGlobal))));
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] GEVfile := '+GetFileName(ote(GetObject('GEVfile', slGlobal))));
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] ChanceBoolean := '+BoolToStr(Boolean(GetObject('ChanceBoolean', slGlobal))));
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] ReplaceInLeveledList := '+BoolToStr(Boolean(GetObject('ReplaceInLeveledList', slGlobal))));
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] ChanceMultiplier := '+IntToStr(Integer(GetObject('ChanceMultiplier', slGlobal))));
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] AllowDisenchanting := '+BoolToStr(Boolean(GetObject('AllowDisenchanting', slGlobal))));
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] EnchMultiplier := '+IntToStr(Integer(GetObject('EnchMultiplier', slGlobal))));
    end;
  finally
    frm.Free;
  end;
	
  debugMsg := False;
// End debugMsg Section
end;

// Generates enchanted versions of a list of records from a list of input files
Procedure GenerateEnchantedVersionsAuto;
var
	slTemp, slItemTiers, slIndex, slFiles, slTempList, slRecords, slEnchanted, slExistingRecords: TStringList;
  tempRecord, tempElement, objEffect, enchLevelList, chanceLevelList, GEVfile: IInterface;
	debugMsg, tempBoolean, AllowDisenchanting, ReplaceInLeveledList: Boolean;
  tempString, suffix, record_sig, record_edid, PatchFile: String;	
	startTime, stopTime, tempStartTime, tempStopTime, processStartTime, processStopTime: TDateTime;
	enchAmount, enchMultiplier: Float;	
	i, x, y, z, tempInteger: Integer;	
begin
	// Initialize
	debugMsg := False;
	startTime := Time;
	if not Assigned(slExistingRecords) then slExistingRecords := TStringList.Create;
	if not Assigned(slEnchanted) then slEnchanted := TStringList.Create;
	if not Assigned(slItemTiers) then slItemTiers := TStringList.Create;
	if not Assigned(slTempList) then slTempList := TStringList.Create;
	if not Assigned(slRecords) then slRecords := TStringList.Create;	
	if not Assigned(slGlobal) then slGlobal := TStringList.Create;
	if not Assigned(slIndex) then slIndex := TStringList.Create;
	if not Assigned(slFiles) then slFiles := TStringList.Create;
	if not Assigned(slTemp) then slTemp := TStringList.Create;

	// Detect loaded plugins
	slTemp.CommaText := 'Skyrim.esm, Dawnguard.esm, Hearthfires.esm, Dragonborn.esm, HolyEnchants.esp, LostEnchantments.esp, "More Interesting Loot for Skyrim.esp", "Summermyst - Enchantments of Skyrim.esp", "Wintermyst - Enchantments of Skyrim.esp"';
	for i := 0 to slTemp.Count-1 do
		if DoesFileExist(slTemp[i]) then
			slFiles.AddObject(Trim(slTemp[i]), FileByName(slTemp[i]));	
	{Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slFiles := ', slFiles, '');

	// Skips dlg if external input is present
	{Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slGlobal := ', slGlobal, '');	
	{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] AllowDisenchanting := '+BoolToStr(Boolean(GetObject('AllowDisenchanting', slGlobal))));
	AllowDisenchanting := Boolean(GetObject('AllowDisenchanting', slGlobal));
	ReplaceInLeveledList := Boolean(GetObject('ReplaceInLeveledList', slGlobal));
	GEVfile := ote(GetObject('GEVfile', slGlobal));

	// Prep File
	if not Assigned(GEVfile) then begin
		GEV_GeneralSettings;
		GEVfile := ote(GetObject('GEVfile', slGlobal));
	end;
	if Assigned(GEVfile) then begin
		// Create the necessary groups
		slTemp.CommaText := 'LVLI, ARMO, WEAP, COBJ, KYWD';
		for x := 0 to slTemp.Count-1 do
			if not HasGroup(GEVfile, slTemp[x]) then 
				Add(GEVfile, slTemp[x], True); 
	end else begin
		msg('[ERROR] [GenerateEnchantedVersionsAuto] GEVfile unassigned');
		if Assigned(slExistingRecords) then slExistingRecords.Free;
		if Assigned(slEnchanted) then slEnchanted.Free;
		if Assigned(slItemTiers) then slItemTiers.Free;		
		if Assigned(slTempList) then slTempList.Free;
		if Assigned(slRecords) then slRecords.Free;
		if Assigned(slIndex) then slIndex.Free;
		if Assigned(slFiles) then slFiles.Free;
		if Assigned(slTemp) then slTemp.Free;
		Exit;
	end;
	{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] AllowDisenchanting := '+BoolToStr(Boolean(GetObject('AllowDisenchanting', slGlobal))));
	
	for i := 0 to slGlobal.Count-1 do
		if StrWithinStr(slGlobal[i], 'Original') then
			if not Assigned(ebp(ote(slGlobal.Objects[i]), 'EITM')) then // Most items with enchantments on the original records are legendary or unique items and should be excluded
				SetObject(StrPosCopy(slGlobal[i], 'Original', True), slGlobal.Objects[i], slRecords);
	{Debug} if debugMsg then msgList('slGlobal := ', slGlobal, '');
	{Debug} if debugMsg then msgList('slRecords := ', slRecords, '');

	// Add masters
	for x := 0 to slFiles.Count-1 do begin
		msg('Adding '+slFiles[x]+' masters to '+GetFileName(GEVfile));
		AddMastersAuto(ote(slFiles.Objects[x]), GEVfile);
	end;
	AddMastersList(slRecords, GEVfile);

	// Build indexes of loaded plugins
	{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] Build indexes of loaded plugins');
	slTemp.Clear;
	// Get keywords
	for x := 0 to slRecords.Count-1 do begin
		tempRecord := ote(slRecords.Objects[x]);
		if (sig(tempRecord) = 'ARMO') then begin
			slGetFlagValues(tempRecord, slTemp, False);
			// Non-vanilla armor types prioritize keywords over BOD2
			slTempList.CommaText :=  '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
			for y := 0 to slTemp.Count-1 do
				if not StrWithinSL(slTemp[y], slTempList) then
					if not slContains(slTemp, AssociatedBOD2(slTemp[y])) then
						slTemp.Add(AssociatedBOD2(slTemp[y]));
			// Add clothing type to keywords
			for y := 0 to slTemp.Count-1 do begin
				if not ((slTemp[y] = '30') or (slTemp[y] = '35') or (slTemp[y] = '36')) then
					slTemp[y] := slTemp[y]+'-'+geev(ElementBySignature(tempRecord, GetElementType(tempRecord)), 'Armor Type');
			end;
		end else
			slTemp.Add(sig(tempRecord));
		slClearEmptyStrings(slTemp);
	end;
	{Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] Keywords (slTemp) := ', slTemp, '');
	for x := 0 to slFiles.Count-1 do begin
		msg('Indexing '+IntToStr(ec(gbs(ote(slFiles.Objects[x]), 'ENCH')))+' Enchantments in '+slFiles[x]);
		IndexObjEffect(ote(slFiles.Objects[x]), slTemp, slIndex);				
	end;
	if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slIndex := ', slIndex, '');
	
	// Set Item Tiers
	for x := 1 to 6 do
		SetObject('0'+IntToStr(x), Integer(GetObject('ItemTier0'+IntToStr(x), slGlobal)), slItemTiers);
	
	// Get a list of existing records
	slExistingRecords.Clear;
	slTemp.CommaText := 'ARMO, AMMO, WEAP';
	for x := 0 to slTemp.Count-1 do begin
		tempElement := gbs(GEVfile, slTemp[x]);
		for y := 0 to Pred(ec(tempElement)) do
			slExistingRecords.Add(EditorID(ebi(tempElement, y)));
	end;
	// {Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slExistingRecords := ', slExistingRecords, '');
	
	// Process
	processStartTime := Time;
	for i := 0 to slRecords.Count-1 do begin
		// Common function output
		{Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slRecords := ', slRecords, '');
		selectedRecord := ote(slRecords.Objects[i]);
		{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] selectedRecord := '+EditorID(ote(slRecords.Objects[i])));
		record_sig := sig(selectedRecord);
		{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] record_sig := '+record_sig);
		record_edid := EditorID(selectedRecord);
		
		// Detect Pre-Existing Leveled Lists
		tempStartTime := Time;
		{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] Detecting Pre-Existing Leveled Lists');
		enchLevelList := nil;
		chanceLevelList := nil;
		for x := 0 to Pred(rbc(selectedRecord)) do begin
			tempRecord := rbi(selectedRecord, x);
			if (sig(tempRecord) = 'LVLI') then begin
				tempString := EditorID(tempRecord);
				if StrWithinStr(tempString, 'Ench') and StrWithinStr(tempString, '++') and not StrWithinStr(tempString, 'Chance') then	begin								
					if not (GetLoadOrder(GEVfile) = GetLoadOrder(GetFile(tempRecord))) then
						enchLevelList := CopyRecordToFile(tempRecord, GEVfile, False, True)
					else
						enchLevelList := tempRecord;
				end else if StrWithinStr(tempString, 'Chance') and StrWithinStr(tempString, '++') then									
					if not (GetLoadOrder(GEVfile) = GetLoadOrder(GetFile(tempRecord))) then
						chanceLevelList := CopyRecordToFile(tempRecord, GEVfile, False, True)
					else
						chanceLevelList := tempRecord;				
			end;
			if Assigned(enchLevelList) and Assigned(chanceLevelList) then Break;
		end;
		tempStopTime := Time;
		if ProcessTime then addProcessTime('[GEV] Detect Pre-Existing Leveled Lists', TimeBtwn(tempStartTime, tempStopTime));
		
		// Create new Leveled Lists if not already present
		{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] Create new Leveled Lists if not already present');
		if not Assigned(enchLevelList) then begin
			slTemp.CommaText := '"Calculate from all levels <= player''s level", "Calculate for each item in count"';
			{Debug} if debugMsg then msgList('createLeveledList( '+GetFileName(GEVfile)+', LItem'+StrCapFirst(record_sig)+'Ench'+record_edid+'++, ', slTemp, ', 0 );');		
			enchLevelList := createLeveledList(GEVfile, 'LItem'+StrCapFirst(record_sig)+'Ench'+record_edid+'++', slTemp, 0);
			addToLeveledList(enchLevelList, selectedRecord, 1);
		end;
		if not Assigned(chanceLevelList) then begin
			{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] createChanceLeveledList( '+GetFileName(GEVfile)+', LItem'+StrCapFirst(record_sig)+'EnchChance'+record_edid+'++, '+IntToStr(Integer(GetObject('ChanceMultiplier', slGlobal)))+', '+record_edid+', '+EditorID(enchLevelList)+' );');	
			chanceLevelList := createChanceLeveledList(GEVfile, 'LItem'+StrCapFirst(record_sig)+'EnchChance'+record_edid+'++', Integer(GetObject('ChanceMultiplier', slGlobal)), selectedRecord, enchLevelList);
			slEnchanted.AddObject(record_edid, TObject(chanceLevelList));
		end;
		
		// Process records using the indexed list
		tempStartTime := Time;
		msg('Processing '+record_edid+' enchanted versions');
		{Debug} if debugMsg then msg('record_sig := '+record_sig);	
		if (record_sig = 'ARMO') then begin 
			slTemp.Clear;
			slGetFlagValues(selectedRecord, slTemp, False);
			// Non-vanilla armor types prioritize keywords over BOD2
			slTempList.CommaText :=  '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlets, 37 - Feet, 39 - Shield
			if not StrWithinStrSL(slTemp, slTempList) then begin
				{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] [Process Records using Indexed List] No Vanilla Slot Detected');
				for y := 0 to slTemp.Count-1 do begin
					if not slContains(slTemp, AssociatedBOD2(slTemp[y])) then begin
						{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] [Process Records using Indexed List] AssociatedBOD2 := '+AssociatedBOD2(slTemp[y]));
						slTemp.Add(AssociatedBOD2(slTemp[y]));
					end;
				end;
			end else
				{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] [Process Records using Indexed List] Vanilla Slot Detected');
			// Adds clothing type to the BOD2 string
			for x := 0 to slTemp.Count-1 do begin
				if not ((slTemp[x] = '30') or (slTemp[x] = '35') or (slTemp[x] = '36')) then
					slTemp[x] := slTemp[x]+'-'+geev(ElementBySignature(selectedRecord, GetElementType(tempRecord)), 'Armor Type');
			end;
			tempString := nil;
		end;
		for x := 0 to slIndex.Count-1 do begin
			objEffect := nil;
			if (record_sig = 'ARMO') then begin 	
				{Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slTemp := ', slTemp, '');
				for y := 0 to slTemp.Count-1 do begin
					{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] slTemp[y] := '+slTemp[y]);
					if StrWithinStr(slIndex[x], slTemp[y]) then begin
						objEffect := ote(slIndex.Objects[x]);
						{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] objEffect := '+EditorID(objEffect));
						Break;
					end;
				end;
			end else begin
				if StrWithinStr(slIndex[x], record_sig) then begin
					objEffect := ote(slIndex.Objects[x]);
					if StrWithinStr(EditorID(objEffect), 'Trap') then Continue;
					{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] objEffect := '+EditorID(objEffect));
				end;	
			end;
			if Assigned(objEffect) then begin
				// Skip rare enchantments that are only applied to a single item
				// if (rbc(objEffect) <= 1) then Continue;
				// Skip weapon enchantments on armor pieces.  Not sure this happens yet.
				// if (sig(selectedRecord) = 'ARMO') and StrWithinStr(EditorID(objEffect), 'Weapon') then Continue;
				tempInteger := GetEnchLevel(objEffect, slItemTiers); {Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] enchLevel := '+IntToStr(tempInteger));
				if (tempInteger >= 0) then begin					
					enchAmount := (enchMultiplier div 100)*geev(objEffect, 'ENIT\Enchantment Amount');
					tempString := nil;
					// Sorting Mod Stuff
					if DoesFileExist('AnotherSortingMod_2017-SSE.esp') then								
						for z := 0 to slItemTiers.Count-1 do
							if (slItemTiers.Objects[z] = tempInteger) then
								tempString := slItemTiers[z];
					suffix := nil;
					// Check for specific enchantment name
					slTempList.Clear;
					for z := 0 to Pred(rbc(objEffect)) do
						if StrWithinStr(full(rbi(objEffect, z)), 'of ') then
							slTempList.Add(StrPosCopy(full(rbi(objEffect, z)), 'of ', False));
					suffix := MostCommonString(slTempList);
					// If there is no enchantment name then use the objEffect name
					if (suffix = '') then
						suffix := StrPosCopy(full(objEffect), 'of', False);
					if (tempString <> '') then
						suffix := suffix+' '+DecToRoman(StrToInt(tempString));
					// Pre-Existing records
					if not slContains(slExistingRecords, EditorID(selectedRecord)+'_'+EditorID(objEffect)) then begin
						tempElement := CopyRecordToFile(selectedRecord, GEVfile, True, True); {Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] enchRecord := '+EditorID(tempElement));
					end else
						Continue;
					// Generate Enchantment
					tempRecord := createEnchantedVersion(selectedRecord, GEVfile, objEffect, tempElement, suffix, Round(enchAmount), AllowDisenchanting); {Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] tempRecord := CreateEnchantedVersion( '+record_edid+', '+GetFileName(GEVfile)+', '+EditorID(objEffect)+', '+EditorID(tempElement)+', '+StrPosCopy(full(objEffect), 'of', False)+', '+IntToStr(Round(enchAmount))+', '+BoolToStr(AllowDisenchanting)+' );');																								
					addToLeveledList(enchLevelList, tempRecord, tempInteger); {Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] AddToLeveledList( '+EditorID(enchLevelList)+', '+EditorID(tempRecord)+', '+IntToStr(tempInteger)+' );');
					slExistingRecords.Add(EditorID(tempRecord));
				end;
			end;
		end;
		tempStopTime := Time;
		if ProcessTime then addProcessTime('[GEV] Process Records using Indexed List', TimeBtwn(tempStartTime, tempStopTime));
		// Leveled Lists
		if ReplaceInLeveledList then begin
			//  Add to enchanted lists
			tempElement := nil;
			if (sig(selectedRecord) = 'WEAP') then begin
				tempElement := ebEDID(gbs(FileByName('Skyrim.esm'), 'LVLI'), 'LItemEnch'+EditorID(ote(GetObject(EditorID(selectedRecord)+'Template', slGlobal)))); {Debug} if debugMsg then msg('tempElement := '+EditorID(tempElement));
			end else
				tempElement := ebEDID(gbs(FileByName('Skyrim.esm'), 'LVLI'), 'LItemEnchArmor'+StrPosCopy(geev(selectedRecord, 'BOD2\Armor Type'), ' ', True)+GetItemType(selectedRecord)); {Debug} if debugMsg then msg('tempElement := '+EditorID(tempElement));		
			if Assigned(tempElement) then begin
				tempRecord := nil;
				if HasFileOverride(tempElement, GEVfile) then begin
					tempRecord := GetFileOverride(tempElement, GEVfile);
				end else
					tempRecord := CopyRecordToFile(selectedRecord, GEVfile, False, True);
				if Assigned(tempRecord) then
					addToLeveledList(tempRecord, enchLevelList, GEVfile);
			end;
		end;
	end;
	processStopTime := Time;
	if ProcessTime then addProcessTime('[GEV] Process', TimeBtwn(processStartTime, processStopTime));
	
	// Replace original with enchanted versions
	if ReplaceInLeveledList then
		ReplaceInLeveledListByList(slRecords, slEnchanted, GEVfile);
	
	// Set Result
	{Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slGlobal := ', slGlobal, '');
	
	// Finalize
	stopTime := Time;
	addProcessTime('GenerateEnchantedVersionsAuto', TimeBtwn(startTime, stopTime));
	if Assigned(slExistingRecords) then slExistingRecords.Free;
	if Assigned(slEnchanted) then slEnchanted.Free;
	if Assigned(slItemTiers) then slItemTiers.Free;
	if Assigned(slTempList) then slTempList.Free;
	if Assigned(slRecords) then slRecords.Free;
	if Assigned(slIndex) then slIndex.Free;
	if Assigned(slFiles) then slFiles.Free;
	if Assigned(slTemp) then slTemp.Free;
end;

// Indexes an Object effect
Procedure IndexObjEffect(aRecord: IInterface; BOD2List, aList: TStringList);
var
	slTemp, slBOD2, slFlagOutput: TStringList;
	objEffect, tempRecord: IInterface;
	debugMsg, tempBoolean: Boolean;
	startTime, stopTime: TDateTime;
	tempString: String;
	i, x, y: Integer;
begin
	// Initialize
	debugMsg := False;
	startTime := Time;
	slBOD2 := TStringList.Create;
	slTemp := TStringList.Create;
	slFlagOutput := TStringList.Create;
	{Debug} if debugMsg then msgList('[IndexObjEffect] input BOD2 := ', BOD2List, '');
	
	// Function
	for i := 0 to Pred(ec(gbs(aRecord, 'ENCH'))) do begin 
		slBOD2.Assign(BOD2List);
		tempRecord := WinningOverride(ebi(gbs(aRecord, 'ENCH'), i));
		if (EditorID(objEffect) = EditorID(tempRecord)) then Continue;
		objEffect := tempRecord;
		{Debug} if debugMsg then msg('[IndexObjEffect] objEffect := '+EditorID(objEffect));
		// Check for recognizable EditorID
		tempBoolean := False;
		tempString := EditorID(objEffect);
		slTemp.CommaText := 'Nightingale, Chillrend, Frostmere, trap, Miraak';
		if SLWithinStr(tempString, slTemp) then
			Continue;
		slTemp.Clear;
		// Check for vanilla suffix
		for x := 1 to 6 do
			if StrEndsWith(tempString, '0'+IntToStr(x)) then
				tempBoolean := True;
		// Check for Sorting Mod prefix
		if not tempBoolean then
			if (Copy(tempString, 1, 2) = 'aa') then
				tempBoolean := True;
		// Check for Eldritch Magic Enchantments Prefix
		if not tempBoolean then
			if StrWithinStr(tempString, 'EldEnch') then
				tempBoolean := True;
		if tempBoolean then begin
			tempString := nil;
			// Search objEffect references for matching BOD2 slot
			for x := 0 to Pred(rbc(objEffect)) do begin
				tempRecord := rbi(objEffect, x);
				// {Debug} if debugMsg then msg('[IndexObjEffect] tempRecord := '+EditorID(tempRecord));
				if (sig(tempRecord) = 'ARMO') then begin
					// Get this record's BOD2
					slFlagOutput.Clear;
					slGetFlagValues(tempRecord, slFlagOutput, False);
					// {Debug} if debugMsg then msgList('[IndexObjEffect] slGetFlagValues := ', slTemp, '');
					// Add clothing type to BOD2
					for y := 0 to slFlagOutput.Count-1 do begin
						if not ((slFlagOutput[y] = '30') or (slFlagOutput[y] = '35') or (slFlagOutput[y] = '36')) then
							slFlagOutput[y] := Trim(slFlagOutput[y])+'-'+Trim(geev(ElementBySignature(tempRecord, GetElementType(tempRecord)), 'Armor Type'));
					end;
					// Add to this ObjEffect's BOD2 if not already present
					for y := 0 to slFlagOutput.Count-1 do
						if not slContains(slTemp, slFlagOutput[y]) then
							slTemp.Add(slFlagOutput[y]);
				end else
					if not slContains(slTemp, sig(tempRecord)) then
						slTemp.Add(sig(tempRecord));
				// If detected BOD2 matches input BOD2 add to this record's list			
				for y := 0 to slTemp.Count-1 do begin
					// {Debug} if debugMsg then msg('[IndexObjEffect] if slContains(slBOD2, '+slTemp[y]+' then begin');
					if slContains(slBOD2, slTemp[y]) then begin
						tempString := Trim(tempString+' '+slTemp[y]);
						slBOD2.Delete(slBOD2.IndexOf(slTemp[y]));
					end;
				end;
				if (slBOD2.Count <= 0) then Break;
			end;
			{Debug} if debugMsg then msg('[IndexObjEffect] '+EditorID(objEffect)+' slBOD2 := '+tempString);
			if (tempString <> '') then begin
				{Debug} if debugMsg then msg('[IndexObjEffect] aList.AddObject( '+Trim(tempString)+', '+EditorID(objEffect)+' );');
				aList.AddObject(tempString, TObject(objEffect));
			end;
		end;
	end;

	//Finalize
	{Debug} if debugMsg then msgList('[IndexObjEffect] aList := ', aList, '');
	stopTime := Time;
	addProcessTime('IndexObjEffect', TimeBtwn(startTime, stopTime));
	slBOD2.Free;
	slTemp.Free;
	slFlagOutput.Free;
	
	debugMsg := False;
// End debugMsg section
end;


// Gets an object by IntToStr EditorID
function IndexOfObjectEDID(s: String; aList: TStringList): Integer;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[IndexOfObjectEDID] IndexOfObjectEDID( '+s+', aList );');
	for i := 0 to aList.Count-1 do begin
		if StrWithinStr(EditorID(ote(aList.Objects[i])), s) then begin
			Result := i;
			{Debug} if debugMsg then msg('[IndexOfObjectEDID] Result := '+IntToStr(Result));
		end;
	end;
	
	debugMsg := False;
// End debugMsg section
end;

// Gets an object by IntToStr EditorID
function IndexOfObjectbyFULL(s: String; aList: TStringList): Integer;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[IndexOfObjectbyFULL] IndexOfObjectbyFULL( '+s+', aList );');
	for i := 0 to aList.Count-1 do begin
		if StrWithinStr(full(ote(aList.Objects[i])), s) then begin
			Result := i;
			{Debug} if debugMsg then msg('[IndexOfObjectbyFULL] Result := '+IntToStr(Result));
		end;
	end;
	
	debugMsg := False;
// End debugMsg section
end;

function IsHighestOverride(aRecord: IInterface; aInteger: Integer): Boolean;
var
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := False;
	
	Result := False;
	{Debug} if debugMsg then msg('[IsHighestOverride] IsHighestOverride( '+EditorID(aRecord)+', '+GetFileName(FileByLoadOrder(aInteger))+' )');
	{Debug} if debugMsg then msg('[IsHighestOverride] if GetLoadOrder( '+GetFileName(GetFile(aRecord))+' ) := '+IntToStr(GetLoadOrder(GetFile(aRecord)))+' = '+IntToStr(GetLoadOrder(GetFile(HighestOverrideOrSelf(aRecord, aInteger))))+' := GetLoadOrder( '+GetFileName(GetFile(HighestOverrideOrSelf(aRecord, aInteger)))+' ) then');
	if (GetLoadOrder(GetFile(aRecord)) = GetLoadOrder(GetFile(HighestOverrideOrSelf(aRecord, aInteger)))) then
		Result := True;
	{Debug}  if debugMsg then msg('[IsHighestOverride] Result := '+BoolToStr(Result));
	
	debugMsg := False;
// End debugMsg section
end;

// Creates new COBJ record to make item temperable [SkyrimUtils]
function MakeTemperable(aRecord: IInterface; lightInteger, heavyInteger: Integer; aPlugin: IInterface): IInterface;
var
  recipeTemper, recipeCondition, tempRecord: IInterface;
	tempBoolean: Boolean;
	slTemp: TStringList;
	record_sig: String;
	debugMsg: Boolean;
  i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Initialize
	slTemp := TStringList.Create;
	
	// CHECK FOR PRE-EXISTING
	
	// Common function output
	{Debug} if debugMsg then msg('[MakeTemperable] MakeTemperable( '+EditorID(aRecord)+', '+IntToStr(lightInteger)+', '+IntToStr(heavyInteger)+', '+GetFileName(aPlugin)+' );');
	record_sig := sig(aRecord);
	{Debug} if debugMsg then msg('[MakeTemperable] record_sig := '+record_sig);
	
  // Filter invalid records
	tempBoolean := False;
	if Assigned(ebp(aRecord, 'CNAM')) then 
		tempBoolean := True;
	if not tempBoolean then
		if not ((record_sig = 'WEAP') or (record_sig = 'ARMO') or (record_sig = 'AMMO')) then
			tempBoolean := True;
	slTemp.CommaText := 'Circlet, Ring, Necklace';
	if not tempBoolean then
		if StrWithinSL(full(aRecord), slTemp) or StrWithinSL(EditorID(aRecord), slTemp) then
			tempBoolean := True;
	if not tempBoolean then
		for i := 0 to Pred(rbc(aRecord)) do
			if (sig(rbi(aRecord, i)) = 'COBJ') and StrWithinStr(EditorID(rbi(aRecord, i)), 'Temper') then
				tempBoolean := True;
	if not tempBoolean then
		if IsClothing(aRecord) then
			tempBoolean := True;
	if tempBoolean then begin
		slTemp.Free;
		Exit;
	end;
			
	// Add conditions
	{Debug} if debugMsg then msg('[MakeTemperable] Add conditions');
  recipeTemper := createRecipe(aRecord, aPlugin);
  Add(recipeTemper, 'Conditions', True);
	RemoveInvalidEntries(recipeTemper);
  recipeCondition := ebp(recipeTemper, 'Conditions');
	seev(ebp(recipeCondition, 'Condition\CTDA'), 'Type', '00010000');
	seev(ebp(recipeCondition, 'Condition\CTDA'), 'Comparison Value', '1');
  seev(ebp(recipeCondition, 'Condition\CTDA'), 'Function', 'EPTemperingItemIsEnchanted'); 
  seev(ebp(recipeCondition, 'Condition\CTDA'), 'Run On', 'Subject');
  seev(ebp(recipeCondition, 'Condition\CTDA'), 'Parameter #3', '-1');
	AddPerkCondition(ebp(recipeTemper, 'Conditions'), GetRecordByFormID('0005218E')); // ArcaneBlacksmith
  
	{Debug} if debugMsg then msg('[MakeTemperable] if record_sig := '+record_sig+' = WEAP then begin');
  if (record_sig = 'WEAP') then begin
    seev(recipeTemper, 'BNAM', GetEditValue(GetRecordByFormID('00088108')));
		{Debug} if debugMsg then msg('[MakeTemperable] GetFileName(GetFile(aRecord)) := '+GetFileName(GetFile(aRecord)));
    seev(recipeTemper, 'EDID', 'TemperWeapon_'+Trim(RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(aRecord)))))+'_'+Trim(EditorID(aRecord)));	
  end;
	{Debug} if debugMsg then msg('[MakeTemperable] if record_sig := '+record_sig+' = ARMO then begin');
	if (record_sig = 'ARMO') then begin
    seev(recipeTemper, 'BNAM', GetEditValue(GetRecordByFormID('000ADB78')));
		{Debug} if debugMsg then msg('[MakeTemperable] GetFileName(GetFile(aRecord)) := '+GetFileName(GetFile(aRecord)));
    seev(recipeTemper, 'EDID', 'TemperArmor_'+Trim(RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(aRecord)))))+'_'+Trim(EditorID(aRecord)));
  end;
	// Add valid combinations
	slTemp.Clear;
	// Weapon
	slTemp.AddObject('WeapMaterialIron', TObject(GetRecordByFormID('0005ACE4')));
	slTemp.AddObject('WeapMaterialSteel', TObject(GetRecordByFormID('0005ACE5')));
	slTemp.AddObject('WeapMaterialElven', TObject(GetRecordByFormID('0005ADA0')));
	slTemp.AddObject('WeapMaterialDwarven', TObject(GetRecordByFormID('000DB8A2')));
	slTemp.AddObject('WeapMaterialEbony', TObject(GetRecordByFormID('0005AD9D')));
	slTemp.AddObject('WeapMaterialDaedric', TObject(GetRecordByFormID('0005AD9D')));
	slTemp.AddObject('WeapMaterialWood', TObject(GetRecordByFormID('0006F993')));
	slTemp.AddObject('WeapMaterialSilver', TObject(GetRecordByFormID('0005ACE3')));
	slTemp.AddObject('WeapMaterialOrcish', TObject(GetRecordByFormID('0005AD99')));
	slTemp.AddObject('WeapMaterialGlass', TObject(GetRecordByFormID('0005ADA1')));
	slTemp.AddObject('WeapMaterialFalmer', TObject(GetRecordByFormID('0003AD57')));
	slTemp.AddObject('WeapMaterialFalmerHoned', TObject(GetRecordByFormID('0003AD57')));
	slTemp.AddObject('DLC1WeapMaterialDragonbone', TObject(GetRecordByFormID('0003ADA4')));
	slTemp.AddObject('DLC2WeaponMaterialStalhrim', TObject(GetRecordByFormID('0402B06B')));
	// Armor
	slTemp.AddObject('ArmorMaterialIron', TObject(GetRecordByFormID('0005ACE4')));
	slTemp.AddObject('ArmorMaterialStudded', TObject(GetRecordByFormID('0005ACE4')));
	slTemp.AddObject('ArmorMaterialElven', TObject(GetRecordByFormID('0005AD9F')));
	slTemp.AddObject('DLC2ArmorMaterialChitinLight', TObject(GetRecordByFormID('0402B04E')));
	slTemp.AddObject('DLC2ArmorMaterialChitinHeavy', TObject(GetRecordByFormID('0402B04E')));
	slTemp.AddObject('DLC1ArmorMaterielFalmerHeavy', TObject(GetRecordByFormID('0003AD57')));
	slTemp.AddObject('DLC1ArmorMaterielFalmerHeavyOriginal', TObject(GetRecordByFormID('0003AD57')));
	slTemp.AddObject('DLC1ArmorMaterialFalmerHardened', TObject(GetRecordByFormID('0402B06B')));
	slTemp.AddObject('DLC2ArmorMaterialBonemoldLight', TObject(GetRecordByFormID('0401CD7C')));
	slTemp.AddObject('DLC2ArmorMaterialBonemoldHeavy', TObject(GetRecordByFormID('0401CD7C')));
	slTemp.AddObject('ArmorMaterialScaled', TObject(GetRecordByFormID('0005AD93')));
	slTemp.AddObject('ArmorMaterialIronBanded', TObject(GetRecordByFormID('0005AD93')));
	slTemp.AddObject('DLC2ArmorMaterialStalhrimLight', TObject(GetRecordByFormID('0402B06B')));
	slTemp.AddObject('DLC2ArmorMaterialStalhrimHeavy', TObject(GetRecordByFormID('0402B06B')));
	slTemp.AddObject('DLC2ArmorMaterialNordicLight', TObject(GetRecordByFormID('0005ADA0')));
	slTemp.AddObject('DLC2ArmorMaterialNordicHeavy', TObject(GetRecordByFormID('0005ADA0')));
	slTemp.AddObject('ArmorMaterialElvenGilded', TObject(GetRecordByFormID('0005ADA0')));
	slTemp.AddObject('ArmorMaterialHide', TObject(GetRecordByFormID('000DB5D2')));
	slTemp.AddObject('ArmorMaterialLeather', TObject(GetRecordByFormID('000DB5D2')));
	slTemp.AddObject('DLC2ArmorMaterialMoragTong', TObject(GetRecordByFormID('000DB5D2')));
	slTemp.AddObject('ArmorMaterialSilver', TObject(GetRecordByFormID('0005ACE3')));
	slTemp.AddObject('ArmorMaterialGlass', TObject(GetRecordByFormID('0005ADA1')));
	slTemp.AddObject('ArmorMaterialEbony', TObject(GetRecordByFormID('0005AD9D')));
	slTemp.AddObject('ArmorMaterialDaedric', TObject(GetRecordByFormID('0005AD9D')));
	slTemp.AddObject('ArmorMaterialDwarven', TObject(GetRecordByFormID('000DB8A2')));
	slTemp.AddObject('ArmorMaterialDragonscale', TObject(GetRecordByFormID('0003ADA3')));
	slTemp.AddObject('ArmorMaterialDragonplate', TObject(GetRecordByFormID('0003ADA4')));
	slTemp.AddObject('ArmorMaterialSteel', TObject(GetRecordByFormID('0005ACE5')));
	slTemp.AddObject('ArmorMaterialImperialHeavy', TObject(GetRecordByFormID('0005ACE5')));
	slTemp.AddObject('ArmorMaterialImperialLight', TObject(GetRecordByFormID('0005ACE5')));
	slTemp.AddObject('ArmorMaterialSteelPlate', TObject(GetRecordByFormID('0005ACE5')));
	slTemp.AddObject('ArmorMaterialStormcloak', TObject(GetRecordByFormID('0005ACE5')));
	slTemp.AddObject('ArmorMaterialImperialStudded', TObject(GetRecordByFormID('0005ACE5')));
	slTemp.AddObject('DLC1ArmorMaterialDawnguard', TObject(GetRecordByFormID('0005ACE5')));
	// Detect value
	if slTemp.Count > 0 then begin
		Add(recipeTemper, 'items', true);
		for i := 0 to slTemp.Count-1 do begin
			{Debug} if debugMsg then msg('[MakeTemperable] if HasKeyword( '+EditorID(aRecord)+', '+slTemp[i]+' ) then begin');
			if HasKeyword(aRecord, slTemp[i]) then begin
				{Debug} if debugMsg then msg('[MakeTemperable] addItem( '+EditorID(recipeTemper)+', '+EditorID(ote(slTemp.Objects[i]))+', 1);');
				addItem(recipeTemper, ote(slTemp.Objects[i]), 1);
			end;
		end;
	end else begin
		msg('[ERROR] [MakeTemperable] Keyword list did not generate');
		Remove(recipeTemper);
		Exit;
	end;
  removeInvalidEntries(recipeTemper);
	// If a vanilla keyword is not detected
  if (geev(recipeTemper, 'COCT') = '') then begin
		tempRecord := GetTemplate(aRecord);
		for i := 0 to slTemp.Count-1 do begin
			{Debug} if debugMsg then msg('[MakeTemperable] if HasKeyword( '+EditorID(tempRecord)+', '+slTemp[i]+' ) then begin');
			if HasKeyword(tempRecord, slTemp[i]) then begin
				{Debug} if debugMsg then msg('[MakeTemperable] addItem( '+EditorID(recipeTemper)+', '+EditorID(ote(slTemp.Objects[i]))+', 1);');
				if ee(aRecord, 'BOD2') then begin
					{Debug} if debugMsg then msg('[MakeTemperable] if ( geev(aRecord, ''BOD2\Armor Type'') := '+geev(aRecord, 'BOD2\Armor Type')+' = Heavy Armor ) then begin');
					if (geev(aRecord, 'BOD2\Armor Type') = 'Heavy Armor') then begin
						addItem(recipeTemper, ote(slTemp.Objects[i]), heavyInteger);
					end else if (geev(aRecord, 'BOD2\Armor Type') = 'Light Armor') then
						addItem(recipeTemper, ote(slTemp.Objects[i]), lightInteger);
				end else if ee(aRecord, 'DNAM\Skill') or ee(aRecord, 'DNAM\Animation Type') then begin
					if (geev(aRecord, 'DNAM\Skill') =  'Two Handed') or StrWithinStr(geev(aRecord, 'DNAM\Animation Type'), 'TwoHand') then begin
						addItem(recipeTemper, ote(slTemp.Objects[i]), heavyInteger);
					end else
						addItem(recipeTemper, ote(slTemp.Objects[i]), lightInteger);
				end else
					addItem(recipeTemper, ote(slTemp.Objects[i]), lightInteger);
			end;
		end;		
	end;
	{Debug} if debugMsg then msg('[makeTemperable] Result := '+EditorID(recipeTemper));
  Result := recipeTemper;
	
	// Finalize
	slTemp.Free;
	
	debugMsg := False;
// End debugMsg section
end;

function MakeCraftable(aRecord, aPlugin: IInterface): IInterface;
var
	tempRecord, templateRecord, recipeRecord: IInterface;
	slTemp: TStringList;
	tempString: String;
	debugMsg, RecipeScaling: Boolean;
	i, tempInteger: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Initialize
	{Debug} if debugMsg then msg('[MakeCraftable] MakeCraftable( '+EditorID(aRecord)+', '+GetFileName(aPlugin)+' );');
	if Assigned(ebp(aRecord, 'EITM')) then Exit;
	slTemp := TStringList.Create;
	RecipeScaling := Boolean(GetObject('RecipeScaling', slGlobal));
	
	// Check for pre-existing crafting recipe
	for i := 0 to Pred(rbc(aRecord)) do begin
		tempRecord := rbi(aRecord, i);
		if (sig(tempRecord) = 'COBJ') then begin
			if StrWithinStr(EditorID(tempRecord), 'Recipe') then begin
				slTemp.Free;
				Exit;
			end;
		end;
	end;
	
	// Process
	if IsClothing(aRecord) then begin
		recipeRecord := createRecipe(aRecord, aPlugin);	
		senv(recipeRecord, 'BNAM', $0007866A); // Tanning Rack
		if ee(aRecord, 'DATA\Value') then begin
			tempString := geev(selectedRecord, 'DATA\Value');
		end else
			tempString := '1';
		if (Length(tempString) >= 2) then begin
			tempString := Copy(tempString, 0, Length(tempString)-1);
			tempInteger := (StrToInt(tempString) div 2);
		end else
			tempInteger := 1;
		addItem(recipeRecord, GetRecordByFormID('000DB5D2'), tempInteger); // Leather
		RemoveInvalidEntries(recipeRecord);
		seev(recipeRecord, 'CNAM', ShortName(aRecord)); {Debug} if debugMsg then msg('[MakeCraftable] seev( '+EditorID(recipeRecord)+', CNAM, '+ShortName(aRecord)+' );+');			
		seev(recipeRecord, 'EDID', 'Recipe_'+Trim(RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(aRecord)))))+'_'+Trim(EditorID(aRecord))); {Debug} if debugMsg then msg('[MakeCraftable] seev( '+EditorID(recipeRecord)+', EDID, RecipeWeapon_'+Trim(RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(aRecord)))))+'_'+Trim(EditorID(aRecord)));
		slTemp.Free;
		Exit;
	end;
	slTemp.CommaText := 'Wood, Iron, Steel, Dwarven, Elven, Orcish, Glass, Ebony, Dragonbone';
	tempInteger := -1;
	for i := 0 to slTemp.Count-1 do begin
		if HasKeyword(aRecord, 'WeapMaterial'+slTemp[i]) or HasKeyword(aRecord, 'ArmorMaterial'+slTemp[i]) then begin
			{Debug} if debugMsg then msg('[MakeCraftable] slTemp[i] := '+slTemp[i]);
			tempInteger := i;
			Break;
		end;
	end;
	if (tempInteger > 0) then begin
		templateRecord := GetTemplate(aRecord);
		for i := 0 to Pred(rbc(templateRecord)) do begin
			tempRecord := rbi(templateRecord, i); {Debug} if debugMsg then msg('[MakeCraftable] tempRecord := '+EditorID(tempRecord));
			if not (sig(tempRecord) = 'COBJ') then Continue;			
			if StrWithinStr(EditorID(tempRecord), 'Recipe') then begin
				AddMastersAuto(tempRecord, aPlugin);
				recipeRecord := CopyRecordToFile(tempRecord, aPlugin, True, True); {Debug} if debugMsg then msg('[MakeCraftable] recipeRecord := '+EditorID(recipeRecord));			
				Break;
			end;
		end; 
		{Debug} if debugMsg then msg('[MakeCraftable] if Assigned(recipeRecord) := '+BoolToStr(Assigned(recipeRecord)));
		if Assigned(recipeRecord) then begin		
			seev(recipeRecord, 'CNAM', ShortName(aRecord)); {Debug} if debugMsg then msg('[MakeCraftable] seev( '+EditorID(recipeRecord)+', CNAM, '+ShortName(aRecord)+' );+');			
			seev(recipeRecord, 'EDID', 'Recipe_'+Trim(RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(aRecord)))))+'_'+Trim(EditorID(aRecord))); {Debug} if debugMsg then msg('[MakeCraftable] seev( '+EditorID(recipeRecord)+', EDID, RecipeWeapon_'+Trim(RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(aRecord)))))+'_'+Trim(EditorID(aRecord)));
		end;
		for i := 0 to slTemp.Count-1 do begin
			if not (tempInteger > 0) then Break;
			if HasKeyword(templateRecord, 'WeapType'+slTemp[i]) or HasKeyword(aRecord, 'ArmorMaterial'+slTemp[i]) then begin
				tempInteger := i - tempInteger; {Debug} if debugMsg then msg('[MakeCraftable] Tier Difference := '+IntToStr(tempInteger));				
				Break;
			end;					
		end;	
		if (tempInteger > 0) and RecipeScaling then begin
			for i := 0 to Pred(ec(gbs(recipeRecord, 'Items'))) do begin			
				SetNativeValue(ebp(gbs(recipeRecord, 'Items'), 'Item\Count'), 2*tempInteger*StrToInt(geev((ebp(gbs(recipeRecord, 'Items'), 'Item\Count'))))); {Debug} if debugMsg then msg('[MakeCraftable] SetNativeValue(ebp(gbs( '+EditorID(recipeRecord)+', Items ), Item\Count ), '+IntToStr(tempInteger*GetNativeValue(ebp(gbs(recipeRecord, 'Items'), 'Item\Count'))));
			end;
		end;
	end else begin {Debug} if debugMsg then msg('[MakeCraftable] end else begin');
		templateRecord := GetTemplate(aRecord); {Debug} if debugMsg then msg('[MakeCraftable] templateRecord := '+EditorID(templateRecord));		
		for i := 0 to Pred(rbc(templateRecord)) do begin
			tempRecord := rbi(templateRecord, i);
			if not (sig(tempRecord) = 'COBJ') then Continue;
			{Debug} if debugMsg then msg('[MakeCraftable] tempRecord := '+EditorID(tempRecord));
			if StrWithinStr(EditorID(tempRecord), 'Recipe') then begin
				AddMastersAuto(tempRecord, aPlugin);
				recipeRecord := CopyRecordToFile(tempRecord, aPlugin, True, True); {Debug} if debugMsg then msg('[MakeCraftable] recipeRecord := '+EditorID(recipeRecord));
				seev(recipeRecord, 'CNAM', ShortName(aRecord));
				seev(recipeRecord, 'EDID', 'Recipe_'+Trim(RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(aRecord)))))+'_'+Trim(EditorID(aRecord)));				
				Break;
			end;
		end;		
	end;
	
	// Finalize
	slTemp.Free;
	
	debugMsg := False;
// End debugMsg section
end;

// Add get item count condition
Procedure AddGetItemCountCondition(rec: IInterface; s: string; aBoolean: Boolean);
var
  conditions, condition: IInterface;
begin
  conditions := ebp(rec, 'Conditions');
  if not Assigned(conditions) then begin
    Add(rec, 'Conditions', True);
    conditions := ebp(rec, 'Conditions');
    condition := ebp(ebi(conditions, 0), 'CTDA');
  end else
    condition := ElementAssign(conditions, HighInteger, nil, False);
  seev(condition, 'Type', '11000000'); // Greater than or equal to
  seev(condition, 'Comparison Value', '1.0');
  seev(condition, 'Function', 'GetItemCount');
  seev(condition, 'Inventory Object', s);
  if aBoolean then begin
    condition := ElementAssign(conditions, HighInteger, nil, False);
    seev(condition, 'Type', '10010000'); // Equal to / OR
    seev(condition, 'Comparison Value', '0.0');
    seev(condition, 'Function', 'GetEquipped');
    seev(condition, 'Inventory Object', s);
    condition := ElementAssign(conditions, HighInteger, nil, False);
    seev(condition, 'Type', '11000000'); // Greater than or equal to
    seev(condition, 'Comparison Value', '2.0');
    seev(condition, 'Function', 'GetItemCount');
    seev(condition, 'Inventory Object', s);
  end;
end;

function MakeBreakdown(aRecord, aPlugin: IInterface): IInterface;
var
	cobj, items, item, recipeRecord, tempRecord: IInterface;
	i, tempInteger, count, LeatherCount, x, hc, rc: integer;
	debugMsg, tempBoolean: Boolean;
	slTemp, slItem: TStringList;
  edid: string;
begin
// Begin debugMsg section
	debugMsg := False;
	
	// Initialize
	{Debug} if debugMsg then msgList('[MakeBreakdown] slGlobal := ', slGlobal, '');
	{Debug} if debugMsg then msg('[MakeBreakdown] MakeBreakdown( '+EditorID(aRecord)+', '+GetFileName(aPlugin)+' );');
	slTemp := TStringList.Create;
	slItem := TStringList.Create;

	// Load crafting recipe or skip records that already have a breakdown recipe
	for i := 0 to Pred(rbc(aRecord)) do begin
		tempRecord := rbi(aRecord, i);
		if (sig(tempRecord) = 'COBJ') then begin
			if StrWithinStr(EditorID(tempRecord), 'Recipe') then begin
				{Debug} if debugMsg then msg('[MakeBreakdown] Crafting recipe: '+EditorID(tempRecord));
				cobj := tempRecord;
			end else if StrWithinStr(EditorID(tempRecord), 'Breakdown') then begin
				{Debug} if debugMsg then msg('[MakeBreakdown] Breakdown already exists: '+EditorID(tempRecord));
				slTemp.Free;
				slItem.Free;
				Exit;
			end;
		end;
	end;
	
	// Skip invalid records
	{Debug} if debugMsg then msg('[MakeBreakdown] Skip invalid records');
	tempBoolean := False;
	if not Assigned(cobj) then
		tempBoolean := True;
	if not Boolean(GetObject('BreakdownEnchanted', slGlobal)) then
		if Assigned(ebp(cobj, 'EITM')) then
			tempBoolean := True;
	if not Boolean(GetObject('BreakdownDaedric', slGlobal)) then
		if HasItem(cobj, 'DaedraHeart') then
			tempBoolean := True;
	if not Boolean(GetObject('BreakdownDLC', slGlobal)) then begin
		slTemp.CommaText := 'DragonBone, DragonScales, DLC2ChitinPlate, ChaurusChitin, BoneMeal';
		for i := 0 to slTemp.Count-1 do
			if HasItem(cobj, slTemp[i]) then
				tempBoolean := True;
	end;
	if tempBoolean then begin
		slTemp.Free;
		slItem.Free;
		Exit;
	end;
	
	// Common Function Output
	{Debug} if debugMsg then msg('[MakeBreakdown] Common Function Output');
	items := ebp(cobj, 'Items');
	LeatherCount := 0;

	// Process ingredients
	{Debug} if debugMsg then msg('[MakeBreakdown] Process ingredients');
	for i := 0 to Pred(ec(items)) do begin
		item := LinksTo(ebp(ebi(items, i), 'CNTO - Item\Item'));
		count := geev(ebi(items, i), 'CNTO - Item\Count');		
		edid := EditorID(item);
		{Debug} if debugMsg then msg('[MakeBreakdown] edid := '+edid);
		{Debug} if debugMsg then msg('[MakeBreakdown] count := '+IntToStr(count));
		// if (edid = 'LeatherStrips') then Continue; // Why shouldn't leather strips be copied?
		slTemp.CommaText := 'ingot, bone, scale, chitin, stalhrim';
		for x := 0 to slTemp.Count-1 do
			if StrWithinStr(edid, slTemp[x]) then
				slItem.AddObject(Name(item), TObject(count));
		if (edid = 'Leather01') then 
			LeatherCount := count;
	end;
	{Debug} if debugMsg then msgList('[MakeBreakdown] slItem := ', slItem, '');
	{Debug} if debugMsg then msg('[MakeBreakdown] LeatherCount := '+IntToStr(LeatherCount));
	
	// Create breakdown recipeRecord at smelter or tanning rack
	{Debug} if debugMsg then msg('[MakeBreakdown] Create breakdown recipeRecord at smelter or tanning rack');
	if (slItem.Count > 0) then begin
		// Create at smelter
		{Debug} if debugMsg then msg('[MakeBreakdown] Create at smelter');
		if (slItem.Count = 1) and (Integer(slItem.Objects[0]) = 1) then begin
			// Skip making breakdown recipeRecord, can't produce less than 1 ingot
			{Debug} if debugMsg then msg('[MakeBreakdown] Skip making breakdown recipeRecord, can''t produce less than 1 ingot');
		end else begin			
			recipeRecord := Add(gbs(aPlugin, 'COBJ'), 'COBJ', True); {Debug} if debugMsg then msg('[MakeBreakdown] Make breakdown recipeRecord');		
			slTemp.CommaText := 'EDID, COCT, Items, CNAM, BNAM, NAM1'; {Debug} if debugMsg then msg('[MakeBreakdown] Add elements');
			for i := 0 to slTemp.Count-1 do
				Add(recipeRecord, slTemp[i], True);
			seev(recipeRecord, 'EDID', 'Breakdown'+StrCapFirst(sig(aRecord))+'_'+Trim(RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(aRecord)))))+'_'+Trim(EditorID(aRecord)));
			senv(recipeRecord, 'BNAM', $000A5CCE); // CraftingSmelter
			AddGetItemCountCondition(recipeRecord, ShortName(aRecord), Boolean(GetObject('BreakdownEquipped', slGlobal)));
			// Add items
			{Debug} if debugMsg then msg('[MakeBreakdown] Add items');
			items := ebp(recipeRecord, 'Items');
			item := ebi(items, 0);
			seev(item, 'CNTO - Item\Item', ShortName(aRecord));
			seev(item, 'CNTO - Item\Count', 1);
			seev(recipeRecord, 'COCT', 1);
			// Set created object stuff
			hc := 0;
			x := -1;
			for i := 0 to slItem.Count-1 do begin
				// Skip single items
				// if (Integer(slItem.Objects[i])-1 <= 0) then Continue;
				// Use first Item subelement or create new one
				if (Integer(slItem.Objects[i]) >= hc) then begin
					hc := Integer();
					x := i;
				end;
			end;
			if (x > -1) then begin
				seev(recipeRecord, 'CNAM', slItem[x]);
				tempInteger := Integer(slItem.Objects[x])-1;
				if (tempInteger = 0) then
					tempInteger := 1;
				seev(recipeRecord, 'NAM1', tempInteger);
				Inc(rc);
			end else begin
				{Debug} if debugMsg then msg('[MakeBreakdown] Remove(recipeRecord)');
				Remove(recipeRecord);
			end;
		end;
	end else if (LeatherCount > 0) then begin {Debug} if debugMsg then msg('[MakeBreakdown] Create at tanning rack');	
		recipeRecord := Add(gbs(aPlugin, 'COBJ'), 'COBJ', True);
		slTemp.CommaText := 'EDID, COCT, Items, CNAM, BNAM, NAM1';
		for i := 0 to slTemp.Count-1 do
			Add(recipeRecord, slTemp[i], True);
		seev(recipeRecord, 'EDID', 'Breakdown'+StrCapFirst(sig(aRecord))+'_'+Trim(RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(aRecord)))))+'_'+Trim(EditorID(aRecord)));
		senv(recipeRecord, 'BNAM', $0007866A); // CraftingTanningRack
		AddGetItemCountCondition(recipeRecord, ShortName(aRecord), Boolean(GetObject('BreakdownEquipped', slGlobal)));
		// Add items to recipeRecord
		items := ebp(recipeRecord, 'Items');
		item := ebi(items, 0);
		seev(item, 'CNTO - Item\Item', ShortName(aRecord));
		seev(item, 'CNTO - Item\Count', 1);
		seev(recipeRecord, 'COCT', 1);
		// Set created object stuff
		senv(recipeRecord, 'CNAM', $000800E4); // LeatherStrips
		seev(recipeRecord, 'NAM1', 2);
		Inc(rc);
  end;

	// Finalize
	slTemp.Free;
	slItem.Free;
	
	debugMsg := False;
// End debugMsg section
end;

// Shifts all TForm components up or down 
Procedure TShift(aInteger, bInteger: Integer; aForm: TForm; aBoolean: Boolean);
var
	debugMsg: Boolean;
	i: Integer;
begin
	for i := 0 to aForm.ComponentCount-1 do begin
		if (aForm.Components[i].Top >= aInteger) then begin
			if aBoolean then begin
				aForm.Components[i].Top := aForm.Components[i].Top - bInteger;
			end else begin
				aForm.Components[i].Top := aForm.Components[i].Top + bInteger;
			end;
		end;
	end;
end;

// Checks if an input record has an item matching the input EditorID.
function HasItem(aRecord: IInterface; s: string): Boolean;
var
  name: string;
  items, li: IInterface;
  i: integer;
begin
  Result := False;
  items := ebp(aRecord, 'Items');
  if not Assigned(items) then 
    exit;
  
  for i := 0 to Pred(ec(items)) do begin
    li := ebi(items, i);
    name := EditorID(LinksTo(ebp(li, 'CNTO - Item\Item')));
    if (name = s) then begin
      Result := True;
      Break;
    end;
  end;
end;

// Clears empty TStringList entries
Procedure slClearEmptyStrings(aList: TStringList);
var
	slTemp: TStringList;
	i: Integer;
begin
	// Initialize
	slTemp := TStringList.Create;
	
	// Process
	for i := 0 to aList.Count-1 do
		if (aList[i] = '') then
			slTemp.Add(aList[i]);
	for i := 0 to slTemp.Count-1 do
		if (aList.IndexOf(slTemp[i]) >= 0) then
			aList.Delete(aList.IndexOf(slTemp[i]));
	
	// Finalize
	slTemp.Free;
end;

// Removes an entry that contains substr
Procedure slDeleteString(s: String; aList: TStringList);
var
	i, tempInteger: Integer;
	slTemp: TStringList;
begin
	// Initialize
	slTemp := TStringList.Create;
	
	// Process
	if StrWithinSL(s, aList) then begin
		for i := 0 to aList.Count-1 do
			if StrWithinStr(aList[i], s) then
				slTemp.Add(aList[i]);
		for i := 0 to slTemp.Count-1 do
			if (aList.IndexOf(slTemp[i]) >= 0) then
				aList.Delete(aList.IndexOf(slTemp[i]));
	end;
	
	// Finalize
	slTemp.Free;
end;

// Gets an object associated with a string
Function GetObject(s: String; aList: TStringList): TObject;
var
	tempString: String;
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[GetObject] GetObject( '+s+', aList );');
	{Debug} if debugMsg then msgList('[GetObject] aList := ', aList, '');
	if slContains(slGlobal, s) then
		Result := aList.Objects[aList.IndexOf(s)];

	debugMsg := False;
// End debugMsg section
end;

// Gets an object associated with a string
Function StringObject(s: String; aList: TStringList): String;
var
	tempObject: TObject;
	tempString: String;
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[GetObject] GetObject( '+s+', aList );');
	{Debug} if debugMsg then msgList('[GetObject] aList := ', aList, '');
	for i := 0 to aList.Count-1 do begin
		if StrWithinStr(aList[i], s) then begin
			Result := StrPosCopy(aList[i], '=', False);
			{Debug} if debugMsg then msg('[GetObject] Result := '+Result);
			Exit;
		end;
	end;		

	debugMsg := False;
// End debugMsg section
end;

// Removes an entry that contains substr
Procedure SetObject(s: String; aObject: Variant; aList: TStringList);
var
	i, tempInteger: Integer;
	tempObject: TObject;
	debugMsg: Boolean;	
begin
// Begin debugMsg Section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[SetObject] SetObject( '+s+', aObject, aList );');
	{Debug} if debugMsg then msg('[SetObject] aObject := '+varTypeAsText(aObject));
	{Debug} if debugMsg then msgList('[SetObject] aList := ', aList, '');
	tempInteger := aList.IndexOf(s);
	if not (tempInteger > -1) then begin
		for i := 0 to aList.Count-1 do begin
			if (aList[i] = s) then begin
				tempInteger := i;	
				Break;
			end;
		end;
	end;
	if (varTypeAsText(aObject) = 'UnicodeString') then begin
		if (tempInteger > -1) then begin
			{Debug} if debugMsg then msg('[SetObject] aList[i] := '+s+'='+varToStr(aObject));
			aList[tempInteger] := s+'='+varToStr(aObject);
			Exit;
		end else begin
			{Debug} if debugMsg then msg('[SetObject] aList.Add( '+s+'='+varToStr(aObject)+' );');
			aList.Add(s+'='+varToStr(aObject));
		end;
	end else begin
		if (tempInteger > -1) then begin
			if (varType(aObject) = varBoolean) or (varType(aObject) = varInteger) then begin
				aList.Objects[tempInteger] := aObject;
			end else
				aList.Objects[tempInteger] := TObject(aObject);
		end else begin
			if (varType(aObject) = varBoolean) or (varType(aObject) = varInteger) then begin
				aList.AddObject(s, aObject);
			end else
				aList.AddObject(s, TObject(aObject));
		end;
	end;
	
	debugMsg := False;
// End debugMsg section
end;

// Gets the component associated with a caption
function AssociatedComponent(s: String; frm: TForm): TObject;
begin
	Result := ComponentByTop(ComponentByCaption(s, frm).Top - 2, frm)
end;

function PreviousOverrideExists(aRecord: IInterface; LoadOrder: Integer): Boolean;
var
	debugMsg, tempBoolean: Boolean;
	tempRecord: IInterface;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	Result := False;
	if (OverrideCount(aRecord) > 0) then begin
		tempBoolean := False;
		for y := Pred(OverrideCount(aRecord)) downto 0 do begin
			tempRecord := OverrideByIndex(aRecord, y);
			if (LoadOrder >= GetLoadOrder(GetFile(tempRecord))) then begin
				{Debug} if debugMsg then msg('[PreviousOverrideExists] '+EditorID(tempRecord)+' := '+IntToStr(LoadOrder)+' >= '+IntToStr(GetLoadOrder(GetFile(tempRecord))));
				Result := True;
				Exit;
			end;
		end;
	end;
	
	debugMsg := False;
// End debugMsg section
end;

function GetPreviousOverride(aRecord: IInterface; LoadOrder: Integer): IInterface;
var
	debugMsg, tempBoolean: Boolean;
	tempRecord: IInterface;
	i, y: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	Result := nil;
	if (OverrideCount(aRecord) > 0) then begin
		tempBoolean := False;
		for y := Pred(OverrideCount(aRecord)) downto 0 do begin
			tempRecord := OverrideByIndex(aRecord, y);
			if (LoadOrder >= GetLoadOrder(GetFile(tempRecord))) then begin
				{Debug} if debugMsg then msg('[PreviousOverrideExists] '+EditorID(tempRecord)+' := '+IntToStr(LoadOrder)+' >= '+IntToStr(GetLoadOrder(GetFile(tempRecord))));
				Result := tempRecord;
				Exit;
			end;
		end;
	end;
	
	debugMsg := False;
// End debugMsg section
end;

function HasFileOverride(aRecord, aFile: IInterface): Boolean;
var
	debugMsg, tempBoolean: Boolean;
	tempRecord: IInterface;
	i, y: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	Result := False;
	if (OverrideCount(aRecord) > 0) then begin
		tempBoolean := False;
		for y := Pred(OverrideCount(aRecord)) downto 0 do begin
			tempRecord := OverrideByIndex(aRecord, y);
			if (GetLoadOrder(aFile) = GetLoadOrder(GetFile(tempRecord))) then begin
				{Debug} if debugMsg then msg('[PreviousOverrideExists] '+EditorID(tempRecord)+' := '+IntToStr(GetLoadOrder(aFile))+' >= '+IntToStr(GetLoadOrder(GetFile(tempRecord))));
				Result := True;
				Exit;
			end;
		end;
	end;
	
	debugMsg := False;
// End debugMsg section
end;

function GetFileOverride(aRecord, aFile: IInterface): IInterface;
var
	debugMsg, tempBoolean: Boolean;
	tempRecord: IInterface;
	i, y: Integer;
begin
// Begin debugMsg section
	debugMsg := False;
	
	Result := nil;
	if (OverrideCount(aRecord) > 0) then begin
		tempBoolean := False;
		for y := Pred(OverrideCount(aRecord)) downto 0 do begin
			tempRecord := OverrideByIndex(aRecord, y);
			if (GetLoadOrder(aFile) = GetLoadOrder(GetFile(tempRecord))) then begin
				{Debug} if debugMsg then msg('[PreviousOverrideExists] '+EditorID(tempRecord)+' := '+IntToStr(GetLoadOrder(aFile))+' >= '+IntToStr(GetLoadOrder(GetFile(tempRecord))));
				Result := tempRecord;
				Exit;
			end;
		end;
	end;
	
	debugMsg := False;
// End debugMsg section
end;

function GetEnchLevel(objEffect: IInterface; slItemTiers: TStringList): Integer;
var
	tempBoolean: Boolean;
	tempString: String;
	i: Integer;
begin
	Result := -1;
	tempString := Copy(EditorID(objEffect), Length(EditorID(objEffect))-1, 2);
	// {Debug} if debugMsg then msg('[GetEnchLevel] tempString := '+tempString);
	if slContains(slItemTiers, tempString) then begin
		Result := Integer(GetObject(tempString, slItemTiers));
	// This is specifically for 'More Interesting Loot' enchantments
	end else if (Copy(EditorID(objEffect), 1, 2) = 'aa') then begin
		tempString := EditorID(objEffect);
		if (Length(IntToStr(IntWithinStr(tempString))) = 1) then begin
			for i := 1 to 6 do begin
				if slContains(slItemTiers, '0'+IntToStr(i)) then begin
					Result := slItemTiers.Objects[slItemTiers.IndexOf('0'+IntToStr(i))]
				end else
					Result := slItemTiers.Objects[slItemTiers.Count-1];
			end;
		end else if (IntWithinStr(tempString) = 10) then begin
			Result := slItemTiers.Objects[0];
		end else if (IntWithinStr(tempString) > 50) and (IntWithinStr(tempString) < 100) then begin
			Result := slItemTiers.Objects[slItemTiers.Count-1];
		end else if (IntWithinStr(tempString) > 100) and (IntWithinStr(tempString) <= 200) then begin
				if StrWithinStr(tempString, 'Greater') then begin
					Result := slItemTiers.Objects[slItemTiers.Count-1];
				end else
					Result := slItemTiers.Objects[(slItemTiers.Count div 2)];
		end else begin
			Result := IntWithinStr(tempString);
		end;
	end;
	if (Result = 0) then
		Result := 1;
end;

//  A copy function that allows you to copy from one position to another [mte functions]
function StrPosCopyBetween(inputString, aString, bString: String): String;
var
	i, p1, p2: Integer;
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := False;
	
  Result := '';
	Result := StrPosCopy(StrPosCopy(inputString, aString, False), bString, True);
	{Debug} if debugMsg then msg('[StrPosCopyBetween] Result := '+Result);
	
	debugMsg := False;
// End debugMsg section
end;

Procedure GenderOnlyArmor(aString: String; aRecord, aPlugin: IInterface);
var
	tempRecord: IInterface;
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[GenderOnlyArmor] GenderOnlyArmor( '+aString+', '+EditorID(aRecord)+', '+GetFileName(aPlugin)+' );');
	if StrWithinStr(aString, 'Male') then begin
		if not (Length(geev(aRecord, 'Female world model\MOD4')) > 0) then begin
			if not (GetLoadOrder(GetFile(aRecord)) = GetLoadOrder(aPlugin)) then begin
				tempRecord := CopyRecordToFile(aRecord, aPlugin, False, True);
			end else
				tempRecord := aRecord;
			Add(tempRecord, 'Female world model', True);
			Add(tempRecord, 'Female world model\MOD4', True);
			seev(tempRecord, 'Female world model\MOD4', geev(WinningOverride(ote(GetObject(EditorID(tempRecord)+'Template', slGlobal))), 'Female world model\MOD4'));
			if not (Length(geev(tempRecord, 'Female world model\MOD4')) > 0) then
				seev(tempRecord, 'Female world model\MOD4', geev(WinningOverride(ote(GetObject(EditorID(tempRecord)+'Template', slGlobal))), 'Male world model\MOD2'));
		end;
	end else if StrWithinStr(aString, 'Female') then begin
		if not (Length(geev(aRecord, 'Male world model\MOD2')) > 0) then begin
			if not (GetLoadOrder(GetFile(aRecord)) = GetLoadOrder(aPlugin)) then begin
				tempRecord := CopyRecordToFile(aRecord, aPlugin, False, True);
			end else
				tempRecord := aRecord;
			Add(tempRecord, 'Male world model', True);
			Add(tempRecord, 'Male world model\MOD2', True);
			seev(tempRecord, 'Male world model\MOD2', geev(WinningOverride(ote(GetObject(EditorID(tempRecord)+'Template', slGlobal))), 'Male world model\MOD2'));
		end;
	end else
		msg('[GenderOnlyArmor] aString := '+aString+' does not contain ''Male'' or ''Female''');
end;

function HasGenderKeyword(aRecord: IInterface): Boolean;
var
	Keywords: IInterface;
	tempString: String;
	debugMsg: Boolean;
	i: Integer;
begin
  Result := False;
  Keywords := ebp(aRecord, 'KWDA');
  for i := 0 to ec(Keywords) - 1 do begin
		tempString := EditorID(LinksTo(ebi(Keywords, i)));
    if StrWithinStr(tempString, 'Male') or StrWithinStr(tempString, 'Female') then begin
      Result := True;
      Break;
    end;
  end;
end;

function GetGenderFromKeyword(aRecord: IInterface): String;
var
	Keywords: IInterface;
	tempString: String;
	debugMsg: Boolean;
	i: Integer;
begin
  Result := '';
  Keywords := ebp(aRecord, 'KWDA');
  for i := 0 to ec(Keywords) - 1 do begin
		tempString := EditorID(LinksTo(ebi(Keywords, i)));
    if StrWithinStr(tempString, 'Male') then begin
			Result := 'Male';
			Break;
		end else if StrWithinStr(tempString, 'Female') then begin
      Result := 'Female';
      Break;
    end;
  end;
end;

function IsClothing(aRecord: IInterface): Boolean;
var
	Keywords: IInterface;
	tempString: String;
	debugMsg: Boolean;
	i: Integer;
begin
	Result := False;
	if not (sig(aRecord) = 'ARMO') then
		Exit;
	if ee(aRecord, 'BODT') then begin
		tempString := 'BODT';
	end else
		tempString := 'BOD2';
	if (geev(aRecord, tempString+'\Armor Type') = 'Clothing') then begin
		Result := True;
		Exit;
	end;
	if StrWithinStr(EditorID(aRecord), 'Clothing') then begin
		Result := True;
		Exit;
	end;
  for i := 0 to ec(Keywords) - 1 do begin
		tempString := EditorID(LinksTo(ebi(Keywords, i)));
    if StrWithinStr(tempString, 'Clothing') then begin
			Result := True;
			Exit;
		end;
  end;
	if ee(aRecord, 'DNAM') then begin
		if (genv(aRecord, 'DNAM') = 0) then begin
			Result := True;
			Exit;
		end;
	end else
		Result := True;
end;

function MostCommonString(aList: TStringList): String;
var
	i, x, tempInteger, Count: Integer;
	slTemp: TStringList;
	debugMsg: Boolean;
begin
	// Begin debugMsg Section
	debugMsg := False;
	
	// Initialize
	if debugMsg then msgList('[MostCommonString] MostCommonString(', aList, ');');
	slTemp := TStringList.Create;
	
	// Process
	tempInteger := 0;
	for i := 0 to aList.Count-1 do begin
		if slContains(slTemp, aList[i]) then Continue;
		Count := 0;
		for x := 0 to aList.Count-1 do
			if (aList[x] = aList[i]) and (x <> i) then
				Count := Count+1;
		if (Count > tempInteger) and (Count > 1) then begin
			Result := aList[i];
			tempInteger := Count;
		end;
		slTemp.Add(aList[i]);
	end;
	
	// Finalize
	if debugMsg then msg('[MostCommonString] Result := '+Result);
	slTemp.Free;
	
	debugMsg := False;
	// End debugMsg Section
end;

function GetElementType(aRecord: IInterface): String;
var
	debugMsg: Boolean;
begin
	debugMsg := False;
	
	{Debug} if debugMsg then msg('[GetElementType] GetElementType( '+EditorID(aRecord)+' );');
	{Debug} if debugMsg then msg('[GetElementType] sig( '+EditorID(aRecord)+' := '+sig(aRecord));
	if (sig(aRecord) = 'ARMO') then begin
		if ee(aRecord, 'BODT') then begin
			Result := 'BODT';
		end else
			Result := 'BOD2';
	end else if (sig(aRecord) = 'LVLI') then
		Result := 'LVLF';
end;

function TimeBtwn(Start, Stop: TDateTime): Integer;
begin
	Result := ((3600*GetHours(Stop))+(60*GetMinutes(Stop))+GetSeconds(Stop))-((3600*GetHours(Start))+(60*GetMinutes(Start))+GetSeconds(Start));
end;

function GetSeconds(aTime: TDateTime): Integer;
var
	tempString: String;
begin
	tempString := TimeToStr(aTime);
	if StrWithinStr(tempString, 'PM') then
		Result := StrToInt(Trim(StrPosCopy(StrPosCopy(StrPosCopy(tempString, ':', False), ':', False), 'PM', True)))
	else
		Result := StrToInt(Trim(StrPosCopy(StrPosCopy(StrPosCopy(tempString, ':', False), ':', False), 'AM', True)))
end;

function GetMinutes(aTime: TDateTime): Integer;
begin
	Result := StrToInt(Trim(StrPosCopy(StrPosCopy(TimeToStr(aTime), ':', False), ':', True)));
end;

function GetHours(aTime: TDateTime): Integer;
begin
	Result := StrToInt(Trim(StrPosCopy(TimeToStr(aTime), ':', True)));
end;

function IntegerToTime(TotalTime: Integer): String;
var
	TimeInteger, Hours, Minutes, Seconds: Integer;
	stringHours, stringMinutes, stringSeconds: String;
	tempString: String;
begin
	TimeInteger := TotalTime;
	// Hours
	while (TimeInteger > 3600) do begin
		TimeInteger := TimeInteger-3600;
		Hours := Hours + 1;
	end;
	if (Hours <= 0) then begin
		stringHours := '00';
	end else if (Hours < 10) then
		stringHours := '0'+IntToStr(Hours)
	else
		stringHours := IntToStr(Hours);
	// Minutes
	while (TimeInteger > 60) do begin
		 TimeInteger := TimeInteger - 60;
		 Minutes := Minutes + 1;
	end;
	if (Minutes <= 0) then begin
		stringMinutes := '00';
	end else if (Minutes < 10) then
		stringMinutes := '0'+IntToStr(Minutes)
	else
		stringMinutes := IntToStr(Minutes);
	// Seconds
	if (TimeInteger <= 0) then begin
		stringSeconds := '00';
	end else if (TimeInteger < 10) then
		stringSeconds := '0'+IntToStr(TimeInteger)
	else
		stringSeconds := IntToStr(TimeInteger);
	Result := stringHours+':'+stringMinutes+':'+stringSeconds;
end;

Procedure addProcessTime(aFunctionName: String; aTime: Integer);
begin
	SetObject(aFunctionName, Integer(GetObject(aFunctionName, slProcessTime))+aTime, slProcessTime);
end;

end.

