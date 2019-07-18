implementation

type
    EnchantmentSkipList = class()
    
private
    masterladder : levellist;
    
    
    function coinflip()boolean;//used in determining height
    begin
        if 
            (randomrange(1, 2) = 1) then := true //tails
        end else 
            result := false //heads
        end;
    end;
    
    function insertbase(iFormId : cardinal, iEnch : IInterface, passedNode : lnode, child : IInterface)boolean;
    var
        coinflip : boolean;
        insertionNode : bEnchNode;
        NewNode : lnode;
    begin
        if not passedNode.getnext() = nil then begin//level continues
            if passedNode.getnext().getEnchNode().getFormId() = iFormId then begin//node already added (child was called before base and added it)
                result := false;
            end else if passedNode.getnext().getEnchNode().getFormId() < iFormId then begin//move down or place node
                if passedNode.getdown() = nil then begin //level 0, place node
                    insertionNode := bEnchNode.create(iFormId, iEnch);//create basenode
                    if not child = nil then begin
                        insertionNode.addChild(child);
                    end;
                    NewNode := insertionNode.getlevels().gethead();//assign top level of insertionNode to Newnode
                    NewNode.setnext(passedNode.getNext());//give the new node the correct pointer
                    passedNode.setnext(NewNode);//give the current node the pointer to the new one
                    result := coinflip();//determine if next level should be built
                end else begin //level n, move down
                    coinflip := insertbase(iFormId, iEnch, passedNode.getdown(), child);//move down a node
                    if coinflip then begin//add level if prev. was added and told to add a level
                        while not passedNode.getdown().getNext().getEnchNode().getFormId() = iFormID do //move lateral until insertion point is found for level
                            passedNode := passedNode.getdown().getNext();
                        end;
                        insertionNode := passedNode.getdown().getNext().getEnchNode();//get node
                        insertionNode.getlevels().addlevel();//increase height
                        NewNode := insertionNode.getlevels().gethead();//assign top level of insertionNode to Newnode
                        NewNode.setnext(passedNode.getNext());//give the new node the correct pointer
                        passedNode.setnext(NewNode);//give the current node the pointer to the new one
                        result := coinflip();//determine if next level should be built
                    end else begin
                        result := false;//no more levels as this one wans't built
                    end;
                end;
            end else begin//move right
                insertbase(iFormId, iEnch, passedNode.getnext(), child);
            end;
        end else begin//end of level, must move down or insert 
            if passedNode.getdown() = nil then begin //level n, move down
                coinflip := insertbase(iFormId, iEnch, passedNode.getdown(), child);//move down
                if coinflip then begin//add level if prev. was added and told to add a level
                    insertionNode := passedNode.getdown().getNext().getEnchNode();//get node
                    insertionNode.getlevels().addlevel();//increase height
                    NewNode := insertionNode.getlevels().gethead();//assign top level of insertionNode to Newnode
                    NewNode.setnext(passedNode.getNext());//give the new node the correct pointer
                    passedNode.setnext(NewNode);//give the current node the pointer to the new one
                    result := coinflip();//determine if next level should be built
                end else begin
                    result := false;//no more levels as this one wasn't built
                end;
            end else begin//level 0, place node
                insertionNode := bEnchNode.create(iFormId, iEnch);//create basenode
                if not child = nil then begin
                    insertionNode.addChild(child);
                end;
                passedNode.setnext(insertionNode.getlevels().gethead())//give the current node the pointer to the new one
                result := coinflip();//return value to determine if next level up is built
            end;
        end;
    end;
    
    function insertchild(iFormId : cardinal, passedNode : lnode, iNode : cEnchNode)boolean;
    begin
        if not passedNode.getnext() = nil then begin//level continues
             if passedNode.getnext().getEnchNode().getFormId() = iFormId then begin//is correct node, insert
                passedNode.getnext().getEnchNode().addChild(iNode);
                result := true;
             end else if passedNode.getnext().getEnchNode().getFormId() < iFormId then begin//is greater, move down
                if passedNode.getdown() = nil then begin//at L0, node not found
                    result := false;
                end else begin//move down
                    result := insertchild(iFormID, passedNode.getdown(), iNode);
             end else//is less, move right
                result := insertchild(iFormID, passedNode.getnext(), iNode);
        end else begin//end of level must move down
            if passedNode.getdown() = nil then begin//at L0, node not found
                result := false;
            end else begin//move down
                result := insertchild(iFormID, passedNode.getdown(), iNode);
            end;
        end;
    end;
public

    constructor create();
        masterladder := levellist.create(nil, nil);
    end;
     
    procedure insert(iEnch : IInterface);
    var
        coinflip,basefound : boolean;
        tmp : lnode;
        child : cEnchNode;
    begin
        if not iEnch.getNativeValue(ElementByPath(selectedRecord, 'ENIT\Base Enchantment')) = nil then 
            coinflip := insertbase(GetLoadOrderFormID(iEnch), iEnch, masterladder.gethead(), nil);
            while coinflip do//keep building up past the prev. master ladder height
                insertionNode := masterladder.gethead().getdown().getNext().getEnchNode();//get node
                insertionNode.getlevels().addlevel();//increase height
                masterladder.addlevel();//increase height of ladder
                masterladder.gethead().setnext(insertionNode.getlevels().gethead());//assign  the ladder to the new level node
                coinflip := coinflip();//determine if next level should be built
            end;
        end else
            child := cEnchNode.create(iEnch, iEnch.getNativeValue(ElementByPath(selectedRecord, 'ENIT\Enchantment Cost')));
            basefound := insertchild(iEnch.getNativeValue(ElementByPath(selectedRecord, 'ENIT\Base Enchantment')), masterladder.gethead(), child);
            if not basefound then begin
                insertbase(iEnch.getNativeValue(ElementByPath(selectedRecord, 'ENIT\Base Enchantment')), iEnch, masterladder.gethead(), child);
            end;
        end;
    end;
    
    
    //TODO
    procedure processEnchantments()
        i : lnode;
        ench : IInterface;
    begin
        i := masterladder.getL0();
        while not i.getnext() = nil begin
            i := i.getnext();
            ench := i.getEnchNode().getEnch()
            {check refrenced by}
            {if refrenced by non armor or weap}
                {set FormID to Null}
            {else}
                {if refrenced by armor, iterate and find slots}
        end;
    end;